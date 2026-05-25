enum EmergencyCaseStatus { draft, guardianReview, verifiedEmergency, closed }

class EmergencyCase {
  const EmergencyCase({
    required this.id,
    required this.personDisplayName,
    required this.guardianDisplayName,
    required this.status,
    required this.createdAt,
    required this.snapshotIds,
    required this.auditEventIds,
    this.closedAt,
  });

  final String id;
  final String personDisplayName;
  final String guardianDisplayName;
  final EmergencyCaseStatus status;
  final DateTime createdAt;
  final DateTime? closedAt;
  final List<String> snapshotIds;
  final List<String> auditEventIds;
}
