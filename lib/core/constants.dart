import 'package:flutter/material.dart';

/// MR HELPER - Web Application Security Analyzer
/// Core constants used throughout the application

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MR HELPER';
  static const String appTagline = 'Web Security Analyzer';
  static const String appVersion = '2.0.0';
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
  static const Duration requestTimeout = Duration(seconds: 30);

  // TLS certificate inspection timeout (kept short so it never stalls a scan)
  static const Duration certTimeout = Duration(seconds: 8);

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

  // Primary Colors — Cerebra-style violet
  static const Color primary = Color(0xFF8B6DFF);
  static const Color primaryDark = Color(0xFF6D4FD9);
  static const Color primaryLight = Color(0xFFB8A4FF);

  // 🌙 Dark Mode Background Colors — deep purple-black
  static const Color backgroundDark = Color(0xFF0A0814);
  static const Color backgroundCard = Color(0xFF14111F);
  static const Color backgroundCardLight = Color(0xFF1E1A30);

  // ☀️ Light Mode Background Colors (زیادکراو)
  static const Color backgroundLight = Color(0xFFF4F2FB);
  static const Color backgroundCardLightMode = Color(0xFFFFFFFF);
  static const Color backgroundCardLightAlt = Color(0xFFF0EEF8);
  static const Color surfaceLight = Color(0xFFE9E5F6);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF0F0C1C);

  // Neon Accents
  static const Color neonBlue = Color(0xFF8B6DFF);
  static const Color neonCyan = Color(0xFF38BDF8);
  static const Color neonPurple = Color(0xFF7C3AED);
  static const Color neonPink = Color(0xFFE05AFF);
  static const Color neonGreen = Color(0xFF34D399);

  // Status Colors
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF43F5E);
  static const Color info = Color(0xFF8B6DFF);

  // Risk Colors
  static const Color riskLowColor = Color(0xFF34D399);
  static const Color riskMediumColor = Color(0xFFFBBF24);
  static const Color riskHighColor = Color(0xFFFB923C);
  static const Color riskCriticalColor = Color(0xFFF43F5E);

  // Grade Colors
  static const Color gradeAColor = Color(0xFF34D399);
  static const Color gradeBColor = Color(0xFF8B6DFF);
  static const Color gradeCColor = Color(0xFFFBBF24);
  static const Color gradeDColor = Color(0xFFFB923C);
  static const Color gradeFColor = Color(0xFFF43F5E);

  // 🌙 Dark Mode Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // ☀️ Light Mode Text Colors (زیادکراو)
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textMutedLight = Color(0xFF999999);

  // Glassmorphism — subtle violet-tinted borders
  static const Color glassBorder = Color(0x33A78BFA);
  static const Color glassBorderLight = Color(0x33000000); // بۆ Light Mode
  static const Color glassBackground = Color(0x14B8A4FF);
  static const Color glassBackgroundLight = Color(0x1A000000); // بۆ Light Mode

  // 🌙 Dark Mode Shimmer
  static const Color shimmerBase = Color(0xFF1E1A30);
  static const Color shimmerHighlight = Color(0xFF2C2545);

  // ☀️ Light Mode Shimmer (زیادکراو)
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
}
