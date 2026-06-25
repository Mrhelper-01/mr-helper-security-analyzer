import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/models/security_finding.dart';

/// MR HELPER - Web Application Security Analyzer
/// Generates a shareable PDF security report from a [ScanResult].
///
/// English uses crisp vector text. Kurdish (Sorani) is rendered by Flutter's
/// text engine into an image and embedded here, because the pdf package's
/// built-in Arabic shaper does not support Kurdish-specific letters — Flutter
/// does, so the image route guarantees correct joining.
class ReportPdfService {
  static const PdfColor _primary = PdfColor.fromInt(0xFF7C5CFF);
  static const PdfColor _dark = PdfColor.fromInt(0xFF1A1A2E);
  static const PdfColor _muted = PdfColor.fromInt(0xFF666666);

  static String _fileName(ScanResult scan) {
    final safe = scan.displayUrl.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return 'MRHELPER_Security_Report_$safe.pdf';
  }

  /// Build the English vector PDF bytes.
  Future<Uint8List> buildPdf(ScanResult scan, AppStrings s) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _header(s),
        footer: (context) => _footer(context),
        build: (context) => [
          _scoreBlock(scan, s),
          pw.SizedBox(height: 16),
          _targetBlock(scan, s),
          pw.SizedBox(height: 16),
          _headersBlock(scan, s),
          pw.SizedBox(height: 16),
          if (scan.serverInfo.isNotEmpty || scan.certificate['checked'] == true)
            _serverBlock(scan, s),
          if (scan.serverInfo.isNotEmpty || scan.certificate['checked'] == true)
            pw.SizedBox(height: 16),
          _findingsBlock(scan, s),
        ],
      ),
    );
    return doc.save();
  }

  /// Share the English vector report.
  Future<void> sharePdf(ScanResult scan, AppStrings s) async {
    final bytes = await buildPdf(scan, s);
    await Printing.sharePdf(bytes: bytes, filename: _fileName(scan));
  }

  /// Wrap a pre-rendered report image (PNG) into a PDF and share it. Used for
  /// Kurdish, where the content is rasterized by Flutter for correct shaping.
  Future<void> shareImagePdf(
    ScanResult scan,
    Uint8List png,
    int imgWidth,
    int imgHeight,
  ) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(png);
    final pageW = PdfPageFormat.a4.width;
    final pageH = pageW * imgHeight / imgWidth;
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageW, pageH, marginAll: 0),
        build: (context) => pw.Image(image, fit: pw.BoxFit.fitWidth),
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: _fileName(scan));
  }

  // --- Sections -------------------------------------------------------------

  pw.Widget _header(AppStrings s) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MR HELPER',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _dark)),
              pw.Text(s.appTagline,
                  style: const pw.TextStyle(fontSize: 9, color: _muted)),
            ],
          ),
          pw.Text(s.securityReport,
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary)),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(
        'MR HELPER  •  ${context.pageNumber}/${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: _muted),
      ),
    );
  }

  pw.Widget _scoreBlock(ScanResult scan, AppStrings s) {
    final color = _scoreColor(scan.score);
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _statColumn(s.scoreLabel, '${scan.score}/100', color),
          _statColumn(s.gradeLabel, scan.grade, color),
          _statColumn(s.riskLabel, s.risk(scan.risk), color),
          _statColumn(
              s.headersLabel,
              '${scan.presentHeaderCount}/${scan.presentHeaderCount + scan.missingHeaderCount}',
              _dark),
        ],
      ),
    );
  }

  pw.Widget _statColumn(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 15, fontWeight: pw.FontWeight.bold, color: color)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
      ],
    );
  }

  pw.Widget _targetBlock(ScanResult scan, AppStrings s) {
    return _card(s.targetInformation, [
      _kv(s.urlLabel, scan.url),
      _kv(s.domainLabel, scan.displayUrl),
      _kv(s.httpsLabel, scan.https ? s.enabled : s.disabled),
      _kv(s.scannedLabel, scan.formattedDate),
    ]);
  }

  pw.Widget _headersBlock(ScanResult scan, AppStrings s) {
    const names = <String, String>{
      'content-security-policy': 'Content-Security-Policy',
      'strict-transport-security': 'Strict-Transport-Security',
      'x-frame-options': 'X-Frame-Options',
      'x-content-type-options': 'X-Content-Type-Options',
      'referrer-policy': 'Referrer-Policy',
      'permissions-policy': 'Permissions-Policy',
    };
    return _card(s.securityHeadersTitle, [
      for (final entry in names.entries)
        _kv(entry.value,
            (scan.headers[entry.key] ?? false) ? s.present : s.missing,
            valueColor: (scan.headers[entry.key] ?? false)
                ? PdfColors.green700
                : PdfColors.red700),
    ]);
  }

  pw.Widget _serverBlock(ScanResult scan, AppStrings s) {
    final cert = scan.certificate;
    return _card(s.serverCertificate, [
      if (scan.serverInfo['server'] != null)
        _kv(s.serverLabel, '${scan.serverInfo['server']}'),
      if (scan.serverInfo['poweredBy'] != null)
        _kv(s.poweredByLabel, '${scan.serverInfo['poweredBy']}'),
      if (cert['checked'] == true)
        _kv(s.certificateLabel, cert['valid'] == true ? s.valid : s.invalid,
            valueColor: cert['valid'] == true
                ? PdfColors.green700
                : PdfColors.red700),
      if (cert['issuer'] != null) _kv(s.issuerLabel, '${cert['issuer']}'),
      if (cert['daysRemaining'] != null)
        _kv(s.expiresInLabel, s.daysValue(cert['daysRemaining'] as int)),
    ]);
  }

  pw.Widget _findingsBlock(ScanResult scan, AppStrings s) {
    final findings = scan.sortedFindings;
    return _card('${s.findings} (${findings.length})', [
      if (findings.isEmpty)
        pw.Text(s.noIssues,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
      for (final f in findings) _findingRow(f, s),
    ]);
  }

  pw.Widget _findingRow(SecurityFinding f, AppStrings s) {
    final color = _severityColor(f.severity);
    final rec = s.findingRecommendation(f);
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                child: pw.Text(s.severityLabel(f.severity).toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(
                child: pw.Text(s.findingTitle(f),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(s.findingDescription(f),
              style: const pw.TextStyle(fontSize: 9, color: _muted)),
          if (rec != null)
            pw.Text('-> $rec',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.green800)),
        ],
      ),
    );
  }

  // --- Helpers --------------------------------------------------------------

  pw.Widget _card(String title, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary)),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _kv(String key, String value, {PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(key,
                style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: valueColor ?? _dark)),
          ),
        ],
      ),
    );
  }

  PdfColor _scoreColor(int score) {
    if (score >= 80) return PdfColors.green700;
    if (score >= 60) return PdfColors.orange700;
    if (score >= 40) return PdfColors.deepOrange700;
    return PdfColors.red700;
  }

  PdfColor _severityColor(FindingSeverity s) {
    switch (s) {
      case FindingSeverity.critical:
        return PdfColors.red700;
      case FindingSeverity.high:
        return PdfColors.deepOrange700;
      case FindingSeverity.medium:
        return PdfColors.orange700;
      case FindingSeverity.low:
        return PdfColors.blue700;
      case FindingSeverity.info:
        return PdfColors.grey600;
    }
  }
}
