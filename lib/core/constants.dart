import 'package:flutter/material.dart';

/// MR HELPER - Web Application Security Analyzer
/// Core constants used throughout the application

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MR HELPER';
  static const String appTagline = 'Web Security Analyzer';
  static const String appVersion = '1.0.0';
  static const String developerName = 'MR HELPER';
  static const String developerRole =
      'Flutter Developer & Cybersecurity Enthusiast';
  static const String appDescription =
      'A professional mobile cybersecurity tool that analyzes website security '
      'headers, checks for vulnerabilities, and provides actionable security recommendations.';

  // Firestore Collections
  static const String scansCollection = 'scans';

  // Firestore Fields
  static const String fieldUrl = 'url';
  static const String fieldScore = 'score';
  static const String fieldRisk = 'risk';
  static const String fieldHttps = 'https';
  static const String fieldHsts = 'hsts';
  static const String fieldCsp = 'csp';
  static const String fieldHeaders = 'headers';
  static const String fieldCookies = 'cookies';
  static const String fieldTimestamp = 'timestamp';

  // Security Score Weights
  static const int scoreHttps = 20;
  static const int scoreHsts = 15;
  static const int scoreCsp = 15;
  static const int scoreXFrameOptions = 10;
  static const int scoreXContentTypeOptions = 10;
  static const int scoreReferrerPolicy = 10;
  static const int scorePermissionsPolicy = 10;
  static const int scoreSecureCookies = 10;

  // Grade Thresholds
  static const int gradeA = 90;
  static const int gradeB = 80;
  static const int gradeC = 70;
  static const int gradeD = 60;

  // Risk Levels
  static const String riskLow = 'Low Risk';
  static const String riskMedium = 'Medium Risk';
  static const String riskHigh = 'High Risk';
  static const String riskCritical = 'Critical Risk';

  // API Timeout
  static const Duration requestTimeout = Duration(seconds: 15);

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 600);
  static const Duration animationSlow = Duration(milliseconds: 1000);

  // URLs
  static const String githubUrl = 'https://github.com/mrhelper';
  static const String portfolioUrl = 'https://mrhelper.dev';

  // Padding
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Glassmorphism
  static const double glassOpacity = 0.15;
  static const double glassBlur = 10.0;
}

/// Neon color palette for cybersecurity theme
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryDark = Color(0xFF0099CC);
  static const Color primaryLight = Color(0xFF66E5FF);

  // 🌙 Dark Mode Background Colors
  static const Color backgroundDark = Color(0xFF0A0E1A);
  static const Color backgroundCard = Color(0xFF111827);
  static const Color backgroundCardLight = Color(0xFF1A2235);

  // ☀️ Light Mode Background Colors (زیادکراو)
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundCardLightMode = Color(0xFFFFFFFF);
  static const Color backgroundCardLightAlt = Color(0xFFF0F2F5);
  static const Color surfaceLight = Color(0xFFE8ECF4);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF0F1524);

  // Neon Accents
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonCyan = Color(0xFF00FFE0);
  static const Color neonPurple = Color(0xFF7C3AED);
  static const Color neonPink = Color(0xFFFF0080);
  static const Color neonGreen = Color(0xFF00FF88);

  // Status Colors
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF3366);
  static const Color info = Color(0xFF00D4FF);

  // Risk Colors
  static const Color riskLowColor = Color(0xFF00FF88);
  static const Color riskMediumColor = Color(0xFFFFB800);
  static const Color riskHighColor = Color(0xFFFF6600);
  static const Color riskCriticalColor = Color(0xFFFF0033);

  // Grade Colors
  static const Color gradeAColor = Color(0xFF00FF88);
  static const Color gradeBColor = Color(0xFF00D4FF);
  static const Color gradeCColor = Color(0xFFFFB800);
  static const Color gradeDColor = Color(0xFFFF6600);
  static const Color gradeFColor = Color(0xFFFF0033);

  // 🌙 Dark Mode Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // ☀️ Light Mode Text Colors (زیادکراو)
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textMutedLight = Color(0xFF999999);

  // Glassmorphism
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x33000000); // بۆ Light Mode
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBackgroundLight = Color(0x1A000000); // بۆ Light Mode

  // 🌙 Dark Mode Shimmer
  static const Color shimmerBase = Color(0xFF1A2235);
  static const Color shimmerHighlight = Color(0xFF2A3A4A);

  // ☀️ Light Mode Shimmer (زیادکراو)
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
}
