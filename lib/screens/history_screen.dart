import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/providers/locale_provider.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/risk_badge.dart';
import 'package:mr_helper_security_analyzer/widgets/aurora_background.dart';

/// MR HELPER - Web Application Security Analyzer
/// Scan history screen with list, sort, and delete functionality

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().loadScanHistory();
    });
  }

  Future<void> _confirmDelete(String id, String url) async {
    final s = context.read<LocaleProvider>().strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteScanTitle),
        content: Text(s.deleteScanConfirm(url)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(s.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ScanProvider>().deleteScan(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.scanDeleted),
              backgroundColor: AppColors.success.withValues(alpha: 0.3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${s.failedDelete}: $e'),
              backgroundColor: AppColors.error.withValues(alpha: 0.3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).scanHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<ScanProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                ),
                onPressed: () => provider.toggleSortOrder(),
                tooltip: AppStrings.of(context).sortByDate,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ScanProvider>().loadScanHistory(),
            tooltip: AppStrings.of(context).refresh,
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: Consumer<ScanProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingHistory) {
                return _buildLoadingState();
              }

              if (provider.historyError != null) {
                return _buildErrorState(provider.historyError!);
              }

              if (provider.scanHistory.isEmpty) {
                return _buildEmptyState();
              }

              return _buildHistoryList(provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingSm),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLg),
        child: GlassmorphismCard(
          padding: const EdgeInsets.all(AppConstants.paddingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.of(context).failedLoadHistory,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.read<ScanProvider>().loadScanHistory(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(AppStrings.of(context).retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(AppConstants.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).noScanHistory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context).historyWillAppear,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
              icon: const Icon(Icons.security_rounded, size: 18),
              label: Text(AppStrings.of(context).startAScan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(ScanProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMd),
      itemCount: provider.scanHistory.length,
      itemBuilder: (context, index) {
        final scan = provider.scanHistory[index];
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
                // Score indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.scoreToColor(scan.score)
                        .withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.scoreToColor(scan.score)
                          .withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${scan.score}',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 16,
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
                // Grade and risk
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          scan.grade,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.scoreToColor(scan.score),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _confirmDelete(scan.id!, scan.url),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RiskBadge(risk: scan.risk, fontSize: 9),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
