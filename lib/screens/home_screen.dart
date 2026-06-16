import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/stats_card.dart';
import 'package:mr_helper_security_analyzer/widgets/risk_badge.dart';

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
                // Header
                _buildHeader(),
                const SizedBox(height: 24),
                // Scan button
                _buildScanButton(),
                const SizedBox(height: 24),
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
            const Text(
              'Web Security Analyzer',
              style: TextStyle(
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
    return GlassmorphismCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.scanner),
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonBlue.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonBlue.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.security_rounded,
              size: 32,
              color: AppColors.neonBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'START SECURITY SCAN',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a URL to analyze its security posture',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
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
                const Text(
                  'OVERVIEW',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
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
                    label: 'Total Scans',
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
                    label: 'Avg Score',
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
                const Text(
                  'RECENT SCANS',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
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
          const Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start your first security scan!',
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
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 13,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history_rounded,
                label: 'History',
                color: AppColors.neonPurple,
                onTap: () => Navigator.pushNamed(context, AppRoutes.history),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_rounded,
                label: 'Statistics',
                color: AppColors.neonGreen,
                onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.info_outline_rounded,
                label: 'About',
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
