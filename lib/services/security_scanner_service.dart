import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/models/security_finding.dart';
import 'package:mr_helper_security_analyzer/utils/cert_inspector.dart';
import 'package:mr_helper_security_analyzer/utils/validators.dart';

/// MR HELPER - Web Application Security Analyzer
/// Service for performing website security scans

class SecurityScannerService {
  /// CORS proxies used only on the web build, where the browser blocks direct
  /// cross-origin reads. Each function maps the target URL to a proxied URL
  /// that forwards the original response headers. Tried in order until one
  /// returns a usable response.
  static final List<String Function(String)> _webProxies = [
    (u) => 'https://corsproxy.io/?url=${Uri.encodeComponent(u)}',
    (u) => 'https://api.codetabs.com/v1/proxy/?quest=$u',
    (u) => 'https://thingproxy.freeboard.io/fetch/$u',
  ];

  /// Inspect the TLS certificate without ever throwing or stalling the scan.
  /// Returns an empty map for non-HTTPS targets, on web, or on any error.
  Future<Map<String, dynamic>> _inspectCertificateSafe(String url) async {
    if (kIsWeb || !UrlValidator.isHttps(url)) return const {};
    try {
      final uri = Uri.parse(url);
      return await inspectCertificate(uri.host, uri.hasPort ? uri.port : 443)
          .timeout(AppConstants.certTimeout);
    } catch (_) {
      return const {};
    }
  }

  /// Fetch the target, going through proxies on web and directly elsewhere.
  Future<http.Response> _fetchWithFallback(String targetUrl) async {
    final requestHeaders = {
      'User-Agent': 'Mozilla/5.0 (compatible; MRHELPER-SecurityAnalyzer/2.0)',
      'Accept': '*/*',
    };

    // Mobile / desktop: direct request, no proxy needed.
    if (!kIsWeb) {
      return http
          .get(Uri.parse(targetUrl), headers: requestHeaders)
          .timeout(AppConstants.requestTimeout);
    }

    // Web: try each proxy in turn, returning the first successful response.
    Object? lastError;
    for (final proxy in _webProxies) {
      try {
        final proxiedUrl = proxy(targetUrl);
        final response = await http
            .get(Uri.parse(proxiedUrl), headers: requestHeaders)
            .timeout(AppConstants.requestTimeout);
        if (response.statusCode < 500) {
          return response;
        }
        lastError = 'Proxy returned ${response.statusCode}';
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(
        'Could not reach the target through any proxy. ${lastError ?? ''}'
            .trim());
  }

  /// Perform a full security scan on the given URL
  Future<ScanResult> performScan(String url) async {
    final normalizedUrl = UrlValidator.normalizeUrl(url);

    try {
      // On web the browser blocks direct cross-origin reads (CORS), so route
      // through a proxy that exposes the headers. On mobile/desktop we hit the
      // target directly. Redirects are followed automatically.
      // Run the header fetch and the TLS certificate inspection CONCURRENTLY.
      // They are independent (the cert check opens its own socket), so doing
      // them in parallel keeps the total scan time short instead of adding up.
      final certificateFuture = _inspectCertificateSafe(normalizedUrl);
      final response = await _fetchWithFallback(normalizedUrl);
      final certificate = await certificateFuture;

      // All the scoring logic lives in analyzeHeaders so it can be unit-tested
      // without performing a network request.
      return analyzeHeaders(normalizedUrl, response.headers,
          certificate: certificate);
    } on http.ClientException {
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } catch (e) {
      final message = e.toString();
      if (message.contains('TimeoutException')) {
        throw Exception(
            'Request timed out. The server may be too slow or unreachable.');
      }
      if (message.contains('SocketException') ||
          message.contains('Failed host lookup')) {
        throw Exception(
            'Unable to connect to the server. Please check the URL and try again.');
      }
      throw Exception('Scan failed: ${message.replaceAll('Exception: ', '')}');
    }
  }

  /// Analyze response headers and produce a [ScanResult]. Pure logic with no
  /// network I/O — this is what the unit tests exercise. [headers] keys are
  /// expected to be lowercase (as the http package returns them).
  ScanResult analyzeHeaders(
    String normalizedUrl,
    Map<String, String> headers, {
    Map<String, dynamic> certificate = const {},
  }) {
    final httpsEnabled = UrlValidator.isHttps(normalizedUrl);

    // A header only "counts" when it is present AND carries a meaningful value.
    final hsts = _hasValidHsts(headers);
    final csp = _hasNonEmpty(headers, 'content-security-policy');
    final xFrameOptions = _hasValidXFrame(headers);
    final xContentTypeOptions = _hasNosniff(headers);
    final referrerPolicy = _hasNonEmpty(headers, 'referrer-policy');
    final permissionsPolicy = _hasNonEmpty(headers, 'permissions-policy');

    final headersMap = <String, bool>{
      'strict-transport-security': hsts,
      'content-security-policy': csp,
      'x-frame-options': xFrameOptions,
      'x-content-type-options': xContentTypeOptions,
      'referrer-policy': referrerPolicy,
      'permissions-policy': permissionsPolicy,
    };

    final cookies = _analyzeCookies(headers);
    final serverInfo = _analyzeServerInfo(headers);

    final score = _calculateScore(
      https: httpsEnabled,
      hsts: hsts,
      csp: csp,
      xFrameOptions: xFrameOptions,
      xContentTypeOptions: xContentTypeOptions,
      referrerPolicy: referrerPolicy,
      permissionsPolicy: permissionsPolicy,
      cookies: cookies,
    );

    final findings = _buildFindings(
      https: httpsEnabled,
      headers: headers,
      headersMap: headersMap,
      cookies: cookies,
      serverInfo: serverInfo,
      certificate: certificate,
    );

    return ScanResult(
      url: normalizedUrl,
      score: score,
      risk: _classifyRisk(score),
      https: httpsEnabled,
      hsts: hsts,
      csp: csp,
      headers: headersMap,
      cookies: cookies,
      serverInfo: serverInfo,
      certificate: certificate,
      findings: findings,
      timestamp: DateTime.now(),
    );
  }

  /// Detect server-software disclosure from Server / X-Powered-By headers.
  Map<String, dynamic> _analyzeServerInfo(Map<String, String> headers) {
    final server = headers['server']?.trim();
    final poweredBy = headers['x-powered-by']?.trim();
    // A version number in the banner is the real risk (helps attackers target
    // known CVEs). A bare product name like "cloudflare" is not.
    final versionPattern = RegExp(r'\d+\.\d+');
    final disclosed = (server != null && versionPattern.hasMatch(server)) ||
        (poweredBy != null && poweredBy.isNotEmpty);
    return {
      if (server != null && server.isNotEmpty) 'server': server,
      if (poweredBy != null && poweredBy.isNotEmpty) 'poweredBy': poweredBy,
      'disclosed': disclosed,
    };
  }

  /// True if the CSP value contains an unsafe directive.
  bool _cspHasUnsafe(Map<String, String> headers) {
    final value = headers['content-security-policy']?.toLowerCase() ?? '';
    return value.contains('unsafe-inline') || value.contains('unsafe-eval');
  }

  /// Build the severity-ranked findings list shown in the report.
  List<SecurityFinding> _buildFindings({
    required bool https,
    required Map<String, String> headers,
    required Map<String, bool> headersMap,
    required Map<String, dynamic> cookies,
    required Map<String, dynamic> serverInfo,
    required Map<String, dynamic> certificate,
  }) {
    final findings = <SecurityFinding>[];

    if (!https) {
      findings.add(const SecurityFinding(
        title: 'No HTTPS encryption',
        description:
            'The site is served over plain HTTP. All traffic can be read or '
            'modified by anyone on the network.',
        severity: FindingSeverity.critical,
        code: FindingCode.noHttps,
        recommendation:
            'Install a valid SSL/TLS certificate and redirect all HTTP to HTTPS.',
      ));
    }

    if (!headersMap['strict-transport-security']!) {
      findings.add(const SecurityFinding(
        title: 'Missing Strict-Transport-Security (HSTS)',
        description:
            'Without HSTS, browsers may connect over insecure HTTP and are '
            'vulnerable to SSL-stripping attacks.',
        severity: FindingSeverity.high,
        code: FindingCode.missingHsts,
        recommendation:
            'Add: Strict-Transport-Security: max-age=63072000; includeSubDomains; preload',
      ));
    }

    if (!headersMap['content-security-policy']!) {
      findings.add(const SecurityFinding(
        title: 'Missing Content-Security-Policy (CSP)',
        description:
            'CSP is the strongest defense against cross-site scripting (XSS) '
            'and data-injection attacks.',
        severity: FindingSeverity.high,
        code: FindingCode.missingCsp,
        recommendation:
            "Define a restrictive policy, e.g. default-src 'self'.",
      ));
    } else if (_cspHasUnsafe(headers)) {
      findings.add(const SecurityFinding(
        title: 'Weak Content-Security-Policy',
        description:
            "The CSP allows 'unsafe-inline' or 'unsafe-eval', which largely "
            'defeats its protection against XSS.',
        severity: FindingSeverity.medium,
        code: FindingCode.weakCsp,
        recommendation:
            "Remove 'unsafe-inline'/'unsafe-eval' and use nonces or hashes.",
      ));
    }

    if (!headersMap['x-frame-options']!) {
      findings.add(const SecurityFinding(
        title: 'Missing X-Frame-Options',
        description:
            'The site can be embedded in an iframe, enabling clickjacking.',
        severity: FindingSeverity.medium,
        code: FindingCode.missingXFrame,
        recommendation: 'Add: X-Frame-Options: DENY (or SAMEORIGIN).',
      ));
    }

    if (!headersMap['x-content-type-options']!) {
      findings.add(const SecurityFinding(
        title: 'Missing X-Content-Type-Options',
        description:
            'Browsers may MIME-sniff responses, which can lead to XSS.',
        severity: FindingSeverity.medium,
        code: FindingCode.missingXContent,
        recommendation: 'Add: X-Content-Type-Options: nosniff.',
      ));
    }

    if (!headersMap['referrer-policy']!) {
      findings.add(const SecurityFinding(
        title: 'Missing Referrer-Policy',
        description:
            'Full URLs may leak to third-party sites via the Referer header.',
        severity: FindingSeverity.low,
        code: FindingCode.missingReferrer,
        recommendation: 'Add: Referrer-Policy: strict-origin-when-cross-origin.',
      ));
    }

    if (!headersMap['permissions-policy']!) {
      findings.add(const SecurityFinding(
        title: 'Missing Permissions-Policy',
        description:
            'Powerful browser features (camera, geolocation, etc.) are not '
            'restricted.',
        severity: FindingSeverity.low,
        code: FindingCode.missingPermissions,
        recommendation:
            'Add a Permissions-Policy disabling features you do not use.',
      ));
    }

    // Modern cross-origin isolation headers (advisory).
    if (!_hasNonEmpty(headers, 'cross-origin-opener-policy')) {
      findings.add(const SecurityFinding(
        title: 'Missing Cross-Origin-Opener-Policy (COOP)',
        description:
            'COOP isolates your window from cross-origin popups, mitigating '
            'side-channel attacks.',
        severity: FindingSeverity.info,
        code: FindingCode.missingCoop,
        recommendation: 'Consider: Cross-Origin-Opener-Policy: same-origin.',
      ));
    }
    if (!_hasNonEmpty(headers, 'cross-origin-resource-policy')) {
      findings.add(const SecurityFinding(
        title: 'Missing Cross-Origin-Resource-Policy (CORP)',
        description:
            'CORP prevents other sites from embedding your resources.',
        severity: FindingSeverity.info,
        code: FindingCode.missingCorp,
        recommendation: 'Consider: Cross-Origin-Resource-Policy: same-origin.',
      ));
    }

    // Server software disclosure.
    if (serverInfo['disclosed'] == true) {
      final banner = [serverInfo['server'], serverInfo['poweredBy']]
          .where((e) => e != null)
          .join(' / ');
      findings.add(SecurityFinding(
        title: 'Server software disclosed',
        description:
            'The server reveals its software/version ($banner), helping '
            'attackers find matching exploits.',
        severity: FindingSeverity.low,
        code: FindingCode.serverDisclosed,
        param: banner,
        recommendation:
            'Remove or obfuscate the Server and X-Powered-By headers.',
      ));
    }

    // Cookie findings.
    if (cookies['present'] == true) {
      if (cookies['secure'] != true) {
        findings.add(const SecurityFinding(
          title: 'Cookie missing Secure flag',
          description:
              'One or more cookies can be sent over unencrypted HTTP.',
          severity: FindingSeverity.medium,
          code: FindingCode.cookieNoSecure,
          recommendation: 'Add the Secure attribute to every cookie.',
        ));
      }
      if (cookies['httpOnly'] != true) {
        findings.add(const SecurityFinding(
          title: 'Cookie missing HttpOnly flag',
          description:
              'Cookies are readable by JavaScript, exposing them to XSS theft.',
          severity: FindingSeverity.medium,
          code: FindingCode.cookieNoHttpOnly,
          recommendation: 'Add the HttpOnly attribute to session cookies.',
        ));
      }
      if (cookies['sameSite'] == 'None') {
        findings.add(const SecurityFinding(
          title: 'Cookie SameSite=None',
          description:
              'Cookies are sent on cross-site requests, enabling CSRF.',
          severity: FindingSeverity.low,
          code: FindingCode.cookieSameSiteNone,
          recommendation: 'Set SameSite=Lax or Strict.',
        ));
      }
    }

    // Certificate findings (only when an inspection was performed).
    if (certificate['checked'] == true) {
      if (certificate['valid'] == false) {
        findings.add(SecurityFinding(
          title: 'TLS certificate problem',
          description: certificate['error'] as String? ??
              'The TLS certificate could not be validated.',
          severity: FindingSeverity.critical,
          code: FindingCode.certInvalid,
          param: certificate['error'],
          recommendation: 'Install a valid, trusted certificate.',
        ));
      } else {
        final days = certificate['daysRemaining'];
        if (days is int && days >= 0 && days <= 15) {
          findings.add(SecurityFinding(
            title: 'TLS certificate expiring soon',
            description:
                'The certificate expires in $days day(s).',
            severity: FindingSeverity.high,
            code: FindingCode.certExpiringSoon,
            param: days,
            recommendation: 'Renew the certificate before it expires.',
          ));
        }
      }
    }

    return findings;
  }

  /// True when [name] header exists with a non-empty value.
  bool _hasNonEmpty(Map<String, String> headers, String name) {
    final value = headers[name];
    return value != null && value.trim().isNotEmpty;
  }

  /// HSTS only counts when it actually enforces HTTPS for some time.
  bool _hasValidHsts(Map<String, String> headers) {
    final value = headers['strict-transport-security']?.toLowerCase();
    if (value == null) return false;
    final match = RegExp(r'max-age\s*=\s*(\d+)').firstMatch(value);
    if (match == null) return false;
    return (int.tryParse(match.group(1) ?? '0') ?? 0) > 0;
  }

  /// X-Frame-Options only counts with a protective directive.
  bool _hasValidXFrame(Map<String, String> headers) {
    final value = headers['x-frame-options']?.toLowerCase().trim();
    if (value == null) return false;
    return value == 'deny' || value == 'sameorigin' || value.startsWith('allow-from');
  }

  /// X-Content-Type-Options only counts when set to nosniff.
  bool _hasNosniff(Map<String, String> headers) {
    return headers['x-content-type-options']?.toLowerCase().trim() == 'nosniff';
  }

  /// Analyze cookies from Set-Cookie headers (already fetched response).
  Map<String, dynamic> _analyzeCookies(Map<String, String> headers) {
    final setCookieHeader = headers['set-cookie'] ?? '';
    if (setCookieHeader.trim().isEmpty) {
      return {
        'present': false,
        'secure': false,
        'httpOnly': false,
        'sameSite': 'None',
        'count': 0,
      };
    }

    // Multiple Set-Cookie headers get joined with commas, but cookie values
    // (e.g. Expires dates) also contain commas. Split only before a new
    // "name=" token so we don't miscount.
    final cookies = setCookieHeader
        .split(RegExp(r',(?=\s*[A-Za-z0-9!#\$%&\x27*+\-.^_`|~]+=)'))
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    // Flags must hold for EVERY cookie to be considered secure overall.
    bool allSecure = cookies.isNotEmpty;
    bool allHttpOnly = cookies.isNotEmpty;
    String sameSite = 'Strict';

    for (final cookie in cookies) {
      final lower = cookie.toLowerCase();
      if (!RegExp(r'(^|;)\s*secure(\s*;|\s*$)').hasMatch(lower)) {
        allSecure = false;
      }
      if (!lower.contains('httponly')) allHttpOnly = false;

      if (lower.contains('samesite=none')) {
        sameSite = 'None';
      } else if (lower.contains('samesite=lax') && sameSite != 'None') {
        sameSite = 'Lax';
      } else if (!lower.contains('samesite=strict') && sameSite == 'Strict') {
        // No SameSite specified on this cookie → browsers default to Lax.
        sameSite = 'Lax';
      }
    }

    return {
      'present': true,
      'secure': allSecure,
      'httpOnly': allHttpOnly,
      'sameSite': sameSite,
      'count': cookies.length,
    };
  }

  /// Calculate a normalized 0–100 security score.
  ///
  /// Each applicable check contributes weighted points to both the earned and
  /// the maximum-possible totals, then the score is scaled to 100. Cookie
  /// checks only enter the calculation when the site actually sets cookies,
  /// so a fully-hardened site without cookies can still reach a perfect 100%.
  int _calculateScore({
    required bool https,
    required bool hsts,
    required bool csp,
    required bool xFrameOptions,
    required bool xContentTypeOptions,
    required bool referrerPolicy,
    required bool permissionsPolicy,
    required Map<String, dynamic> cookies,
  }) {
    int earned = 0;
    int possible = 0;

    void check(bool ok, int weight) {
      possible += weight;
      if (ok) earned += weight;
    }

    // Transport & header checks (always applicable).
    check(https, 25);
    check(hsts, 15);
    check(csp, 18);
    check(xFrameOptions, 10);
    check(xContentTypeOptions, 10);
    check(referrerPolicy, 7);
    check(permissionsPolicy, 5);

    // Cookie checks only apply when the site actually sets cookies.
    if (cookies['present'] == true) {
      check(cookies['secure'] == true, 4);
      check(cookies['httpOnly'] == true, 4);
      check(
        cookies['sameSite'] == 'Lax' || cookies['sameSite'] == 'Strict',
        4,
      );
    }

    if (possible == 0) return 0;
    return ((earned / possible) * 100).round().clamp(0, 100);
  }

  /// Classify risk level based on score
  String _classifyRisk(int score) {
    if (score >= 80) return AppConstants.riskLow;
    if (score >= 60) return AppConstants.riskMedium;
    if (score >= 40) return AppConstants.riskHigh;
    return AppConstants.riskCritical;
  }
}
