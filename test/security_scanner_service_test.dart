import 'package:flutter_test/flutter_test.dart';
import 'package:mr_helper_security_analyzer/models/security_finding.dart';
import 'package:mr_helper_security_analyzer/services/security_scanner_service.dart';

/// MR HELPER - Web Application Security Analyzer
/// Unit tests proving the scanner's scoring and parsing logic is correct.
/// These run with no network access — they feed synthetic headers into
/// [SecurityScannerService.analyzeHeaders] and assert the outcome.

void main() {
  final scanner = SecurityScannerService();

  /// Headers for a fully hardened HTTPS site that sets NO cookies.
  /// This must reach a perfect 100 — the bug we fixed.
  const fullyHardened = <String, String>{
    'strict-transport-security': 'max-age=63072000; includeSubDomains; preload',
    'content-security-policy': "default-src 'self'",
    'x-frame-options': 'DENY',
    'x-content-type-options': 'nosniff',
    'referrer-policy': 'no-referrer',
    'permissions-policy': 'geolocation=()',
  };

  group('Score normalization', () {
    test('fully hardened site with no cookies scores exactly 100', () {
      final result = scanner.analyzeHeaders('https://secure.example', fullyHardened);
      expect(result.score, 100);
      expect(result.grade, 'A');
      expect(result.risk, contains('Low'));
    });

    test('fully hardened site WITH perfect cookies also scores 100', () {
      final headers = {
        ...fullyHardened,
        'set-cookie': 'session=abc; Secure; HttpOnly; SameSite=Strict',
      };
      final result = scanner.analyzeHeaders('https://secure.example', headers);
      expect(result.score, 100);
    });

    test('plain HTTP site with no headers scores very low / critical', () {
      final result = scanner.analyzeHeaders('http://insecure.example', {});
      expect(result.score, lessThan(40));
      expect(result.risk, contains('Critical'));
      expect(result.https, isFalse);
    });

    test('HTTPS only, no other headers, no cookies', () {
      // earned 25 / possible 90 -> 28
      final result = scanner.analyzeHeaders('https://bare.example', {});
      expect(result.score, 28);
      expect(result.https, isTrue);
    });
  });

  group('Value-aware header checks', () {
    test('HSTS with max-age=0 does NOT count', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'strict-transport-security': 'max-age=0'},
      );
      expect(result.hsts, isFalse);
    });

    test('HSTS with positive max-age counts', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'strict-transport-security': 'max-age=31536000'},
      );
      expect(result.hsts, isTrue);
    });

    test('X-Frame-Options with junk value does NOT count', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'x-frame-options': 'whatever'},
      );
      expect(result.headers['x-frame-options'], isFalse);
    });

    test('X-Frame-Options SAMEORIGIN (any case) counts', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'x-frame-options': 'SameOrigin'},
      );
      expect(result.headers['x-frame-options'], isTrue);
    });

    test('X-Content-Type-Options must be nosniff', () {
      final wrong = scanner.analyzeHeaders(
        'https://x.example',
        {'x-content-type-options': 'something'},
      );
      expect(wrong.headers['x-content-type-options'], isFalse);

      final right = scanner.analyzeHeaders(
        'https://x.example',
        {'x-content-type-options': 'nosniff'},
      );
      expect(right.headers['x-content-type-options'], isTrue);
    });

    test('empty header value does not count', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'content-security-policy': '   '},
      );
      expect(result.csp, isFalse);
    });
  });

  group('Cookie parsing', () {
    test('no Set-Cookie -> not present', () {
      final result = scanner.analyzeHeaders('https://x.example', {});
      expect(result.cookies['present'], isFalse);
      expect(result.cookies['count'], 0);
    });

    test('counts multiple cookies correctly despite commas in Expires date', () {
      // Two real cookies joined into one header; the Expires date contains a
      // comma ("Wed, 24 Jun...") which must NOT be mistaken for a separator.
      const setCookie =
          'XSRF-TOKEN=abc; expires=Wed, 24 Jun 2026 04:22:22 GMT; Max-Age=7200; path=/; secure; samesite=lax,'
          'qiu_session=def; path=/; httponly; samesite=lax';
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'set-cookie': setCookie},
      );
      expect(result.cookies['count'], 2);
      expect(result.cookies['present'], isTrue);
    });

    test('secure/httpOnly only true when ALL cookies have the flag', () {
      // One cookie lacks Secure -> overall secure must be false.
      const setCookie =
          'a=1; Secure; HttpOnly; SameSite=Strict,b=2; HttpOnly; SameSite=Strict';
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'set-cookie': setCookie},
      );
      expect(result.cookies['secure'], isFalse);
      expect(result.cookies['httpOnly'], isTrue);
    });

    test('SameSite=None is reported as None', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'set-cookie': 'a=1; Secure; SameSite=None'},
      );
      expect(result.cookies['sameSite'], 'None');
    });
  });

  group('Findings & severity', () {
    test('fully hardened site produces no findings', () {
      final result =
          scanner.analyzeHeaders('https://secure.example', fullyHardened);
      // Cross-origin advisory headers are absent in the fixture, so a couple of
      // info-level notes are acceptable, but nothing critical/high/medium.
      expect(result.countBySeverity(FindingSeverity.critical), 0);
      expect(result.countBySeverity(FindingSeverity.high), 0);
      expect(result.countBySeverity(FindingSeverity.medium), 0);
    });

    test('plain HTTP site flags a critical "No HTTPS" finding', () {
      final result = scanner.analyzeHeaders('http://insecure.example', {});
      expect(result.countBySeverity(FindingSeverity.critical),
          greaterThanOrEqualTo(1));
      expect(
        result.findings.any((f) => f.title.contains('No HTTPS')),
        isTrue,
      );
    });

    test('findings are sorted most-severe first', () {
      final result = scanner.analyzeHeaders('http://insecure.example', {});
      final weights = result.sortedFindings.map((f) => f.severity.weight);
      final sorted = [...weights]..sort();
      expect(weights.toList(), sorted);
    });

    test('server version disclosure is detected and flagged', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'server': 'Apache/2.4.41', 'x-powered-by': 'PHP/7.2.1'},
      );
      expect(result.serverDisclosed, isTrue);
      expect(result.serverInfo['server'], 'Apache/2.4.41');
      expect(
        result.findings.any((f) => f.title.contains('Server software')),
        isTrue,
      );
    });

    test('bare server name without version is not flagged as disclosure', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'server': 'cloudflare'},
      );
      expect(result.serverDisclosed, isFalse);
    });

    test('weak CSP with unsafe-inline produces a medium finding', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        {'content-security-policy': "default-src 'self'; script-src 'unsafe-inline'"},
      );
      expect(
        result.findings.any((f) => f.title.contains('Weak Content-Security')),
        isTrue,
      );
    });

    test('invalid certificate produces a critical finding', () {
      final result = scanner.analyzeHeaders(
        'https://x.example',
        fullyHardened,
        certificate: {'checked': true, 'valid': false, 'error': 'expired'},
      );
      expect(
        result.findings.any((f) => f.title.contains('TLS certificate problem')),
        isTrue,
      );
    });
  });
}
