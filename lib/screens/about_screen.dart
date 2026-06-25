import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';

/// MR HELPER - Web Application Security Analyzer
/// About screen with developer info and app description

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).aboutTitle),
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
              children: [
                const SizedBox(height: 20),
                // App Logo / Icon
                _buildAppLogo(),
                const SizedBox(height: 24),
                // App Name
                _buildAppName(),
                const SizedBox(height: 32),
                // Developer Card
                _buildDeveloperCard(context),
                const SizedBox(height: 20),
                // Description Card
                _buildDescriptionCard(context),
                const SizedBox(height: 20),
                // Features Card
                _buildFeaturesCard(context),
                const SizedBox(height: 20),
                // Technical Details
                _buildTechDetailsCard(context),
                const SizedBox(height: 32),
                // Footer
                _buildFooter(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF111827),
          ],
        ),
      ),
      child: const Icon(
        Icons.shield_rounded,
        size: 50,
        color: AppColors.neonBlue,
      ),
    );
  }

  Widget _buildAppName() {
    return Column(
      children: [
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontFamily: 'UniQAIDAR',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: AppColors.neonBlue.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.neonBlue.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'v${AppConstants.appVersion}',
            style: TextStyle(
              fontFamily: 'UniQAIDAR',
              fontSize: 12,
              color: AppColors.neonBlue,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Row(
        children: [
          // Developer avatar
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.neonBlue, AppColors.neonPurple],
              ),
            ),
            child: const Center(
              child: Text(
                'MH',
                style: TextStyle(
                  fontFamily: 'UniQAIDAR',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.developerName,
                  style: TextStyle(
                    fontFamily: 'UniQAIDAR',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.flutterDeveloper,
                  style: const TextStyle(
                    fontFamily: 'UniQAIDAR',
                    fontSize: 12,
                    color: AppColors.neonBlue,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.cyberEnthusiast,
                  style: const TextStyle(
                    fontFamily: 'UniQAIDAR',
                    fontSize: 11,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined,
                  size: 18, color: AppColors.neonBlue),
              const SizedBox(width: 8),
              Text(
                s.descriptionTitle,
                style: const TextStyle(
                  fontFamily: 'UniQAIDAR',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            s.appDescriptionText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                s.keyFeatures,
                style: const TextStyle(
                  fontFamily: 'UniQAIDAR',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.security_rounded,
            s.featureHeadersTitle,
            s.featureHeadersDesc,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.cookie_outlined,
            s.featureCookieTitle,
            s.featureCookieDesc,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.score_rounded,
            s.featureScoreTitle,
            s.featureScoreDesc,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.analytics_rounded,
            s.featureRiskTitle,
            s.featureRiskDesc,
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.cloud_sync_rounded,
            s.featureCloudTitle,
            s.featureCloudDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechDetailsCard(BuildContext context) {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded,
                  size: 18, color: AppColors.neonPurple),
              const SizedBox(width: 8),
              Text(
                s.technicalDetails,
                style: const TextStyle(
                  fontFamily: 'UniQAIDAR',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(s.frameworkLabel, 'Flutter (Dart)'),
          _buildDetailRow(s.backendLabel, 'Firebase Firestore'),
          _buildDetailRow(s.stateMgmtLabel, 'Provider'),
          _buildDetailRow(s.architectureLabel, s.cleanArchitecture),
          _buildDetailRow(s.chartsLabel, 'fl_chart'),
          _buildDetailRow(s.httpClientLabel, 'http package'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'UniQAIDAR',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      children: [
        Text(
          s.madeWith(AppConstants.developerName),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© ${DateTime.now().year} ${s.allRightsReserved}',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
