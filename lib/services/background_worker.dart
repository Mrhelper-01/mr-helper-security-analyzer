import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:mr_helper_security_analyzer/services/monitor_service.dart';
import 'package:mr_helper_security_analyzer/services/notification_service.dart';
import 'package:mr_helper_security_analyzer/services/security_scanner_service.dart';

/// MR HELPER - Web Application Security Analyzer
/// WorkManager entry point. Runs in a background isolate, so it re-initializes
/// everything it needs and avoids Firebase (state lives in SharedPreferences).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != MonitorService.taskName) return true;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(MonitorService.kUrl);
      if (url == null || url.isEmpty) return true;

      final lastScore = prefs.getInt(MonitorService.kLastScore) ?? 100;
      final result = await SecurityScannerService().performScan(url);

      // Alert only when security has gotten meaningfully worse.
      if (result.score < lastScore - 2) {
        await NotificationService.init();
        await NotificationService.showAlert(
          id: url.hashCode & 0x7fffffff,
          title: 'Security alert: ${result.displayUrl}',
          body:
              'Score dropped from $lastScore to ${result.score} (${result.risk}).',
        );
      }
      await prefs.setInt(MonitorService.kLastScore, result.score);
      return true;
    } catch (_) {
      // Never crash the worker; try again next cycle.
      return true;
    }
  });
}
