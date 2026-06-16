import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/utils/validators.dart';

/// MR HELPER - Web Application Security Analyzer
/// Service for performing website security scans

class SecurityScannerService {
  /// Perform a full security scan on the given URL
  Future<ScanResult> performScan(String url) async {
    final normalizedUrl = UrlValidator.normalizeUrl(url);

    try {
      // Make HTTP request to get headers
      final response = await http.get(
        Uri.parse(normalizedUrl),
        headers: {
          'User-Agent': 'MRHELPER-SecurityAnalyzer/1.0',
        },
      ).timeout(AppConstants.requestTimeout);

      // Extract security headers
      final headers = response.headers;
      final httpsEnabled = UrlValidator.isHttps(normalizedUrl);

      // Check specific security headers
      final hsts = headers.containsKey('strict-transport-security');
      final csp = headers.containsKey('content-security-policy');
      final xFrameOptions = headers.containsKey('x-frame-options');
      final xContentTypeOptions = headers.containsKey('x-content-type-options');
      final referrerPolicy = headers.containsKey('referrer-policy');
      final permissionsPolicy = headers.containsKey('permissions-policy');

      // Build headers map
      final headersMap = <String, bool>{
        'strict-transport-security': hsts,
        'content-security-policy': csp,
        'x-frame-options': xFrameOptions,
        'x-content-type-options': xContentTypeOptions,
        'referrer-policy': referrerPolicy,
        'permissions-policy': permissionsPolicy,
      };

      // Check cookies
      final cookies = await _analyzeCookies(normalizedUrl);

      // Calculate security score
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

      // Determine risk level
      final risk = _classifyRisk(score);

      return ScanResult(
        url: normalizedUrl,
        score: score,
        risk: risk,
        https: httpsEnabled,
        hsts: hsts,
        csp: csp,
        headers: headersMap,
        cookies: cookies,
        timestamp: DateTime.now(),
      );
    } on SocketException {
      throw Exception(
          'Unable to connect to the server. Please check the URL and try again.');
    } on http.ClientException {
      throw Exception(
          'Network error occurred. Please check your internet connection.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Request timed out. The server may be too slow or unreachable.');
      }
      throw Exception('Scan failed: ${e.toString()}');
    }
  }

  /// Analyze cookies from Set-Cookie headers
  Future<Map<String, dynamic>> _analyzeCookies(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'MRHELPER-SecurityAnalyzer/1.0',
        },
      ).timeout(AppConstants.requestTimeout);

      final setCookieHeaders = response.headers['set-cookie'] ?? '';
      if (setCookieHeaders.isEmpty) {
        return {
          'present': false,
          'secure': false,
          'httpOnly': false,
          'sameSite': 'None',
          'count': 0,
        };
      }

      // Parse cookie attributes
      final cookies = setCookieHeaders.split(',').map((c) => c.trim()).toList();
      bool hasSecure = false;
      bool hasHttpOnly = false;
      String sameSite = 'None';

      for (final cookie in cookies) {
        if (cookie.toLowerCase().contains('secure')) hasSecure = true;
        if (cookie.toLowerCase().contains('httponly')) hasHttpOnly = true;
        if (cookie.toLowerCase().contains('samesite=lax')) sameSite = 'Lax';
        if (cookie.toLowerCase().contains('samesite=strict')) {
          sameSite = 'Strict';
        }
      }

      return {
        'present': true,
        'secure': hasSecure,
        'httpOnly': hasHttpOnly,
        'sameSite': sameSite,
        'count': cookies.length,
      };
    } catch (e) {
      return {
        'present': false,
        'secure': false,
        'httpOnly': false,
        'sameSite': 'None',
        'count': 0,
      };
    }
  }

  /// Calculate security score based on present headers
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
    int score = 0;

    // Positive scoring
    if (https) score += AppConstants.scoreHttps;
    if (hsts) score += AppConstants.scoreHsts;
    if (csp) score += AppConstants.scoreCsp;
    if (xFrameOptions) score += AppConstants.scoreXFrameOptions;
    if (xContentTypeOptions) score += AppConstants.scoreXContentTypeOptions;
    if (referrerPolicy) score += AppConstants.scoreReferrerPolicy;
    if (permissionsPolicy) score += AppConstants.scorePermissionsPolicy;

    // Cookie security scoring
    if (cookies['present'] == true) {
      if (cookies['secure'] == true) score += 5;
      if (cookies['httpOnly'] == true) score += 5;
      if (cookies['sameSite'] == 'Lax' || cookies['sameSite'] == 'Strict') {
        score += 5;
      }
    }

    // Deductions for missing headers (if HTTPS is used)
    if (https) {
      if (!hsts) score -= 5;
      if (!csp) score -= 5;
      if (!xFrameOptions) score -= 3;
      if (!xContentTypeOptions) score -= 3;
      if (!referrerPolicy) score -= 2;
      if (!permissionsPolicy) score -= 2;
    }

    // Clamp score between 0 and 100
    return score.clamp(0, 100);
  }

  /// Classify risk level based on score
  String _classifyRisk(int score) {
    if (score >= 80) return AppConstants.riskLow;
    if (score >= 60) return AppConstants.riskMedium;
    if (score >= 40) return AppConstants.riskHigh;
    return AppConstants.riskCritical;
  }
}
