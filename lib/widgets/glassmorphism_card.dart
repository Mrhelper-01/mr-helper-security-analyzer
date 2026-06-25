import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';

/// MR HELPER - Web Application Security Analyzer
/// Reusable glassmorphism card widget

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? glassColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.borderColor,
    this.glassColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppConstants.radiusLg),
          child: AnimatedContainer(
            duration: AppConstants.animationFast,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? AppConstants.radiusLg),
              border: Border.all(
                color: borderColor ??
                    AppColors.primaryLight.withValues(alpha: 0.18),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glassColor?.withValues(alpha: 0.16) ??
                      Colors.white.withValues(alpha: 0.06),
                  (glassColor ?? AppColors.primary).withValues(alpha: 0.02),
                ],
              ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 28,
                      spreadRadius: -6,
                      offset: const Offset(0, 12),
                    ),
                  ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? AppConstants.radiusLg),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppConstants.glassBlur,
                  sigmaY: AppConstants.glassBlur,
                ),
                child: Container(
                  padding:
                      padding ?? const EdgeInsets.all(AppConstants.paddingMd),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        borderRadius ?? AppConstants.radiusLg),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (glassColor ?? AppColors.glassBackground)
                            .withValues(alpha: 0.1),
                        (glassColor ?? AppColors.glassBackground)
                            .withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
