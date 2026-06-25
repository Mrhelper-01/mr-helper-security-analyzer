import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// MR HELPER - Web Application Security Analyzer
/// Manages periodic monitoring of a single website. Uses SharedPreferences for
/// state (no Firebase needed in the background isolate) and WorkManager for the
/// recurring task.
class MonitorService {
  static const taskName = 'mrhelper_periodic_scan';
  static const _uniqueName = 'mrhelper_monitor_task';
  static const kUrl = 'monitor_url';
  static const kLastScore = 'monitor_last_score';

  /// Currently monitored URL, or null if monitoring is off.
  static Future<String?> monitoredUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(kUrl);
    return (u != null && u.isNotEmpty) ? u : null;
  }

  static Future<bool> isMonitoring(String url) async {
    return (await monitoredUrl()) == url;
  }

  /// Start monitoring [url], seeding the baseline [currentScore].
  static Future<void> start(String url, int currentScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUrl, url);
    await prefs.setInt(kLastScore, currentScore);
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      taskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Stop monitoring and cancel the scheduled task.
  static Future<void> stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kUrl);
    await prefs.remove(kLastScore);
    await Workmanager().cancelByUniqueName(_uniqueName);
  }
}
