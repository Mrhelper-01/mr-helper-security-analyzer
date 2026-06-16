import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';

/// MR HELPER - Web Application Security Analyzer
/// Circular score indicator widget

class ScoreIndicator extends StatelessWidget {
  final int score;
  final String grade;
  final double size;
  final double strokeWidth;

  const ScoreIndicator({
    super.key,
    required this.score,
    required this.grade,
    this.size = 180,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.scoreToColor(score);
    final percentage = score / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: AppColors.backgroundCardLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.backgroundCardLight,
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percentage),
              duration: AppConstants.animationSlow,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grade letter
              AnimatedContainer(
                duration: AppConstants.animationMedium,
                child: Text(
                  grade,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: [
                      Shadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Score number
              Text(
                '$score/100',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
