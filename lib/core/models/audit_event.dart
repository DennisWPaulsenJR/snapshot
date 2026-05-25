enum AuditEventType {
  snapshotCreated,
  emergencyCaseOpened,
  emergencyCaseUpdated,
  deviceRegistered,
  retentionApplied,
}

class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.actor,
    required this.summary,
    this.subjectId,
    this.metadata = const {},
  });

  final String id;
  final AuditEventType type;
  final DateTime timestamp;
  final String actor;
  final String summary;
  final String? subjectId;
  final Map<String, Object?> metadata;
}
