/// MR HELPER - Web Application Security Analyzer
/// Utility functions for URL validation and formatting
library;

class UrlValidator {
  UrlValidator._();

  /// Validate URL format
  static String? validateUrl(String url) {
    if (url.isEmpty) {
      return 'Please enter a URL';
    }

    final trimmedUrl = url.trim();

    // Add https:// if no protocol is specified
    String processedUrl = trimmedUrl;
    if (!trimmedUrl.startsWith('http://') &&
        !trimmedUrl.startsWith('https://')) {
      processedUrl = 'https://$trimmedUrl';
    }

    final uri = Uri.tryParse(processedUrl);
    if (uri == null || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }

    // Check for common TLDs or at least a dot in the host
    final host = uri.host;
    if (!host.contains('.')) {
      return 'Please enter a complete domain (e.g., example.com)';
    }

    return null; // Valid
  }

  /// Normalize URL (ensure https:// prefix, trim, etc.)
  static String normalizeUrl(String url) {
    final trimmedUrl = url.trim();
    if (!trimmedUrl.startsWith('http://') &&
        !trimmedUrl.startsWith('https://')) {
      return 'https://$trimmedUrl';
    }
    return trimmedUrl;
  }

  /// Extract hostname from URL
  static String extractHostname(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasAuthority) {
      return uri.host;
    }
    return url;
  }

  /// Check if URL uses HTTPS
  static bool isHttps(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https';
  }

  /// Get display-friendly URL (remove protocol, trailing slashes)
  static String displayUrl(String url) {
    return url
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
  }
}
