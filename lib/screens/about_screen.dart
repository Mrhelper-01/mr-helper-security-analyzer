import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';

/// MR HELPER - Web Application Security Analyzer
/// About screen with developer info and app description

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT'),
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
              children: [
                const SizedBox(height: 20),
                // App Logo / Icon
                _buildAppLogo(),
                const SizedBox(height: 24),
                // App Name
                _buildAppName(),
                const SizedBox(height: 32),
                // Developer Card
                _buildDeveloperCard(),
                const SizedBox(height: 20),
                // Description Card
                _buildDescriptionCard(),
                const SizedBox(height: 20),
                // Features Card
                _buildFeaturesCard(),
                const SizedBox(height: 20),
                // Technical Details
                _buildTechDetailsCard(),
                const SizedBox(height: 32),
                // Footer
                _buildFooter(),
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
            fontFamily: 'JetBrainsMono',
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
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              color: AppColors.neonBlue,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard() {
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
                  fontFamily: 'JetBrainsMono',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.developerName,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Flutter Developer',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    color: AppColors.neonBlue,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cybersecurity Enthusiast',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
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

  Widget _buildDescriptionCard() {
    return const GlassmorphismCard(
      padding: EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 18, color: AppColors.neonBlue),
              SizedBox(width: 8),
              Text(
                'DESCRIPTION',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            AppConstants.appDescription,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_outline_rounded,
                  size: 18, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'KEY FEATURES',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
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
            'Security Header Analysis',
            'Check CSP, HSTS, X-Frame-Options and more',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.cookie_outlined,
            'Cookie Security Audit',
            'Analyze Secure, HttpOnly, and SameSite flags',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.score_rounded,
            'Security Scoring Engine',
            '0-100 score with letter grades A through F',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.analytics_rounded,
            'Risk Classification',
            'Low, Medium, High, and Critical risk levels',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.cloud_sync_rounded,
            'Cloud History',
            'All scans stored securely in Firebase Firestore',
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

  Widget _buildTechDetailsCard() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.code_rounded, size: 18, color: AppColors.neonPurple),
              SizedBox(width: 8),
              Text(
                'TECHNICAL DETAILS',
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
          _buildDetailRow('Framework', 'Flutter (Dart)'),
          _buildDetailRow('Backend', 'Firebase Firestore'),
          _buildDetailRow('State Management', 'Provider'),
          _buildDetailRow('Architecture', 'Clean Architecture'),
          _buildDetailRow('Charts', 'fl_chart'),
          _buildDetailRow('HTTP Client', 'http package'),
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
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Made with ❤️ by ${AppConstants.developerName}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© ${DateTime.now().year} All Rights Reserved',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
