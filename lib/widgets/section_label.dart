import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';

/// MR HELPER - Web Application Security Analyzer
/// Section heading with a small gradient accent bar (Cerebra-style).
class SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Widget? trailing;

  const SectionLabel({
    super.key,
    required this.text,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (icon != null) ...[
          Icon(icon, size: 15, color: AppColors.primaryLight),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'UniQAIDAR',
            fontSize: 11,
            color: AppColors.textSecondary,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}
