import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';

/// MR HELPER - Web Application Security Analyzer
/// Risk level badge widget

class RiskBadge extends StatelessWidget {
  final String risk;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const RiskBadge({
    super.key,
    required this.risk,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.riskToColor(risk);
    final label = AppStrings.of(context).risk(risk);

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSm,
            vertical: AppConstants.paddingXs,
          ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'UniQAIDAR',
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
