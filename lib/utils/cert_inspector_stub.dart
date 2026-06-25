/// MR HELPER - Web Application Security Analyzer
/// No-op TLS certificate inspector used on platforms without dart:io (web).
library;

/// Returns an empty map — certificate inspection is unsupported here, so the
/// UI simply omits the certificate section.
Future<Map<String, dynamic>> inspectCertificate(String host, int port) async {
  return const {};
}
