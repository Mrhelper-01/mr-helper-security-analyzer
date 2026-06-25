import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/theme.dart';

/// MR HELPER - Web Application Security Analyzer
/// Animated circular score gauge with a glowing gradient arc.

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
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.scoreToColor(score);
    final percentage = (score / 100.0).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: percentage),
        duration: AppConstants.animationSlow,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow halo
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25 * value),
                      blurRadius: 34,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Gradient arc
              CustomPaint(
                size: Size(size, size),
                painter: _GaugePainter(
                  progress: value,
                  color: color,
                  strokeWidth: strokeWidth,
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    grade,
                    style: TextStyle(
                      fontFamily: 'UniQAIDAR',
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1,
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(value * 100).round()}/100',
                    style: TextStyle(
                      fontFamily: 'UniQAIDAR',
                      fontSize: size * 0.1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.backgroundCardLight.withValues(alpha: 0.7);
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: [
        color.withValues(alpha: 0.55),
        color,
        AppColors.primaryLight,
      ],
      stops: const [0.0, 0.6, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);
    canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}
