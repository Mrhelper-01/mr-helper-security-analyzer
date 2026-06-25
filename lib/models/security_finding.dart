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

/// A single issue or note produced by the scanner.
class SecurityFinding {
  final String title;
  final String description;
  final FindingSeverity severity;

  /// Optional remediation advice (what the site owner should do).
  final String? recommendation;

  const SecurityFinding({
    required this.title,
    required this.description,
    required this.severity,
    this.recommendation,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'severity': severity.id,
        if (recommendation != null) 'recommendation': recommendation,
      };

  factory SecurityFinding.fromMap(Map<String, dynamic> map) => SecurityFinding(
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        severity: FindingSeverity.fromId(map['severity'] as String?),
        recommendation: map['recommendation'] as String?,
      );
}
