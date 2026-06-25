import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';

/// MR HELPER - Web Application Security Analyzer
/// Security header check tile widget

class HeaderCheckTile extends StatelessWidget {
  final String headerName;
  final bool isPresent;
  final String? description;
  final bool showDivider;

  const HeaderCheckTile({
    super.key,
    required this.headerName,
    required this.isPresent,
    this.description,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSm,
            vertical: AppConstants.paddingSm,
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isPresent ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.22),
                      (isPresent ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(
                    color: (isPresent ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  isPresent
                      ? Icons.check_rounded
                      : Icons.priority_high_rounded,
                  color: isPresent ? AppColors.success : AppColors.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              // Header info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerName,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: (isPresent ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (isPresent ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isPresent ? 'PRESENT' : 'MISSING',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isPresent ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
