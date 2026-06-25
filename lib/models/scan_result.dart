import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mr_helper_security_analyzer/models/security_finding.dart';

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

  /// Server software disclosure: {'server': String?, 'poweredBy': String?,
  /// 'disclosed': bool}. Empty map when nothing was disclosed.
  final Map<String, dynamic> serverInfo;

  /// TLS certificate details (mobile/desktop only): {'checked': bool,
  /// 'valid': bool, 'issuer': String?, 'subject': String?,
  /// 'expiresOn': String?, 'daysRemaining': int?, 'error': String?}.
  final Map<String, dynamic> certificate;

  /// DNS / email security: {'spf': bool, 'dmarc': bool, 'dmarcPolicy': String?,
  /// 'mx': bool, 'checked': bool}.
  final Map<String, dynamic> dnsInfo;

  /// Discovery probes: {'securityTxt': bool, 'robotsTxt': bool,
  /// 'exposedGit': bool, 'exposedEnv': bool, 'exposedHtaccess': bool}.
  final Map<String, dynamic> discoveryInfo;

  /// Detailed findings with severity, used to drive the report.
  final List<SecurityFinding> findings;

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
    this.serverInfo = const {},
    this.certificate = const {},
    this.dnsInfo = const {},
    this.discoveryInfo = const {},
    this.findings = const [],
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
      serverInfo: Map<String, dynamic>.from(data['serverInfo'] as Map? ?? {}),
      certificate: Map<String, dynamic>.from(data['certificate'] as Map? ?? {}),
      dnsInfo: Map<String, dynamic>.from(data['dnsInfo'] as Map? ?? {}),
      discoveryInfo:
          Map<String, dynamic>.from(data['discoveryInfo'] as Map? ?? {}),
      findings: ((data['findings'] as List?) ?? [])
          .map((e) => SecurityFinding.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
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
      'serverInfo': serverInfo,
      'certificate': certificate,
      'dnsInfo': dnsInfo,
      'discoveryInfo': discoveryInfo,
      'findings': findings.map((f) => f.toMap()).toList(),
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
        (cookies['sameSite'] == 'Lax' || cookies['sameSite'] == 'Strict');
  }

  /// Findings sorted by severity (most serious first).
  List<SecurityFinding> get sortedFindings {
    final list = [...findings];
    list.sort((a, b) => a.severity.weight.compareTo(b.severity.weight));
    return list;
  }

  /// Number of findings at the given severity.
  int countBySeverity(FindingSeverity severity) =>
      findings.where((f) => f.severity == severity).length;

  /// Whether the server software version was disclosed.
  bool get serverDisclosed => serverInfo['disclosed'] == true;

  @override
  String toString() {
    return 'ScanResult(id: $id, url: $url, score: $score, risk: $risk, grade: $grade)';
  }
}
