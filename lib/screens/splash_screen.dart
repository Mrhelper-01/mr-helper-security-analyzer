import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/widgets/app_logo.dart';

/// MR HELPER - Web Application Security Analyzer
/// Animated splash screen with cybersecurity theme

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationSlow * 2,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Navigate to home after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              Color(0xFF0A1628),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background grid
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
            // Neon glow orbs
            Positioned(
              top: -100,
              right: -100,
              child: _buildGlowOrb(
                color: AppColors.neonBlue,
                size: 300,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: _buildGlowOrb(
                color: AppColors.neonPurple,
                size: 250,
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ لۆگۆی نوێی MR HELPER
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: const AppLogo(
                        size: 130,
                        showText: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'MR HELPER',
                          style: TextStyle(
                            fontFamily: 'UniQAIDAR',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: AppColors.neonBlue.withAlpha(128),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.neonBlue.withAlpha(76),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppStrings.of(context).webSecurityAnalyzerCaps,
                            style: const TextStyle(
                              fontFamily: 'UniQAIDAR',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neonBlue,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Sliding tagline
                  SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      AppStrings.of(context).securingTheWeb,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withAlpha(179),
                        letterSpacing: 1,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom loading indicator
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.neonBlue.withAlpha(128),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.of(context).initializing,
                      style: const TextStyle(
                        fontFamily: 'UniQAIDAR',
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowOrb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha(38),
            color.withAlpha(13),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Grid painter for background effect
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonBlue.withAlpha(8)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
