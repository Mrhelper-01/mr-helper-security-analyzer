import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';

/// MR HELPER - Web Application Security Analyzer
/// Advanced layered background: deep gradient base + blurred glowing orbs +
/// a faint grid. Wrap any screen body with this for the Cerebra-style look.
class AuroraBackground extends StatelessWidget {
  final Widget child;

  /// When true, paints brighter hero glows (used on the home/landing surface).
  final bool hero;

  const AuroraBackground({
    super.key,
    required this.child,
    this.hero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base vertical gradient
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B0816),
                  Color(0xFF120C24),
                  Color(0xFF08060F),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        // Faint grid overlay
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter()),
        ),
        // Top-right violet glow
        Positioned(
          top: hero ? -120 : -160,
          right: -120,
          child: _Orb(
            color: AppColors.primary,
            size: hero ? 360 : 300,
            opacity: hero ? 0.45 : 0.28,
          ),
        ),
        // Bottom-left indigo glow
        Positioned(
          bottom: -140,
          left: -130,
          child: _Orb(
            color: const Color(0xFF5B21B6),
            size: hero ? 340 : 280,
            opacity: hero ? 0.40 : 0.24,
          ),
        ),
        // Center subtle cyan accent (hero only)
        if (hero)
          const Positioned(
            top: 120,
            left: -40,
            child: _Orb(
              color: AppColors.neonCyan,
              size: 200,
              opacity: 0.16,
            ),
          ),
        // Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}

/// A soft, heavily-blurred radial glow.
class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Orb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Faint technical grid, reinforcing the cyber aesthetic.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 0.6;
    const gridSize = 34.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
