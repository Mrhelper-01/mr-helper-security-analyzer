import 'package:cloud_firestore/cloud_firestore.dart';

/// MR HELPER - Web Application Security Analyzer
/// Model representing a security scan result

class ScanResult {
  final String? id;
  final String url;
  final int score;
  final String risk;
  final bool https;
  final bool hsts;
  final bool csp;
  final Map<String, bool> headers;
  final Map<String, dynamic> cookies;
  final DateTime? timestamp;

  ScanResult({
    this.id,
    required this.url,
    required this.score,
    required this.risk,
    required this.https,
    required this.hsts,
    required this.csp,
    required this.headers,
    required this.cookies,
    this.timestamp,
  });

  /// Create from Firestore document
  factory ScanResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanResult(
      id: doc.id,
      url: data['url'] as String? ?? '',
      score: data['score'] as int? ?? 0,
      risk: data['risk'] as String? ?? 'Unknown',
      https: data['https'] as bool? ?? false,
      hsts: data['hsts'] as bool? ?? false,
      csp: data['csp'] as bool? ?? false,
      headers: Map<String, bool>.from(data['headers'] as Map? ?? {}),
      cookies: Map<String, dynamic>.from(data['cookies'] as Map? ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'score': score,
      'risk': risk,
      'https': https,
      'hsts': hsts,
      'csp': csp,
      'headers': headers,
      'cookies': cookies,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Get security grade letter
  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  /// Get display-friendly URL (remove protocol)
  String get displayUrl {
    return url.replaceAll(RegExp(r'^https?://'), '');
  }

  /// Format timestamp
  String get formattedDate {
    if (timestamp == null) return 'N/A';
    final now = DateTime.now();
    final diff = now.difference(timestamp!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${timestamp!.day}/${timestamp!.month}/${timestamp!.year}';
  }

  /// Check if any security header is missing
  bool get hasMissingHeaders {
    return headers.values.any((present) => !present);
  }

  /// Count of present headers
  int get presentHeaderCount {
    return headers.values.where((present) => present).length;
  }

  /// Count of missing headers
  int get missingHeaderCount {
    return headers.values.where((present) => !present).length;
  }

  /// Check if cookies are secure
  bool get areCookiesSecure {
    if (cookies.isEmpty) return false;
    return cookies['secure'] == true && 
           cookies['httpOnly'] == true && 
           cookies['sameSite'] == 'Lax' || cookies['sameSite'] == 'Strict';
  }

  @override
  String toString() {
    return 'ScanResult(id: $id, url: $url, score: $score, risk: $risk, grade: $grade)';
  }
}
