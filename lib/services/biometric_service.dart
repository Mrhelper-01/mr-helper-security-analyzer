import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// MR HELPER - Web Application Security Analyzer
/// Thin wrapper around local_auth for biometric / device-credential unlock.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device can perform any local authentication (biometric OR a
  /// device PIN/pattern/passcode — so phones without a fingerprint sensor,
  /// including iPhones that use Face ID, are still covered).
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// The biometric methods the device offers (face, fingerprint, iris…).
  Future<List<BiometricType>> availableTypes() async {
    if (kIsWeb) return const [];
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
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
