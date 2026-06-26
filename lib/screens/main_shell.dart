import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';
import 'package:mr_helper_security_analyzer/core/routes.dart';
import 'package:mr_helper_security_analyzer/core/app_strings.dart';
import 'package:mr_helper_security_analyzer/screens/home_screen.dart';
import 'package:mr_helper_security_analyzer/screens/history_screen.dart';
import 'package:mr_helper_security_analyzer/screens/statistics_screen.dart';
import 'package:mr_helper_security_analyzer/screens/settings_screen.dart';

/// MR HELPER - Web Application Security Analyzer
/// Main app shell with a persistent bottom navigation bar. The centre item is
/// a Scan action that opens the scanner instead of switching tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Nav index uses 0,1,3,4 — index 2 is the centre "Scan" action.
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    HistoryScreen(embedded: true),
    SizedBox.shrink(), // placeholder for the Scan slot
    StatisticsScreen(embedded: true),
    SettingsScreen(embedded: true),
  ];

  void _onTap(int i) {
    if (i == 2) {
      Navigator.pushNamed(context, AppRoutes.scanner);
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withValues(alpha: 0.97),
          border: Border(
            top: BorderSide(color: AppColors.glassBorder.withValues(alpha: 0.5)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded), label: s.navHome),
            BottomNavigationBarItem(
                icon: const Icon(Icons.history_rounded), label: s.history),
            BottomNavigationBarItem(
                icon: _scanFab(), label: s.navScan),
            BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_rounded), label: s.statistics),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded), label: s.navSettings),
          ],
        ),
      ),
    );
  }

  Widget _scanFab() {
    return Container(
      width: 46,
      height: 46,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF9B7BFF), Color(0xFF6D4FD9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: const Icon(Icons.radar_rounded, color: Colors.white, size: 24),
    );
  }
}
