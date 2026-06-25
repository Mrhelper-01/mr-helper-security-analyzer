import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/section_label.dart';

/// MR HELPER - Web Application Security Analyzer
/// Dedicated DNS & email-security detail page.
class DnsEmailScreen extends StatelessWidget {
  final ScanResult scanResult;

  const DnsEmailScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final dns = scanResult.dnsInfo;

    final spf = dns['spf'] == true;
    final dkim = dns['dkim'] == true;
    final dmarc = dns['dmarc'] == true;
    final emailProtected = spf && dmarc;
    final wellConfigured =
        spf && dmarc && (dns['nsRecord'] != null || dns['aRecord'] != null);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(s.dnsEmailTitle, style: const TextStyle(fontSize: 16)),
            Text(
              scanResult.displayUrl,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(s),
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: dns['checked'] != true
              ? Center(
                  child: Text(s.notFoundLabel,
                      style: const TextStyle(color: AppColors.textMuted)))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.paddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _dnsConfigCard(s, dns, wellConfigured),
                      const SizedBox(height: 24),
                      SectionLabel(
                          text: s.emailSecurity,
                          icon: Icons.mark_email_read_rounded),
                      const SizedBox(height: 12),
                      _emailCheck(s.spfFull, spf ? s.validSpf : s.noSpf, spf, s),
                      const SizedBox(height: 10),
                      _emailCheck(
                          s.dkimFull, dkim ? s.validDkim : s.noDkim, dkim, s),
                      const SizedBox(height: 10),
                      _emailCheck(
                        s.dmarcFull,
                        dmarc ? s.validDmarc : s.noDmarc,
                        dmarc,
                        s,
                        extra: dmarc && dns['dmarcPolicy'] != null
                            ? s.policyLine('${dns['dmarcPolicy']}')
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _protectionBanner(s, emailProtected),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _share(AppStrings s) {
    final dns = scanResult.dnsInfo;
    final lines = [
      '${s.dnsEmailTitle} — ${scanResult.displayUrl}',
      'SPF: ${dns['spf'] == true ? s.pass : s.fail}',
      'DKIM: ${dns['dkim'] == true ? s.pass : s.fail}',
      'DMARC: ${dns['dmarc'] == true ? s.pass : s.fail}'
          '${dns['dmarcPolicy'] != null ? ' (p=${dns['dmarcPolicy']})' : ''}',
      '— MR HELPER',
    ];
    Share.share(lines.join('\n'));
  }

  // --- DNS configuration card ----------------------------------------------
  Widget _dnsConfigCard(
      AppStrings s, Map<String, dynamic> dns, bool wellConfigured) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.dnsConfiguration,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      wellConfigured ? s.wellConfigured : s.issuesFound,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: wellConfigured
                              ? AppColors.success
                              : AppColors.warning),
                    ),
                  ],
                ),
              ),
              Icon(Icons.dns_rounded,
                  color: AppColors.primary.withValues(alpha: 0.8), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          _recordRow(s.aRecord, dns['aRecord']),
          _recordRow(s.mxRecord, dns['mxRecord']),
          _recordRow(s.nsRecord, dns['nsRecord']),
          _recordRow(s.txtRecord, dns['txtRecord'], last: true),
        ],
      ),
    );
  }

  Widget _recordRow(String label, dynamic value, {bool last = false}) {
    final has = value != null && '$value'.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(
                    color: AppColors.glassBorder.withValues(alpha: 0.4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              has ? '$value' : '—',
              style: const TextStyle(
                  fontFamily: 'UniQAIDAR',
                  fontSize: 12,
                  color: AppColors.textSecondary),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            has ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
            size: 20,
            color: has ? AppColors.success : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  // --- Email security check rows -------------------------------------------
  Widget _emailCheck(String title, String subtitle, bool pass, AppStrings s,
      {String? extra}) {
    final color = pass ? AppColors.success : AppColors.error;
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3)),
                const SizedBox(height: 4),
                Text(extra ?? subtitle,
                    style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Text(
              pass ? s.pass : s.fail,
              style: TextStyle(
                  fontFamily: 'UniQAIDAR',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  // --- Bottom protection banner --------------------------------------------
  Widget _protectionBanner(AppStrings s, bool protectedDomain) {
    final color = protectedDomain ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
                protectedDomain ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                color: color,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              protectedDomain ? s.domainProtected : s.domainNotProtected,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
