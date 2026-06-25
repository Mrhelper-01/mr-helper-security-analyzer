/// MR HELPER - Web Application Security Analyzer
/// Model representing a single security finding with a severity level.
library;

/// Severity of a security finding, ordered from most to least serious.
enum FindingSeverity {
  critical,
  high,
  medium,
  low,
  info;

  /// Stable string used for storage / serialization.
  String get id => name;

  /// Human-friendly label.
  String get label {
    switch (this) {
      case FindingSeverity.critical:
        return 'Critical';
      case FindingSeverity.high:
        return 'High';
      case FindingSeverity.medium:
        return 'Medium';
      case FindingSeverity.low:
        return 'Low';
      case FindingSeverity.info:
        return 'Info';
    }
  }

  /// Sort weight — lower comes first (most serious).
  int get weight => index;

  static FindingSeverity fromId(String? id) {
    return FindingSeverity.values.firstWhere(
      (s) => s.name == id,
      orElse: () => FindingSeverity.info,
    );
  }
}

/// Stable identifier for each kind of finding, used to look up localized text.
enum FindingCode {
  noHttps,
  missingHsts,
  missingCsp,
  weakCsp,
  missingXFrame,
  missingXContent,
  missingReferrer,
  missingPermissions,
  missingCoop,
  missingCorp,
  serverDisclosed,
  cookieNoSecure,
  cookieNoHttpOnly,
  cookieSameSiteNone,
  certInvalid,
  certExpiringSoon,
  other;

  static FindingCode fromId(String? id) => FindingCode.values.firstWhere(
        (c) => c.name == id,
        orElse: () => FindingCode.other,
      );
}

/// A single issue or note produced by the scanner.
class SecurityFinding {
  final String title;
  final String description;
  final FindingSeverity severity;

  /// Optional remediation advice (what the site owner should do).
  final String? recommendation;

  /// Stable code used to fetch localized text at display time.
  final FindingCode code;

  /// Optional dynamic value embedded in the message (e.g. server banner,
  /// days-remaining), so localized text can re-inject it.
  final dynamic param;

  const SecurityFinding({
    required this.title,
    required this.description,
    required this.severity,
    this.recommendation,
    this.code = FindingCode.other,
    this.param,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'severity': severity.id,
        'code': code.name,
        if (recommendation != null) 'recommendation': recommendation,
        if (param != null) 'param': param,
      };

  factory SecurityFinding.fromMap(Map<String, dynamic> map) => SecurityFinding(
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        severity: FindingSeverity.fromId(map['severity'] as String?),
        recommendation: map['recommendation'] as String?,
        code: FindingCode.fromId(map['code'] as String?),
        param: map['param'],
      );
}
