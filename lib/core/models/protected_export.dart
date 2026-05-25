enum ExportRequestStatus { pending, denied, approved, expired, revoked }

enum ExportAuthorizationConcept {
  guardian,
  owner,
  emergencyVerified,
  legalRequest,
  localDebug,
}

enum EmergencyAccessReason {
  missingPersonEmergency,
  guardianSafetyReview,
  verifiedLegalRequest,
  localDebugReview,
}

class ExportRequest {
  const ExportRequest({
    required this.id,
    required this.reason,
    required this.requestedBy,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.requestedConcepts,
    this.decisionSummary,
  });

  final String id;
  final EmergencyAccessReason reason;
  final String requestedBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ExportRequestStatus status;
  final Set<ExportAuthorizationConcept> requestedConcepts;
  final String? decisionSummary;

  ExportRequest copyWith({
    ExportRequestStatus? status,
    String? decisionSummary,
  }) {
    return ExportRequest(
      id: id,
      reason: reason,
      requestedBy: requestedBy,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: status ?? this.status,
      requestedConcepts: requestedConcepts,
      decisionSummary: decisionSummary ?? this.decisionSummary,
    );
  }
}

class ExportAuthorization {
  const ExportAuthorization({
    required this.requestId,
    required this.approvedBy,
    required this.approvedAt,
    required this.expiresAt,
    required this.concepts,
  });

  final String requestId;
  final String approvedBy;
  final DateTime approvedAt;
  final DateTime expiresAt;
  final Set<ExportAuthorizationConcept> concepts;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());
}

class ExportAuditRecord {
  const ExportAuditRecord({
    required this.id,
    required this.requestId,
    required this.createdAt,
    required this.actor,
    required this.action,
    required this.summary,
  });

  final String id;
  final String requestId;
  final DateTime createdAt;
  final String actor;
  final String action;
  final String summary;
}

class ProtectedExportResult {
  const ProtectedExportResult.rejected(this.reason) : authorized = false;

  final bool authorized;
  final String reason;
  List<Map<String, Object?>> get records => const [];
}
