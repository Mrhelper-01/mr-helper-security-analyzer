import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/providers/scan_provider.dart';
import 'package:mr_helper_security_analyzer/widgets/glassmorphism_card.dart';
import 'package:mr_helper_security_analyzer/widgets/risk_badge.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scan'),
        content: Text('Are you sure you want to delete the scan for\n$url?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('DELETE'),
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
              content: const Text('Scan deleted successfully'),
              backgroundColor: AppColors.success.withValues(alpha: 0.3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
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
        title: const Text('SCAN HISTORY'),
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
                tooltip: 'Sort by date',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ScanProvider>().loadScanHistory(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
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
              const Text(
                'Failed to Load History',
                style: TextStyle(
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
                label: const Text('RETRY'),
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
            const Text(
              'No Scan History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your security scan results will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.scanner),
              icon: const Icon(Icons.security_rounded, size: 18),
              label: const Text('START A SCAN'),
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
