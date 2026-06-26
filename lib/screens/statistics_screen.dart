import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';
import 'package:mr_helper_security_analyzer/widgets/section_label.dart';

/// MR HELPER - Web Application Security Analyzer
/// Statistics dashboard with charts and analytics

class StatisticsScreen extends StatefulWidget {
  final bool embedded;
  const StatisticsScreen({super.key, this.embedded = false});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppStrings.of(context).statisticsTitle),
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ScanProvider>().loadStatistics(),
            tooltip: AppStrings.of(context).refresh,
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: Consumer<ScanProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingStats) {
                return _buildLoadingState();
              }
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Summary Cards
                    _buildSummaryCards(provider),
                    const SizedBox(height: 20),
                    // Risk Distribution Chart
                    _buildRiskDistributionChart(provider),
                    const SizedBox(height: 20),
                    // Most Scanned Websites
                    _buildMostScannedWebsites(provider),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSummaryCards(ScanProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.travel_explore_rounded,
            label: AppStrings.of(context).totalScans,
            value: '${provider.totalScans}',
            color: AppColors.neonBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.score_rounded,
            label: AppStrings.of(context).avgScore,
            value: provider.averageScore.toStringAsFixed(1),
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'UniQAIDAR',
              fontSize: 28,
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

  Widget _buildRiskDistributionChart(ScanProvider provider) {
    final distribution = provider.riskDistribution;
    int totalScans = distribution.values.fold(0, (sum, count) => sum + count);

    if (distribution.isEmpty) {
      return GlassmorphismCard(
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: _buildEmptyChart(context),
      );
    }

    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
              text: AppStrings.of(context).riskDistribution,
              icon: Icons.donut_large_rounded),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: _buildPieChartSections(distribution, totalScans),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _buildLegend(context, distribution),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, int> distribution, int total) {
    if (total == 0) return [];

    final colorMap = <String, Color>{
      AppConstants.riskLow: AppColors.riskLowColor,
      AppConstants.riskMedium: AppColors.riskMediumColor,
      AppConstants.riskHigh: AppColors.riskHighColor,
      AppConstants.riskCritical: AppColors.riskCriticalColor,
    };

    return distribution.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colorMap[entry.key] ?? AppColors.textMuted;
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontFamily: 'UniQAIDAR',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(
      BuildContext context, Map<String, int> distribution) {
    final s = AppStrings.of(context);
    final colorMap = <String, Color>{
      AppConstants.riskLow: AppColors.riskLowColor,
      AppConstants.riskMedium: AppColors.riskMediumColor,
      AppConstants.riskHigh: AppColors.riskHighColor,
      AppConstants.riskCritical: AppColors.riskCriticalColor,
    };

    return distribution.entries.map((entry) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorMap[entry.key] ?? AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${s.risk(entry.key)} (${entry.value})',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildEmptyChart(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.pie_chart_outline_rounded,
          size: 48,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.of(context).noRiskData,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMostScannedWebsites(ScanProvider provider) {
    final websites = provider.mostScannedWebsites;

    return GlassmorphismCard(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
              text: AppStrings.of(context).mostScanned,
              icon: Icons.leaderboard_rounded),
          const SizedBox(height: 14),
          if (websites.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  AppStrings.of(context).noScanDataYet,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ...websites.asMap().entries.map((entry) {
            final index = entry.key;
            final site = entry.value;
            final maxCount = websites.first.value;
            final barWidth = maxCount > 0 ? (site.value / maxCount) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${index + 1}. ${site.key}',
                          style: const TextStyle(
                            fontFamily: 'UniQAIDAR',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${site.value}',
                        style: const TextStyle(
                          fontFamily: 'UniQAIDAR',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: barWidth),
                    duration: AppConstants.animationMedium,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.neonCyan,
                            ],
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.65 * value,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
