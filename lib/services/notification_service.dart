import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// MR HELPER - Web Application Security Analyzer
/// Local notifications used to alert when a monitored site's score drops.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'mrhelper_monitor';
  static const _channelName = 'Security Monitoring';

  /// Initialize the plugin and request the Android 13+ permission.
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Show a security alert notification.
  static Future<void> showAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Alerts when a monitored website becomes less secure',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );
    await _plugin.show(
        id: id, title: title, body: body, notificationDetails: details);
  }
}
