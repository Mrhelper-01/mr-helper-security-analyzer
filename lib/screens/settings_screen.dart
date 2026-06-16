import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/providers/theme_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';

/// MR HELPER - Web Application Security Analyzer
/// Settings screen with theme toggle, app info, and developer info

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
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
                // Appearance Section
                _buildSectionHeader('APPEARANCE'),
                const SizedBox(height: 12),
                _buildThemeToggle(),
                const SizedBox(height: 24),
                // App Info Section
                _buildSectionHeader('APPLICATION'),
                const SizedBox(height: 12),
                _buildAppInfoSection(context),
                const SizedBox(height: 24),
                // Developer Section
                _buildSectionHeader('DEVELOPER'),
                const SizedBox(height: 12),
                _buildDeveloperSection(context),
                const SizedBox(height: 24),
                // Danger Zone
                _buildSectionHeader('DATA'),
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
          fontFamily: 'JetBrainsMono',
          fontSize: 11,
          color: AppColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return GlassmorphismCard(
          padding: const EdgeInsets.all(AppConstants.paddingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: const Icon(
                  Icons.dark_mode_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Toggle dark theme',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.neonBlue,
            title: 'About',
            subtitle: 'App information and version',
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.code_rounded,
            iconColor: AppColors.neonPurple,
            title: 'Version',
            subtitle: AppConstants.appVersion,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.success,
            title: 'App Purpose',
            subtitle: 'Web Security Analysis Tool',
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.primary,
            title: 'Developer',
            subtitle: AppConstants.developerName,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.work_outline_rounded,
            iconColor: AppColors.success,
            title: 'Role',
            subtitle: AppConstants.developerRole,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.code_rounded,
            iconColor: AppColors.warning,
            title: 'Tech Stack',
            subtitle: 'Flutter, Dart, Firebase',
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.cloud_sync_rounded,
            iconColor: AppColors.neonBlue,
            title: 'Firebase Sync',
            subtitle: 'Data stored in Firebase Firestore',
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.textMuted,
            title: 'Privacy',
            subtitle: 'Only scanned URLs are stored',
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
