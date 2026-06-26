import 'dart:convert';
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

  /// Query DNS over HTTPS (Cloudflare) for SPF / DMARC / MX. Best-effort.
  Future<Map<String, dynamic>> _probeDnsEmail(String host) async {
    if (host.isEmpty) return const {};
    // Strip a leading "www." so email records resolve on the root domain.
    final domain = host.startsWith('www.') ? host.substring(4) : host;

    // Generic DoH query → list of the answer "data" strings (quotes stripped,
    // trailing dots removed).
    Future<List<String>> query(String name, String type) async {
      try {
        final res = await http.get(
          Uri.parse(
              'https://cloudflare-dns.com/dns-query?name=$name&type=$type'),
          headers: {'Accept': 'application/dns-json'},
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode != 200) return const [];
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final answers = (data['Answer'] as List?) ?? [];
        return answers
            .map((a) => (a['data'] as String? ?? '')
                .replaceAll('"', '')
                .replaceAll(RegExp(r'\.$'), '')
                .trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (_) {
        return const [];
      }
    }

    // Best-effort DKIM: probe common selectors CONCURRENTLY (not one by one,
    // which used to make this very slow).
    Future<bool> hasDkim() async {
      const selectors = ['default', 'google', 'selector1', 'selector2', 'k1'];
      final results = await Future.wait(
          selectors.map((sel) => query('$sel._domainkey.$domain', 'TXT')));
      return results.any((recs) => recs.any((r) {
            final l = r.toLowerCase();
            return l.contains('v=dkim1') || (l.contains('p=') && l.contains('k='));
          }));
    }

    final results = await Future.wait([
      query(domain, 'TXT'),
      query('_dmarc.$domain', 'TXT'),
      query(domain, 'MX'),
      query(domain, 'A'),
      query(domain, 'NS'),
      hasDkim(),
    ]);
    final rootTxt = results[0] as List<String>;
    final dmarcTxt = results[1] as List<String>;
    final mxList = results[2] as List<String>;
    final aList = results[3] as List<String>;
    final nsList = results[4] as List<String>;
    final dkim = results[5] as bool;

    final spfRecord = rootTxt.firstWhere(
      (t) => t.toLowerCase().startsWith('v=spf1'),
      orElse: () => '',
    );
    final spf = spfRecord.isNotEmpty;
    final dmarcRecord = dmarcTxt.firstWhere(
      (t) => t.toLowerCase().startsWith('v=dmarc1'),
      orElse: () => '',
    );
    final dmarc = dmarcRecord.isNotEmpty;
    String? policy;
    if (dmarc) {
      final m = RegExp(r'p=\s*(none|quarantine|reject)', caseSensitive: false)
          .firstMatch(dmarcRecord);
      policy = m?.group(1)?.toLowerCase();
    }

    // "MX data" looks like "10 mail.example.com" → keep just the host.
    String? mxHost;
    if (mxList.isNotEmpty) {
      final parts = mxList.first.split(RegExp(r'\s+'));
      mxHost = parts.length > 1 ? parts.last : parts.first;
    }

    return {
      'checked': true,
      'spf': spf,
      'spfRecord': spfRecord,
      'dmarc': dmarc,
      'dmarcRecord': dmarcRecord,
      'dmarcPolicy': policy,
      'dkim': dkim,
      'mx': mxList.isNotEmpty,
      'aRecord': aList.isNotEmpty ? aList.first : null,
      'mxRecord': mxHost,
      'nsRecord': nsList.isNotEmpty ? nsList.first : null,
      'txtRecord': spf ? spfRecord : (rootTxt.isNotEmpty ? rootTxt.first : null),
    };
  }

  /// Probe well-known paths and commonly-exposed files. Best-effort.
  Future<Map<String, dynamic>> _probeDiscovery(String baseUrl) async {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // Returns the response if it looks like a genuine hit (200 + signature),
    // guarding against soft-404 pages that return 200 for everything.
    Future<bool> exists(String path, {String? signature}) async {
      try {
        final res = await http.get(
          Uri.parse('$base$path'),
          headers: {'User-Agent': 'MRHELPER-SecurityAnalyzer/2.0'},
        ).timeout(const Duration(seconds: 8));
        if (res.statusCode != 200) return false;
        final body = res.body;
        // A real file is unlikely to be served as an HTML error page.
        final looksHtml = body.toLowerCase().contains('<!doctype html') ||
            body.toLowerCase().contains('<html');
        if (signature != null) {
          return body.contains(signature) && !looksHtml;
        }
        return !looksHtml;
      } catch (_) {
        return false;
      }
    }

    final results = await Future.wait([
      exists('/.well-known/security.txt', signature: 'Contact'),
      exists('/robots.txt', signature: 'ser-agent'),
      exists('/.git/HEAD', signature: 'ref:'),
      exists('/.env', signature: '='),
      exists('/.htaccess'),
    ]);

    return {
      'checked': true,
      'securityTxt': results[0],
      'robotsTxt': results[1],
      'exposedGit': results[2],
      'exposedEnv': results[3],
      'exposedHtaccess': results[4],
    };
  }

  /// Common database error signatures used for error-based SQL-injection
  /// detection. Lower-cased for matching.
  static final RegExp _sqlErrorPattern = RegExp(
    r'you have an error in your sql syntax|'
    r'warning:\s*mysql|mysql_fetch|mysqli_|'
    r'unclosed quotation mark after the character string|'
    r'quoted string not properly terminated|'
    r'incorrect syntax near|microsoft ole db provider for sql server|'
    r'odbc sql server driver|'
    r'ora-\d{4,5}|oracle error|'
    r'postgresql.*error|pg_query|syntax error at or near|'
    r'sqlite_error|sqlite3?::|unrecognized token|'
    r'sql syntax.*near',
    caseSensitive: false,
  );

  /// Non-destructive, error-based SQL-injection probe. Only existing query
  /// parameters are tested by appending a single quote; the response is scanned
  /// for database error signatures. No data is modified or extracted.
  Future<Map<String, dynamic>> _probeSqlInjection(String url) async {
    try {
      final uri = Uri.parse(url);
      if (uri.queryParameters.isEmpty) {
        return {'checked': true, 'tested': false};
      }
      for (final key in uri.queryParameters.keys) {
        final injected = Map<String, String>.from(uri.queryParameters);
        injected[key] = "${injected[key]}'";
        final testUri = uri.replace(queryParameters: injected);
        final res = await http.get(
          testUri,
          headers: {'User-Agent': 'MRHELPER-SecurityAnalyzer/2.0'},
        ).timeout(const Duration(seconds: 8));
        if (_sqlErrorPattern.hasMatch(res.body)) {
          return {
            'checked': true,
            'tested': true,
            'vulnerable': true,
            'param': key,
          };
        }
      }
      return {'checked': true, 'tested': true, 'vulnerable': false};
    } catch (_) {
      return {'checked': true, 'tested': false};
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

  /// Perform a full security scan on the given URL.
  Future<ScanResult> performScan(String url) async {
    final normalizedUrl = UrlValidator.normalizeUrl(url);

    try {
      return await _runScan(normalizedUrl);
    } catch (e) {
      // Many sites (especially test targets) are HTTP-only. If an HTTPS attempt
      // failed to connect, retry once over HTTP so the scan still succeeds.
      final reachability = _isReachabilityError(e);
      if (reachability && normalizedUrl.startsWith('https://')) {
        final httpUrl = normalizedUrl.replaceFirst('https://', 'http://');
        try {
          return await _runScan(httpUrl);
        } catch (_) {
          // fall through to error mapping below
        }
      }
      throw _mapError(e);
    }
  }

  bool _isReachabilityError(Object e) {
    final m = e.toString();
    return m.contains('TimeoutException') ||
        m.contains('SocketException') ||
        m.contains('HandshakeException') ||
        m.contains('Connection refused') ||
        m.contains('Failed host lookup') ||
        m.contains('ClientException');
  }

  Exception _mapError(Object e) {
    final message = e.toString();
    if (message.contains('TimeoutException')) {
      return Exception(
          'Request timed out. The server may be too slow or unreachable.');
    }
    if (message.contains('SocketException') ||
        message.contains('HandshakeException') ||
        message.contains('Failed host lookup') ||
        message.contains('ClientException')) {
      return Exception(
          'Unable to connect to the server. Please check the URL and try again.');
    }
    return Exception('Scan failed: ${message.replaceAll('Exception: ', '')}');
  }

  /// Runs all probes for [scanUrl] and builds the result. Throws raw errors so
  /// the caller can decide whether to retry (e.g. an HTTP fallback).
  Future<ScanResult> _runScan(String scanUrl) async {
    // On web the browser blocks direct cross-origin reads (CORS), so route
    // through a proxy. On mobile/desktop we hit the target directly.
    final host = Uri.parse(scanUrl).host;

    // DNS (hits Cloudflare) and the TLS cert (its own socket) target DIFFERENT
    // hosts, so they can run alongside the main fetch without competing.
    final dnsFuture = _probeDnsEmail(host);
    final certificateFuture = _inspectCertificateSafe(scanUrl);

    // The MAIN request runs alone against the target host first — hammering a
    // slow site with several parallel probes was causing timeouts.
    final response = await _fetchWithFallback(scanUrl);

    // Now the lighter probes that also hit the target host.
    final discoveryInfo = await _probeDiscovery(scanUrl).catchError((_) => <String, dynamic>{});
    final injectionInfo = await _probeSqlInjection(scanUrl).catchError((_) => <String, dynamic>{});

    // Best-effort: never let a slow DNS/cert probe block the result.
    final certificate = await certificateFuture
        .timeout(const Duration(seconds: 2), onTimeout: () => const {})
        .catchError((_) => <String, dynamic>{});
    final dnsInfo = await dnsFuture
        .timeout(const Duration(seconds: 3), onTimeout: () => const {})
        .catchError((_) => <String, dynamic>{});

    return analyzeHeaders(scanUrl, response.headers,
        certificate: certificate,
        dnsInfo: dnsInfo,
        discoveryInfo: discoveryInfo,
        injectionInfo: injectionInfo);
  }

  /// Analyze response headers and produce a [ScanResult]. Pure logic with no
  /// network I/O — this is what the unit tests exercise. [headers] keys are
  /// expected to be lowercase (as the http package returns them).
  ScanResult analyzeHeaders(
    String normalizedUrl,
    Map<String, String> headers, {
    Map<String, dynamic> certificate = const {},
    Map<String, dynamic> dnsInfo = const {},
    Map<String, dynamic> discoveryInfo = const {},
    Map<String, dynamic> injectionInfo = const {},
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
      dnsInfo: dnsInfo,
      discoveryInfo: discoveryInfo,
      injectionInfo: injectionInfo,
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
      dnsInfo: dnsInfo,
      discoveryInfo: discoveryInfo,
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
    Map<String, dynamic> dnsInfo = const {},
    Map<String, dynamic> discoveryInfo = const {},
    Map<String, dynamic> injectionInfo = const {},
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

    // Permissive CORS — any header value of "*" exposes responses to all sites.
    if (headers['access-control-allow-origin']?.trim() == '*') {
      findings.add(const SecurityFinding(
        title: 'Permissive CORS (Allow-Origin: *)',
        description:
            'Access-Control-Allow-Origin is set to *, allowing any site to read responses.',
        severity: FindingSeverity.medium,
        code: FindingCode.permissiveCors,
        recommendation:
            'Restrict Access-Control-Allow-Origin to trusted origins.',
      ));
    }
    if (!_hasNonEmpty(headers, 'cross-origin-embedder-policy')) {
      findings.add(const SecurityFinding(
        title: 'Missing Cross-Origin-Embedder-Policy (COEP)',
        description:
            'COEP, together with COOP, enables strong cross-origin isolation.',
        severity: FindingSeverity.info,
        code: FindingCode.missingCoep,
        recommendation: 'Consider: Cross-Origin-Embedder-Policy: require-corp.',
      ));
    }

    // DNS / email security findings (only when a DNS probe ran).
    if (dnsInfo['checked'] == true) {
      if (dnsInfo['spf'] != true) {
        findings.add(const SecurityFinding(
          title: 'Missing SPF record',
          description:
              'Without an SPF record, attackers can more easily spoof emails from this domain.',
          severity: FindingSeverity.medium,
          code: FindingCode.missingSpf,
          recommendation:
              'Publish an SPF TXT record, e.g. v=spf1 include:... -all',
        ));
      }
      if (dnsInfo['dmarc'] != true) {
        findings.add(const SecurityFinding(
          title: 'Missing DMARC record',
          description:
              'Without DMARC, there is no policy telling receivers how to handle spoofed mail.',
          severity: FindingSeverity.medium,
          code: FindingCode.missingDmarc,
          recommendation:
              'Publish a _dmarc TXT record with at least p=quarantine.',
        ));
      } else if (dnsInfo['dmarcPolicy'] == 'none') {
        findings.add(const SecurityFinding(
          title: 'Weak DMARC policy (p=none)',
          description:
              'DMARC is set to p=none, which only monitors and does not block spoofed mail.',
          severity: FindingSeverity.low,
          code: FindingCode.weakDmarc,
          recommendation: 'Strengthen DMARC to p=quarantine or p=reject.',
        ));
      }
    }

    // Discovery findings (exposed files are serious; missing security.txt is info).
    if (discoveryInfo['checked'] == true) {
      if (discoveryInfo['exposedGit'] == true) {
        findings.add(const SecurityFinding(
          title: 'Exposed .git repository',
          description:
              'The /.git directory is publicly accessible, which can leak full source code.',
          severity: FindingSeverity.critical,
          code: FindingCode.exposedGit,
          recommendation:
              'Block access to /.git or remove it from the web root.',
        ));
      }
      if (discoveryInfo['exposedEnv'] == true) {
        findings.add(const SecurityFinding(
          title: 'Exposed .env file',
          description:
              'The .env file is publicly accessible and may contain secrets/passwords.',
          severity: FindingSeverity.critical,
          code: FindingCode.exposedEnv,
          recommendation:
              'Remove .env from the web root and rotate any leaked secrets.',
        ));
      }
      if (discoveryInfo['exposedHtaccess'] == true) {
        findings.add(const SecurityFinding(
          title: 'Exposed config file',
          description: 'A server configuration file is publicly accessible.',
          severity: FindingSeverity.high,
          code: FindingCode.exposedConfig,
          recommendation: 'Restrict access to configuration files.',
        ));
      }
      if (discoveryInfo['securityTxt'] != true) {
        findings.add(const SecurityFinding(
          title: 'No security.txt',
          description:
              'No security.txt was found; researchers have no standard way to report issues.',
          severity: FindingSeverity.info,
          code: FindingCode.missingSecurityTxt,
          recommendation:
              'Add a /.well-known/security.txt with contact details.',
        ));
      }
    }

    // SQL injection (error-based) — only when a query parameter was tested.
    if (injectionInfo['vulnerable'] == true) {
      final param = injectionInfo['param'];
      findings.add(SecurityFinding(
        title: 'Possible SQL Injection',
        description:
            'A database error was triggered by an injected quote in the "$param" '
            'parameter, indicating the input is not properly sanitized.',
        severity: FindingSeverity.critical,
        code: FindingCode.sqlInjection,
        param: param,
        recommendation:
            'Use parameterized queries / prepared statements and validate all input.',
      ));
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
