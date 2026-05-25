import 'package:flutter_test/flutter_test.dart';
import 'package:snapshot/core/models/audit_event.dart';
import 'package:snapshot/core/models/protected_export.dart';
import 'package:snapshot/core/services/audit_log_service.dart';
import 'package:snapshot/core/services/protected_export_service.dart';

void main() {
  test('protected export request can be approved and then revoked', () async {
    final audit = InMemoryAuditLogService();
    final service = MockProtectedExportService(auditLogService: audit);
    final request = await service.createRequest(
      reason: EmergencyAccessReason.missingPersonEmergency,
      requestedBy: 'guardian',
      requestedConcepts: const {ExportAuthorizationConcept.guardian},
    );

    final approved = await service.approveRequest(
      requestId: request.id,
      approvedBy: 'owner',
    );
    final revoked = await service.revokeRequest(
      requestId: request.id,
      revokedBy: 'owner',
    );

    expect(approved.status, ExportRequestStatus.approved);
    expect(revoked.status, ExportRequestStatus.revoked);
    expect(
      (await service.listRequests()).single.status,
      ExportRequestStatus.revoked,
    );
  });

  test(
    'expired pending request transitions to expired and audits it',
    () async {
      final audit = InMemoryAuditLogService();
      final service = MockProtectedExportService(
        auditLogService: audit,
        approvalTimeout: const Duration(milliseconds: -1),
      );
      await service.createRequest(
        reason: EmergencyAccessReason.guardianSafetyReview,
        requestedBy: 'guardian',
        requestedConcepts: const {ExportAuthorizationConcept.guardian},
      );

      final expired = await service.expirePendingRequests();
      final request = (await service.listRequests()).single;
      final events = await audit.listEvents();

      expect(expired, 1);
      expect(request.status, ExportRequestStatus.expired);
      expect(
        events.any(
          (event) => event.type == AuditEventType.exportRequestExpired,
        ),
        isTrue,
      );
    },
  );

  test('denied export flow records denial audit', () async {
    final audit = InMemoryAuditLogService();
    final service = MockProtectedExportService(auditLogService: audit);
    final request = await service.createRequest(
      reason: EmergencyAccessReason.verifiedLegalRequest,
      requestedBy: 'reviewer',
      requestedConcepts: const {ExportAuthorizationConcept.legalRequest},
    );

    final denied = await service.denyRequest(
      requestId: request.id,
      deniedBy: 'owner',
      reason: 'Insufficient verification',
    );

    expect(denied.status, ExportRequestStatus.denied);
    expect(denied.decisionSummary, 'Insufficient verification');
    expect(
      (await audit.listEvents()).any(
        (event) => event.type == AuditEventType.exportRequestDenied,
      ),
      isTrue,
    );
  });

  test(
    'unauthorized protected export attempt is rejected and audited',
    () async {
      final audit = InMemoryAuditLogService();
      final service = MockProtectedExportService(auditLogService: audit);
      final request = await service.createRequest(
        reason: EmergencyAccessReason.localDebugReview,
        requestedBy: 'debugger',
        requestedConcepts: const {ExportAuthorizationConcept.localDebug},
      );

      final result = await service.attemptProtectedExport(request.id);
      final events = await audit.listEvents();

      expect(result.authorized, isFalse);
      expect(result.records, isEmpty);
      expect(result.reason, contains('requires approved'));
      expect(
        events.any(
          (event) =>
              event.type == AuditEventType.unauthorizedProtectedExportRejected,
        ),
        isTrue,
      );
    },
  );

  test('approved request still cannot expose raw data in MVP', () async {
    final audit = InMemoryAuditLogService();
    final service = MockProtectedExportService(auditLogService: audit);
    final request = await service.createRequest(
      reason: EmergencyAccessReason.missingPersonEmergency,
      requestedBy: 'guardian',
      requestedConcepts: const {
        ExportAuthorizationConcept.guardian,
        ExportAuthorizationConcept.emergencyVerified,
      },
    );
    await service.approveRequest(requestId: request.id, approvedBy: 'owner');

    final result = await service.attemptProtectedExport(request.id);

    expect(result.authorized, isFalse);
    expect(result.records, isEmpty);
    expect(result.reason, contains('not implemented in MVP'));
  });
}
