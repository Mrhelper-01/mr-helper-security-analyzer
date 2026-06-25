import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/providers/locale_provider.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/models/security_finding.dart';
import 'package:mr_helper_security_analyzer/services/report_pdf_service.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';
import 'package:mr_helper_security_analyzer/widgets/score_indicator.dart';
import 'package:mr_helper_security_analyzer/widgets/risk_badge.dart';
import 'package:mr_helper_security_analyzer/widgets/header_check_tile.dart';

/// MR HELPER - Web Application Security Analyzer
/// Detailed security report screen with full breakdown

class ReportScreen extends StatelessWidget {
  final ScanResult? scanResult;

  const ReportScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    final scan = scanResult;
    if (scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('REPORT')),
        body: const Center(child: Text('No scan data available')),
      );
    }

    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.securityReport),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: s.shareReport,
            onPressed: () => _sharePdf(context, scan),
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Score & Grade Section
                _buildScoreSection(scan, s),
                const SizedBox(height: 20),
                // URL & Risk Info
                _buildUrlInfoSection(scan, s),
                const SizedBox(height: 20),
                // Security Headers
                _buildHeadersSection(scan, s),
                const SizedBox(height: 20),
                // Cookie Analysis
                _buildCookieSection(scan, s),
                const SizedBox(height: 20),
                // Server / certificate info
                _buildServerSection(scan, s),
                // Summary
                _buildSummarySection(scan, s),
                const SizedBox(height: 20),
                // Findings (severity-ranked)
                _buildFindingsSection(scan, s),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context, ScanResult scan) async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = context.read<LocaleProvider>().strings;
    messenger.showSnackBar(
      SnackBar(
        content: Text(strings.generatingPdf),
        duration: const Duration(seconds: 1),
      ),
    );
    try {
      await ReportPdfService().sharePdf(scan);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not generate PDF: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildScoreSection(ScanResult scan, AppStrings s) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        children: [
          Text(
            s.securityScore,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          ScoreIndicator(
            score: scan.score,
            grade: scan.grade,
            size: 160,
          ),
          const SizedBox(height: 16),
          RiskBadge(risk: scan.risk, fontSize: 14),
        ],
      ),
    );
  }

  Widget _buildUrlInfoSection(ScanResult scan, AppStrings s) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.targetInformation,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(s.urlLabel, scan.url, Icons.link_rounded),
          const SizedBox(height: 8),
          _buildInfoRow(s.domainLabel, scan.displayUrl, Icons.language_rounded),
          const SizedBox(height: 8),
          _buildInfoRow(s.httpsLabel, scan.https ? s.enabled : s.disabled,
              scan.https ? Icons.lock_rounded : Icons.lock_open_rounded,
              valueColor: scan.https ? AppColors.success : AppColors.error),
          if (scan.timestamp != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                s.scannedLabel, scan.formattedDate, Icons.access_time_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadersSection(ScanResult scan, AppStrings s) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.securityHeadersTitle,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${scan.presentHeaderCount}/${scan.presentHeaderCount + scan.missingHeaderCount}',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildHeaderStatus(
              'Content-Security-Policy',
              scan.headers['content-security-policy'] ?? false,
              s.cspDesc),
          _buildHeaderStatus(
              'Strict-Transport-Security',
              scan.headers['strict-transport-security'] ?? false,
              s.hstsDesc),
          _buildHeaderStatus('X-Frame-Options',
              scan.headers['x-frame-options'] ?? false, s.xFrameDesc),
          _buildHeaderStatus(
              'X-Content-Type-Options',
              scan.headers['x-content-type-options'] ?? false,
              s.xContentDesc),
          _buildHeaderStatus('Referrer-Policy',
              scan.headers['referrer-policy'] ?? false, s.referrerDesc),
          _buildHeaderStatus('Permissions-Policy',
              scan.headers['permissions-policy'] ?? false, s.permissionsDesc),
        ],
      ),
    );
  }

  Widget _buildHeaderStatus(String name, bool present, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: HeaderCheckTile(
        headerName: name,
        isPresent: present,
        description: description,
        showDivider: true,
      ),
    );
  }

  Widget _buildCookieSection(ScanResult scan, AppStrings s) {
    final cookies = scan.cookies;
    final hasCookies = cookies['present'] == true;
    final secure = cookies['secure'] == true;
    final httpOnly = cookies['httpOnly'] == true;
    final sameSite = cookies['sameSite'] ?? 'None';
    final count = cookies['count'] ?? 0;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.cookieAnalysis,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _buildCookieStatus(
            s.cookiesPresent,
            hasCookies,
            hasCookies ? s.cookiesFound(count as int) : s.noCookiesDetected,
          ),
          const Divider(height: 1),
          _buildCookieStatus(
            s.secureFlag,
            secure,
            secure ? s.cookiesHttpsOnly : s.missingSecureFlag,
          ),
          const Divider(height: 1),
          _buildCookieStatus(
            s.httpOnlyFlag,
            httpOnly,
            httpOnly ? s.cookiesNoJs : s.missingHttpOnly,
          ),
          const Divider(height: 1),
          _buildSameSiteStatus(sameSite, s),
        ],
      ),
    );
  }

  Widget _buildCookieStatus(String label, bool isSecure, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isSecure ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
              isSecure ? Icons.check_circle : Icons.cancel,
              color: isSecure ? AppColors.success : AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSameSiteStatus(String sameSite, AppStrings s) {
    final isGood = sameSite == 'Lax' || sameSite == 'Strict';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: AppConstants.paddingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isGood ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
              isGood ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isGood ? AppColors.success : AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.sameSitePolicy,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'SameSite=$sameSite',
                  style: TextStyle(
                    fontSize: 11,
                    color: isGood ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ScanResult scan, AppStrings s) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.summary,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryItem(
                s.gradeLabel,
                scan.grade,
                AppTheme.scoreToColor(scan.score),
              ),
              _buildSummaryItem(
                s.scoreLabel,
                '${scan.score}/100',
                AppTheme.scoreToColor(scan.score),
              ),
              _buildSummaryItem(
                s.riskLabel,
                s.risk(scan.risk),
                AppTheme.riskToColor(scan.risk),
              ),
              _buildSummaryItem(
                s.headersLabel,
                '${scan.presentHeaderCount}/${scan.presentHeaderCount + scan.missingHeaderCount}',
                scan.hasMissingHeaders ? AppColors.warning : AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Server software & TLS certificate card. Hidden when nothing to show.
  Widget _buildServerSection(ScanResult scan, AppStrings s) {
    final cert = scan.certificate;
    final hasCert = cert['checked'] == true;
    final hasServer = scan.serverInfo.isNotEmpty;
    if (!hasCert && !hasServer) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassmorphismCard(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.serverCertificate,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              if (scan.serverInfo['server'] != null)
                _buildInfoRow(s.serverLabel, '${scan.serverInfo['server']}',
                    Icons.dns_rounded),
              if (scan.serverInfo['poweredBy'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(s.poweredByLabel,
                    '${scan.serverInfo['poweredBy']}', Icons.memory_rounded),
              ],
              if (hasCert) ...[
                if (scan.serverInfo.isNotEmpty) const SizedBox(height: 8),
                _buildInfoRow(
                  s.certificateLabel,
                  cert['valid'] == true ? s.valid : s.invalid,
                  cert['valid'] == true
                      ? Icons.verified_user_rounded
                      : Icons.gpp_bad_rounded,
                  valueColor:
                      cert['valid'] == true ? AppColors.success : AppColors.error,
                ),
                if (cert['issuer'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      s.issuerLabel, '${cert['issuer']}', Icons.business_rounded),
                ],
                if (cert['daysRemaining'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    s.expiresInLabel,
                    s.daysValue(cert['daysRemaining'] as int),
                    Icons.event_rounded,
                    valueColor: (cert['daysRemaining'] as int) <= 15
                        ? AppColors.warning
                        : Colors.white,
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Color _severityColor(FindingSeverity s) {
    switch (s) {
      case FindingSeverity.critical:
        return AppColors.riskCriticalColor;
      case FindingSeverity.high:
        return AppColors.riskHighColor;
      case FindingSeverity.medium:
        return AppColors.warning;
      case FindingSeverity.low:
        return AppColors.primary;
      case FindingSeverity.info:
        return AppColors.textMuted;
    }
  }

  Widget _buildFindingsSection(ScanResult scan, AppStrings s) {
    final findings = scan.sortedFindings;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                s.findings,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s.issueCount(findings.length),
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (findings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.noIssues,
                      style: const TextStyle(
                          color: AppColors.success, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ...findings.map(_buildFindingTile),
        ],
      ),
    );
  }

  Widget _buildFindingTile(SecurityFinding finding) {
    final color = _severityColor(finding.severity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  finding.severity.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  finding.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              finding.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (finding.recommendation != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right_rounded,
                    size: 16, color: AppColors.success),
                Expanded(
                  child: Text(
                    finding.recommendation!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
