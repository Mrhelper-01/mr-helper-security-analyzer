import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// MR HELPER - Web Application Security Analyzer
/// Thin wrapper around local_auth for biometric / device-credential unlock.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device can perform any local authentication.
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && (canCheck || await _auth.isDeviceSupported());
    } catch (_) {
      return false;
    }
  }

  /// Prompt the user. Returns true only on a successful authentication.
  Future<bool> authenticate(String reason) async {
    if (kIsWeb) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
