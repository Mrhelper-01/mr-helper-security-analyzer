import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/providers/locale_provider.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';

/// MR HELPER - Web Application Security Analyzer
/// Settings screen with theme toggle, app info, and developer info

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
                // Language Section
                _buildSectionHeader('${AppStrings.of(context).language} / زمان'),
                const SizedBox(height: 12),
                _buildLanguageToggle(),
                const SizedBox(height: 24),
                // App Info Section
                _buildSectionHeader(AppStrings.of(context).application),
                const SizedBox(height: 12),
                _buildAppInfoSection(context),
                const SizedBox(height: 24),
                // Developer Section
                _buildSectionHeader(AppStrings.of(context).developerSection),
                const SizedBox(height: 12),
                _buildDeveloperSection(context),
                const SizedBox(height: 24),
                // Danger Zone
                _buildSectionHeader(AppStrings.of(context).dataSection),
                const SizedBox(height: 12),
                _buildDataSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'UniQAIDAR',
          fontSize: 11,
          color: AppColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final s = localeProvider.strings;
        return GlassmorphismCard(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: AppColors.neonBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.language,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              _langChip(context, localeProvider, AppLang.en, s.english),
              const SizedBox(width: 8),
              _langChip(context, localeProvider, AppLang.ckb, s.kurdish),
            ],
          ),
        );
      },
    );
  }

  Widget _langChip(
    BuildContext context,
    LocaleProvider provider,
    AppLang lang,
    String label,
  ) {
    final selected = provider.lang == lang;
    return GestureDetector(
      onTap: () => provider.setLanguage(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.neonBlue,
            title: s.about,
            subtitle: s.aboutSubtitle,
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.code_rounded,
            iconColor: AppColors.neonPurple,
            title: s.versionLabel,
            subtitle: AppConstants.appVersion,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.success,
            title: s.appPurpose,
            subtitle: s.appPurposeValue,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.primary,
            title: s.developerLabel,
            subtitle: AppConstants.developerName,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.work_outline_rounded,
            iconColor: AppColors.success,
            title: s.roleLabel,
            subtitle: s.developerRoleValue,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.code_rounded,
            iconColor: AppColors.warning,
            title: s.techStackLabel,
            subtitle: 'Flutter, Dart, Firebase',
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.cloud_sync_rounded,
            iconColor: AppColors.neonBlue,
            title: s.firebaseSync,
            subtitle: s.firebaseSyncValue,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.textMuted,
            title: s.privacyLabel,
            subtitle: s.privacyValue,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSm,
        vertical: 2,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      dense: true,
    );
  }
}
