import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/stats_card.dart';
import 'package:mr_helper_security_analyzer/widgets/risk_badge.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';
import 'package:mr_helper_security_analyzer/widgets/gradient_button.dart';
import 'package:mr_helper_security_analyzer/widgets/section_label.dart';

/// MR HELPER - Web Application Security Analyzer
/// Home dashboard with stats, quick actions, and recent scans

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ چاکسازی: بانگکردنی داتاکان دوای تەواوبوونی build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final scanProvider = context.read<ScanProvider>();
    scanProvider.loadStatistics();
    scanProvider.loadScanHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        hero: true,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Header
                _buildHeader(),
                const SizedBox(height: 28),
                // Hero scan CTA
                _buildScanButton(),
                const SizedBox(height: 28),
                // Stats section
                _buildStatsSection(),
                const SizedBox(height: 24),
                // Recent scans
                _buildRecentScansSection(),
                const SizedBox(height: 24),
                // Quick actions
                _buildQuickActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MR HELPER',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: AppColors.neonBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.of(context).appTagline,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: AppColors.neonBlue,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              icon: Icons.bar_chart_rounded,
              onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.settings_rounded,
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundCardLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    final s = AppStrings.of(context);
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        children: [
          // Glowing shield emblem
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.35),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_moon_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // Two-tone hero heading
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                height: 1.25,
              ),
              children: [
                TextSpan(
                  text: 'SECURED BY\n',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'INNOVATION',
                  style: TextStyle(color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.enterUrlToAnalyze,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: s.startSecurityScan,
            icon: Icons.security_rounded,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: SectionLabel(text: AppStrings.of(context).overview)),
                if (provider.isLoadingStats)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    label: AppStrings.of(context).totalScans,
                    value: provider.isLoadingStats
                        ? '...'
                        : '${provider.totalScans}',
                    icon: Icons.travel_explore,
                    color: AppColors.neonBlue,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.history),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    label: AppStrings.of(context).avgScore,
                    value: provider.isLoadingStats
                        ? '...'
                        // ignore: unnecessary_string_interpolations
                        : '${provider.averageScore.toStringAsFixed(1)}',
                    icon: Icons.score_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentScansSection() {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: SectionLabel(
                        text: AppStrings.of(context).recentScans)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                  child: Text(
                    AppStrings.of(context).viewAll,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: AppColors.neonBlue,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isLoadingHistory)
              ...List.generate(3, (_) => _buildShimmerCard()),
            if (!provider.isLoadingHistory && provider.scanHistory.isEmpty)
              _buildEmptyState(),
            if (!provider.isLoadingHistory && provider.scanHistory.isNotEmpty)
              ...provider.scanHistory.take(3).map(
                    (scan) => _buildRecentScanItem(scan),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildRecentScanItem(dynamic scan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
      child: GlassmorphismCard(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.report,
          arguments: {'scanResult': scan},
        ),
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.scoreToColor(scan.score).withValues(alpha: 0.1),
                border: Border.all(
                  color:
                      AppTheme.scoreToColor(scan.score).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${scan.score}',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.scoreToColor(scan.score),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // URL and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.displayUrl,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.formattedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Risk badge
            RiskBadge(risk: scan.risk),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.of(context).noScansYet,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.of(context).startFirstScan,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: AppStrings.of(context).quickActions),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history_rounded,
                label: AppStrings.of(context).history,
                color: AppColors.neonPurple,
                onTap: () => Navigator.pushNamed(context, AppRoutes.history),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_rounded,
                label: AppStrings.of(context).statistics,
                color: AppColors.neonGreen,
                onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.info_outline_rounded,
                label: AppStrings.of(context).about,
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 0.5,
          ),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
