import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/models/security_finding.dart';

/// MR HELPER - Web Application Security Analyzer
/// A white, print-friendly rendering of the report. Rendered by Flutter's
/// text engine (full Kurdish/Arabic shaping) and captured to an image for PDF.
class PrintableReport extends StatelessWidget {
  final ScanResult scan;
  final AppStrings s;
  final double width;

  const PrintableReport({
    super.key,
    required this.scan,
    required this.s,
    this.width = 760,
  });

  static const _primary = Color(0xFF6D4FD9);
  static const _ink = Color(0xFF1A1A2E);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: s.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: width,
        color: Colors.white,
        padding: const EdgeInsets.all(28),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'UniQAIDAR',
            color: _ink,
            fontSize: 13,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              const SizedBox(height: 18),
              _scoreRow(),
              const SizedBox(height: 18),
              _card(s.targetInformation, [
                _kv(s.urlLabel, scan.url),
                _kv(s.domainLabel, scan.displayUrl),
                _kv(s.httpsLabel, scan.https ? s.enabled : s.disabled),
                _kv(s.scannedLabel, scan.formattedDate),
              ]),
              const SizedBox(height: 14),
              _headersCard(),
              if (scan.serverInfo.isNotEmpty ||
                  scan.certificate['checked'] == true) ...[
                const SizedBox(height: 14),
                _serverCard(),
              ],
              const SizedBox(height: 14),
              _findingsCard(),
              const SizedBox(height: 16),
              Center(
                child: Text('MR HELPER  •  ${s.appTagline}',
                    style: const TextStyle(fontSize: 10, color: _muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _primary, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MR HELPER',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _ink)),
              Text(s.appTagline,
                  style: const TextStyle(fontSize: 10, color: _muted)),
            ],
          ),
          Text(s.securityReport,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: _primary)),
        ],
      ),
    );
  }

  Widget _scoreRow() {
    final color = AppTheme.scoreToColor(scan.score);
    final total = scan.presentHeaderCount + scan.missingHeaderCount;
    Widget stat(String label, String value, Color c) => Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: c)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
          ],
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          stat(s.scoreLabel, '${scan.score}/100', color),
          stat(s.gradeLabel, scan.grade, color),
          stat(s.riskLabel, s.risk(scan.risk), color),
          stat(s.headersLabel, '${scan.presentHeaderCount}/$total', _ink),
        ],
      ),
    );
  }

  Widget _headersCard() {
    const names = <String, String>{
      'content-security-policy': 'Content-Security-Policy',
      'strict-transport-security': 'Strict-Transport-Security',
      'x-frame-options': 'X-Frame-Options',
      'x-content-type-options': 'X-Content-Type-Options',
      'referrer-policy': 'Referrer-Policy',
      'permissions-policy': 'Permissions-Policy',
    };
    return _card(s.securityHeadersTitle, [
      for (final e in names.entries)
        _kv(e.value, (scan.headers[e.key] ?? false) ? s.present : s.missing,
            valueColor: (scan.headers[e.key] ?? false)
                ? const Color(0xFF15803D)
                : const Color(0xFFB91C1C)),
    ]);
  }

  Widget _serverCard() {
    final cert = scan.certificate;
    return _card(s.serverCertificate, [
      if (scan.serverInfo['server'] != null)
        _kv(s.serverLabel, '${scan.serverInfo['server']}'),
      if (scan.serverInfo['poweredBy'] != null)
        _kv(s.poweredByLabel, '${scan.serverInfo['poweredBy']}'),
      if (cert['checked'] == true)
        _kv(s.certificateLabel, cert['valid'] == true ? s.valid : s.invalid,
            valueColor: cert['valid'] == true
                ? const Color(0xFF15803D)
                : const Color(0xFFB91C1C)),
      if (cert['issuer'] != null) _kv(s.issuerLabel, '${cert['issuer']}'),
      if (cert['daysRemaining'] != null)
        _kv(s.expiresInLabel, s.daysValue(cert['daysRemaining'] as int)),
    ]);
  }

  Widget _findingsCard() {
    final findings = scan.sortedFindings;
    return _card('${s.findings} (${findings.length})', [
      if (findings.isEmpty)
        Text(s.noIssues,
            style: const TextStyle(fontSize: 12, color: Color(0xFF15803D))),
      for (final f in findings) _findingRow(f),
    ]);
  }

  Widget _findingRow(SecurityFinding f) {
    final color = _severityColor(f.severity);
    final rec = s.findingRecommendation(f);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: BorderDirectional(
          start: BorderSide(color: color, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(s.severityLabel(f.severity),
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.findingTitle(f),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(s.findingDescription(f),
              style: const TextStyle(fontSize: 11, color: _muted, height: 1.4)),
          if (rec != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('‹  $rec',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF15803D), height: 1.4)),
            ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(key,
                style: const TextStyle(fontSize: 11, color: _muted)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? _ink)),
          ),
        ],
      ),
    );
  }

  Color _severityColor(FindingSeverity sev) {
    switch (sev) {
      case FindingSeverity.critical:
        return const Color(0xFFDC2626);
      case FindingSeverity.high:
        return const Color(0xFFEA580C);
      case FindingSeverity.medium:
        return const Color(0xFFD97706);
      case FindingSeverity.low:
        return const Color(0xFF2563EB);
      case FindingSeverity.info:
        return const Color(0xFF6B7280);
    }
  }
}
