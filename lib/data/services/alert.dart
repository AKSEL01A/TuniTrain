import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType { info, warning, danger, success }

enum AlertTarget { all, lineUsers, stationUsers, subscribers }

extension AlertTypeX on AlertType {
  String get label => switch (this) {
    AlertType.info => 'Information',
    AlertType.warning => 'Avertissement',
    AlertType.danger => 'Urgence',
    AlertType.success => 'Bonne nouvelle',
  };
}

extension AlertTargetX on AlertTarget {
  String get label => switch (this) {
    AlertTarget.all => 'Tous les clients',
    AlertTarget.lineUsers => 'Utilisateurs d\'une ligne',
    AlertTarget.stationUsers => 'Utilisateurs d\'une gare',
    AlertTarget.subscribers => 'Abonnés uniquement',
  };
}

class Alert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertTarget target;
  final String? targetLineId;
  final String? targetLineName;
  final String? targetStationId;
  final String? targetStationName;
  final bool isPublished;
  final bool isPushEnabled;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.target,
    this.targetLineId,
    this.targetLineName,
    this.targetStationId,
    this.targetStationName,
    required this.isPublished,
    required this.isPushEnabled,
    required this.createdAt,
    this.expiresAt,
  });

  /// Safe enum parser — never throws even if Firestore has an unexpected value
  static AlertType _parseType(dynamic raw) {
    final s = raw?.toString().toLowerCase().trim() ?? '';
    return switch (s) {
      'warning' || 'avertissement' => AlertType.warning,
      'danger' || 'urgence' || 'error' => AlertType.danger,
      'success' || 'bonne nouvelle' => AlertType.success,
      _ => AlertType.info,
    };
  }

  static AlertTarget _parseTarget(dynamic raw) {
    final s = raw?.toString().toLowerCase().trim() ?? '';
    return switch (s) {
      'lineusers' || 'line_users' || 'line' => AlertTarget.lineUsers,
      'stationusers' ||
      'station_users' ||
      'station' => AlertTarget.stationUsers,
      'subscribers' || 'abonnés' || 'abonnes' => AlertTarget.subscribers,
      _ => AlertTarget.all,
    };
  }

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    return Alert(
      id: doc.id,
      title: m['title']?.toString() ?? '',
      message: m['message']?.toString() ?? '',
      type: _parseType(m['type']),
      target: _parseTarget(m['target']),
      targetLineId: m['targetLineId'] as String?,
      targetLineName: m['targetLineName'] as String?,
      targetStationId: m['targetStationId'] as String?,
      targetStationName: m['targetStationName'] as String?,
      isPublished: m['isPublished'] as bool? ?? false,
      isPushEnabled: m['isPushEnabled'] as bool? ?? false,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (m['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'message': message,
    'type': type.name,
    'target': target.name,
    'targetLineId': targetLineId,
    'targetLineName': targetLineName,
    'targetStationId': targetStationId,
    'targetStationName': targetStationName,
    'isPublished': isPublished,
    'isPushEnabled': isPushEnabled,
    'createdAt': FieldValue.serverTimestamp(),
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
  };
}
