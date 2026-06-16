import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SECURITY REPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Score & Grade Section
                _buildScoreSection(scan),
                const SizedBox(height: 20),
                // URL & Risk Info
                _buildUrlInfoSection(scan),
                const SizedBox(height: 20),
                // Security Headers
                _buildHeadersSection(scan),
                const SizedBox(height: 20),
                // Cookie Analysis
                _buildCookieSection(scan),
                const SizedBox(height: 20),
                // Summary
                _buildSummarySection(scan),
                const SizedBox(height: 20),
                // Recommendations
                _buildRecommendations(scan),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(ScanResult scan) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        children: [
          const Text(
            'SECURITY SCORE',
            style: TextStyle(
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

  Widget _buildUrlInfoSection(ScanResult scan) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TARGET INFORMATION',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('URL', scan.url, Icons.link_rounded),
          const SizedBox(height: 8),
          _buildInfoRow('Domain', scan.displayUrl, Icons.language_rounded),
          const SizedBox(height: 8),
          _buildInfoRow('HTTPS', scan.https ? 'Enabled' : 'Disabled',
              scan.https ? Icons.lock_rounded : Icons.lock_open_rounded,
              valueColor: scan.https ? AppColors.success : AppColors.error),
          if (scan.timestamp != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                'Scanned', scan.formattedDate, Icons.access_time_rounded),
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

  Widget _buildHeadersSection(ScanResult scan) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SECURITY HEADERS',
                style: TextStyle(
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
              'Controls resources the browser is allowed to load'),
          _buildHeaderStatus(
              'Strict-Transport-Security',
              scan.headers['strict-transport-security'] ?? false,
              'Forces HTTPS connections'),
          _buildHeaderStatus(
              'X-Frame-Options',
              scan.headers['x-frame-options'] ?? false,
              'Prevents clickjacking attacks'),
          _buildHeaderStatus(
              'X-Content-Type-Options',
              scan.headers['x-content-type-options'] ?? false,
              'Prevents MIME type sniffing'),
          _buildHeaderStatus(
              'Referrer-Policy',
              scan.headers['referrer-policy'] ?? false,
              'Controls referrer information'),
          _buildHeaderStatus(
              'Permissions-Policy',
              scan.headers['permissions-policy'] ?? false,
              'Controls browser features'),
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

  Widget _buildCookieSection(ScanResult scan) {
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
          const Text(
            'COOKIE ANALYSIS',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          _buildCookieStatus(
            'Cookies Present',
            hasCookies,
            hasCookies ? '$count cookie(s) found' : 'No cookies detected',
          ),
          const Divider(height: 1),
          _buildCookieStatus(
            'Secure Flag',
            secure,
            secure ? 'Cookies sent over HTTPS only' : 'Missing Secure flag',
          ),
          const Divider(height: 1),
          _buildCookieStatus(
            'HttpOnly Flag',
            httpOnly,
            httpOnly
                ? 'Cookies not accessible via JavaScript'
                : 'Missing HttpOnly flag',
          ),
          const Divider(height: 1),
          _buildSameSiteStatus(sameSite),
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

  Widget _buildSameSiteStatus(String sameSite) {
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
                const Text(
                  'SameSite Policy',
                  style: TextStyle(
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

  Widget _buildSummarySection(ScanResult scan) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUMMARY',
            style: TextStyle(
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
                'Grade',
                scan.grade,
                AppTheme.scoreToColor(scan.score),
              ),
              _buildSummaryItem(
                'Score',
                '${scan.score}/100',
                AppTheme.scoreToColor(scan.score),
              ),
              _buildSummaryItem(
                'Risk',
                scan.risk,
                AppTheme.riskToColor(scan.risk),
              ),
              _buildSummaryItem(
                'Headers',
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

  Widget _buildRecommendations(ScanResult scan) {
    final recommendations = <String>[];

    if (!scan.https) {
      recommendations.add(
          'Enable HTTPS using a valid SSL/TLS certificate to encrypt all data in transit.');
    }
    if (!scan.hsts) {
      recommendations.add(
          'Implement Strict-Transport-Security header to enforce HTTPS connections.');
    }
    if (!scan.csp) {
      recommendations.add(
          'Add Content-Security-Policy header to prevent XSS and data injection attacks.');
    }
    if (!(scan.headers['x-frame-options'] ?? false)) {
      recommendations.add(
          'Set X-Frame-Options header to DENY or SAMEORIGIN to prevent clickjacking.');
    }
    if (!(scan.headers['x-content-type-options'] ?? false)) {
      recommendations.add(
          'Enable X-Content-Type-Options: nosniff to prevent MIME type sniffing.');
    }
    if (!(scan.headers['referrer-policy'] ?? false)) {
      recommendations.add(
          'Configure Referrer-Policy header to control information leakage via referrer headers.');
    }
    if (!(scan.headers['permissions-policy'] ?? false)) {
      recommendations.add(
          'Implement Permissions-Policy header to restrict browser feature access.');
    }

    final cookies = scan.cookies;
    if (cookies['present'] == true) {
      if (cookies['secure'] != true) {
        recommendations.add(
            'Add the Secure flag to all cookies to ensure they are only sent over HTTPS.');
      }
      if (cookies['httpOnly'] != true) {
        recommendations.add(
            'Add the HttpOnly flag to cookies to prevent client-side script access.');
      }
      if (cookies['sameSite'] == 'None') {
        recommendations.add(
            'Set SameSite attribute (Lax or Strict) on cookies to prevent CSRF attacks.');
      }
    }

    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'RECOMMENDATIONS',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recommendations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Excellent! Your website has strong security posture.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
