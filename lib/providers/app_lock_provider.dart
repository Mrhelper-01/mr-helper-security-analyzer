import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mr_helper_security_analyzer/services/biometric_service.dart';

/// MR HELPER - Web Application Security Analyzer
/// Holds the app-lock (biometric) preference and exposes auth helpers.
class AppLockProvider extends ChangeNotifier {
  static const _kEnabled = 'app_lock_enabled';

  final BiometricService _biometric = BiometricService();
  bool _enabled = false;
  bool _available = false;
  bool _hasFace = false;
  bool _hasFingerprint = false;

  bool get enabled => _enabled;
  bool get available => _available;

  /// True when the device supports face recognition (e.g. Face ID).
  bool get hasFace => _hasFace;

  /// True when the device has a fingerprint sensor.
  bool get hasFingerprint => _hasFingerprint;

  /// Load the saved preference and device capability at startup.
  Future<void> load() async {
    _available = await _biometric.isAvailable();
    final types = await _biometric.availableTypes();
    _hasFace = types.contains(BiometricType.face);
    _hasFingerprint = types.contains(BiometricType.fingerprint);
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;
    notifyListeners();
  }

  /// Toggle the lock. Turning it ON requires a successful auth first.
  /// Returns true if the new state was applied.
  Future<bool> setEnabled(bool value, String reason) async {
    if (value) {
      final ok = await _biometric.authenticate(reason);
      if (!ok) return false;
    }
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
    notifyListeners();
    return true;
  }

  /// Require auth before a protected action. Always true when lock is off.
  Future<bool> requireAuth(String reason) async {
    if (!_enabled) return true;
    return _biometric.authenticate(reason);
  }
}
