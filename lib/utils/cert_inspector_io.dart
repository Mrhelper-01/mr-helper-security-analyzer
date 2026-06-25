import 'dart:io';

/// MR HELPER - Web Application Security Analyzer
/// Real TLS certificate inspector (mobile/desktop) using SecureSocket.

/// Connect to [host]:[port] over TLS and return certificate details.
///
/// Strategy: first attempt a normal handshake. If it succeeds, the chain is
/// trusted by the OS → the certificate is valid. If the handshake fails with a
/// bad-certificate error, retry while accepting the certificate so we can still
/// read its details and report exactly why it is invalid.
Future<Map<String, dynamic>> inspectCertificate(String host, int port) async {
  try {
    final socket = await SecureSocket.connect(
      host,
      port,
      timeout: const Duration(seconds: 7),
    ).timeout(const Duration(seconds: 8));
    final result = _describe(socket.peerCertificate, valid: true,
        protocol: socket.selectedProtocol);
    socket.destroy();
    return result;
  } on HandshakeException catch (e) {
    // The certificate is untrusted/expired/mismatched. Reconnect accepting it
    // so we can read the details and surface a precise reason.
    return _inspectUntrusted(host, port, e.message);
  } catch (e) {
    return {'checked': true, 'valid': false, 'error': _short(e)};
  }
}

Future<Map<String, dynamic>> _inspectUntrusted(
    String host, int port, String reason) async {
  try {
    final socket = await SecureSocket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
      onBadCertificate: (_) => true,
    ).timeout(const Duration(seconds: 12));
    final result =
        _describe(socket.peerCertificate, valid: false, error: reason);
    socket.destroy();
    return result;
  } catch (e) {
    return {'checked': true, 'valid': false, 'error': _short(e)};
  }
}

Map<String, dynamic> _describe(
  X509Certificate? cert, {
  required bool valid,
  String? error,
  String? protocol,
}) {
  if (cert == null) {
    return {
      'checked': true,
      'valid': false,
      'error': 'No certificate presented',
    };
  }
  final now = DateTime.now();
  final notBefore = cert.startValidity;
  final notAfter = cert.endValidity;
  final expired = now.isAfter(notAfter);
  final notYetValid = now.isBefore(notBefore);
  final dateValid = !expired && !notYetValid;
  final effectiveValid = valid && dateValid;

  String? effectiveError = error;
  effectiveError ??= expired
      ? 'Certificate expired'
      : (notYetValid ? 'Certificate not yet valid' : null);

  return {
    'checked': true,
    'valid': effectiveValid,
    'issuer': _cn(cert.issuer),
    'subject': _cn(cert.subject),
    'expiresOn': notAfter.toIso8601String(),
    'daysRemaining': notAfter.difference(now).inDays,
    if (protocol != null) 'protocol': protocol,
    if (!effectiveValid && effectiveError != null) 'error': effectiveError,
  };
}

/// Pull a readable name out of a DN string like "CN=R3, O=Let's Encrypt".
String _cn(String dn) {
  final match = RegExp(r'CN=([^,/]+)').firstMatch(dn);
  return (match?.group(1) ?? dn).trim();
}

String _short(Object e) {
  final s = e.toString().replaceAll('Exception: ', '');
  return s.length > 120 ? '${s.substring(0, 117)}...' : s;
}
