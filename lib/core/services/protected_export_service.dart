import '../models/audit_event.dart';
import '../models/protected_export.dart';
import 'audit_log_service.dart';

abstract class ProtectedExportService {
  Future<ExportRequest> createRequest({
    required EmergencyAccessReason reason,
    required String requestedBy,
    required Set<ExportAuthorizationConcept> requestedConcepts,
  });

  Future<ExportRequest> approveRequest({
    required String requestId,
    required String approvedBy,
  });

  Future<ExportRequest> denyRequest({
    required String requestId,
    required String deniedBy,
    required String reason,
  });

  Future<ExportRequest> revokeRequest({
    required String requestId,
    required String revokedBy,
  });

  Future<List<ExportRequest>> listRequests();
  Future<List<ExportAuditRecord>> listExportAuditRecords();
  Future<int> expirePendingRequests();
  Future<ProtectedExportResult> attemptProtectedExport(String requestId);
}

class MockProtectedExportService implements ProtectedExportService {
  MockProtectedExportService({
    required AuditLogService auditLogService,
    Duration approvalTimeout = const Duration(minutes: 30),
  }) : _auditLogService = auditLogService,
       _approvalTimeout = approvalTimeout;

  final AuditLogService _auditLogService;
  final Duration _approvalTimeout;
  final List<ExportRequest> _requests = [];
  final List<ExportAuditRecord> _auditRecords = [];

  @override
  Future<ExportRequest> createRequest({
    required EmergencyAccessReason reason,
    required String requestedBy,
    required Set<ExportAuthorizationConcept> requestedConcepts,
  }) async {
    final now = DateTime.now();
    final request = ExportRequest(
      id: 'export_${now.microsecondsSinceEpoch}',
      reason: reason,
      requestedBy: requestedBy,
      createdAt: now,
      expiresAt: now.add(_approvalTimeout),
      status: ExportRequestStatus.pending,
      requestedConcepts: requestedConcepts,
    );
    _requests.insert(0, request);
    await _record(
      requestId: request.id,
      actor: requestedBy,
      action: 'created',
      summary: 'Protected export request created',
      eventType: AuditEventType.exportRequestCreated,
      metadata: {'reason': reason.name},
    );
    return request;
  }

  @override
  Future<ExportRequest> approveRequest({
    required String requestId,
    required String approvedBy,
  }) async {
    final request = await _activeRequest(requestId);
    final updated = request.copyWith(
      status: ExportRequestStatus.approved,
      decisionSummary: 'Approved for mock review; raw export remains disabled.',
    );
    _replace(updated);
    await _record(
      requestId: updated.id,
      actor: approvedBy,
      action: 'approved',
      summary: 'Protected export request approved for mock governance review',
      eventType: AuditEventType.exportRequestApproved,
    );
    return updated;
  }

  @override
  Future<ExportRequest> denyRequest({
    required String requestId,
    required String deniedBy,
    required String reason,
  }) async {
    final request = _findRequest(requestId);
    final updated = request.copyWith(
      status: ExportRequestStatus.denied,
      decisionSummary: reason,
    );
    _replace(updated);
    await _record(
      requestId: updated.id,
      actor: deniedBy,
      action: 'denied',
      summary: 'Protected export request denied: $reason',
      eventType: AuditEventType.exportRequestDenied,
    );
    return updated;
  }

  @override
  Future<ExportRequest> revokeRequest({
    required String requestId,
    required String revokedBy,
  }) async {
    final request = _findRequest(requestId);
    final updated = request.copyWith(
      status: ExportRequestStatus.revoked,
      decisionSummary: 'Authorization revoked before protected export.',
    );
    _replace(updated);
    await _record(
      requestId: updated.id,
      actor: revokedBy,
      action: 'revoked',
      summary: 'Protected export request revoked',
      eventType: AuditEventType.exportRequestRevoked,
    );
    return updated;
  }

  @override
  Future<List<ExportRequest>> listRequests() async {
    await expirePendingRequests();
    return List.unmodifiable(_requests);
  }

  @override
  Future<List<ExportAuditRecord>> listExportAuditRecords() async {
    return List.unmodifiable(_auditRecords.reversed);
  }

  @override
  Future<int> expirePendingRequests() async {
    final now = DateTime.now();
    var expiredCount = 0;
    for (final request in List<ExportRequest>.of(_requests)) {
      if (request.status == ExportRequestStatus.pending &&
          !request.expiresAt.isAfter(now)) {
        final updated = request.copyWith(
          status: ExportRequestStatus.expired,
          decisionSummary: 'Pending approval timed out.',
        );
        _replace(updated);
        expiredCount++;
        await _record(
          requestId: updated.id,
          actor: 'mock_authorization_timer',
          action: 'expired',
          summary: 'Protected export request expired before approval',
          eventType: AuditEventType.exportRequestExpired,
        );
      }
    }
    return expiredCount;
  }

  @override
  Future<ProtectedExportResult> attemptProtectedExport(String requestId) async {
    final request = _findRequest(requestId);
    await expirePendingRequests();
    final current = _findRequest(requestId);
    final isApproved = current.status == ExportRequestStatus.approved;
    final rejectionReason = isApproved
        ? 'Protected/raw export is not implemented in MVP.'
        : 'Protected export requires approved, unexpired authorization.';

    await _record(
      requestId: request.id,
      actor: 'local_debug_user',
      action: 'protected_export_rejected',
      summary: rejectionReason,
      eventType: AuditEventType.unauthorizedProtectedExportRejected,
      metadata: {'status': current.status.name},
    );
    return ProtectedExportResult.rejected(rejectionReason);
  }

  Future<ExportRequest> _activeRequest(String requestId) async {
    await expirePendingRequests();
    final request = _findRequest(requestId);
    if (request.status != ExportRequestStatus.pending) {
      throw StateError('Only pending requests can transition from review.');
    }
    return request;
  }

  ExportRequest _findRequest(String requestId) {
    return _requests.firstWhere(
      (request) => request.id == requestId,
      orElse: () => throw StateError('Export request not found: $requestId'),
    );
  }

  void _replace(ExportRequest updated) {
    final index = _requests.indexWhere((request) => request.id == updated.id);
    if (index == -1) {
      throw StateError('Export request not found: ${updated.id}');
    }
    _requests[index] = updated;
  }

  Future<void> _record({
    required String requestId,
    required String actor,
    required String action,
    required String summary,
    required AuditEventType eventType,
    Map<String, Object?> metadata = const {},
  }) async {
    final now = DateTime.now();
    final record = ExportAuditRecord(
      id: 'export_audit_${now.microsecondsSinceEpoch}',
      requestId: requestId,
      createdAt: now,
      actor: actor,
      action: action,
      summary: summary,
    );
    _auditRecords.add(record);
    await _auditLogService.record(
      AuditEvent(
        id: 'audit_${now.microsecondsSinceEpoch}',
        type: eventType,
        timestamp: now,
        actor: actor,
        summary: summary,
        subjectId: requestId,
        metadata: {'action': action, ...metadata},
      ),
    );
  }
}
