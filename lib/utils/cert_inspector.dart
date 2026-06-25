/// MR HELPER - Web Application Security Analyzer
/// Conditional facade for TLS certificate inspection.
///
/// On platforms with dart:io (mobile/desktop) this resolves to the real
/// SecureSocket-based implementation; on web it resolves to a no-op stub so
/// the web build still compiles.
library;

export 'cert_inspector_stub.dart'
    if (dart.library.io) 'cert_inspector_io.dart';
