import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/screens/splash_screen.dart';
import 'package:mr_helper_security_analyzer/screens/home_screen.dart';
import 'package:mr_helper_security_analyzer/screens/scanner_screen.dart';
import 'package:mr_helper_security_analyzer/screens/history_screen.dart';
import 'package:mr_helper_security_analyzer/screens/report_screen.dart';
import 'package:mr_helper_security_analyzer/screens/statistics_screen.dart';
import 'package:mr_helper_security_analyzer/screens/settings_screen.dart';
import 'package:mr_helper_security_analyzer/screens/about_screen.dart';
import 'package:mr_helper_security_analyzer/screens/dns_email_screen.dart';

/// MR HELPER - Web Application Security Analyzer
/// Application routing system

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String scanner = '/scanner';
  static const String history = '/history';
  static const String report = '/report';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String dnsEmail = '/dns-email';

  static Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: routeSettings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: routeSettings,
        );
      case scanner:
        return MaterialPageRoute(
          builder: (_) => const ScannerScreen(),
          settings: routeSettings,
        );
      case history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: routeSettings,
        );
      case report:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReportScreen(
            scanResult: args?['scanResult'],
          ),
          settings: routeSettings,
        );
      case statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: routeSettings,
        );
      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
          settings: routeSettings,
        );
      case dnsEmail:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DnsEmailScreen(
            scanResult: args!['scanResult'],
          ),
          settings: routeSettings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}


