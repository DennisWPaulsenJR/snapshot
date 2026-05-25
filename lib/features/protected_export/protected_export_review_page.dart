import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../core/models/audit_event.dart';
import '../../core/models/protected_export.dart';
import '../shared/app_scaffold.dart';

class ProtectedExportReviewPage extends StatefulWidget {
  const ProtectedExportReviewPage({super.key});

  @override
  State<ProtectedExportReviewPage> createState() =>
      _ProtectedExportReviewPageState();
}

class _ProtectedExportReviewPageState extends State<ProtectedExportReviewPage> {
  late Future<_ProtectedExportState> _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = _loadState();
  }

  Future<_ProtectedExportState> _loadState() async {
    final protectedExport = SnapshotScope.protectedExportsOf(context);
    final auditLog = SnapshotScope.auditOf(context);
    final requests = await protectedExport.listRequests();
    final exportAudit = await protectedExport.listExportAuditRecords();
    final auditEvents = await auditLog.listEvents();
    return _ProtectedExportState(
      requests: requests,
      exportAudit: exportAudit,
      auditEvents: auditEvents,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _state = _loadState();
    });
  }

  Future<void> _createMockRequest() async {
    await SnapshotScope.protectedExportsOf(context).createRequest(
      reason: EmergencyAccessReason.missingPersonEmergency,
      requestedBy: 'local_guardian_mock',
      requestedConcepts: const {
        ExportAuthorizationConcept.guardian,
        ExportAuthorizationConcept.emergencyVerified,
      },
    );
    await _refresh();
  }

  Future<void> _approve(String requestId) async {
    await SnapshotScope.protectedExportsOf(
      context,
    ).approveRequest(requestId: requestId, approvedBy: 'local_owner_mock');
    await _refresh();
  }

  Future<void> _deny(String requestId) async {
    await SnapshotScope.protectedExportsOf(context).denyRequest(
      requestId: requestId,
      deniedBy: 'local_owner_mock',
      reason: 'Mock review denied; protected export remains unavailable.',
    );
    await _refresh();
  }

  Future<void> _revoke(String requestId) async {
    await SnapshotScope.protectedExportsOf(
      context,
    ).revokeRequest(requestId: requestId, revokedBy: 'local_owner_mock');
    await _refresh();
  }

  Future<void> _attemptProtectedExport(String requestId) async {
    final result = await SnapshotScope.protectedExportsOf(
      context,
    ).attemptProtectedExport(requestId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.reason)));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Protected Export Review',
      currentIndex: 4,
      child: FutureBuilder<_ProtectedExportState>(
        future: _state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const _ProtectedExportState.empty();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _MvpBoundaryNotice(),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _createMockRequest,
                  icon: const Icon(Icons.add_moderator),
                  label: const Text('Create Mock Request'),
                ),
                const SizedBox(height: 12),
                if (state.requests.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No protected export requests yet.'),
                    ),
                  )
                else
                  for (final request in state.requests) ...[
                    _RequestCard(
                      request: request,
                      onApprove: () => _approve(request.id),
                      onDeny: () => _deny(request.id),
                      onRevoke: () => _revoke(request.id),
                      onAttemptExport: () =>
                          _attemptProtectedExport(request.id),
                    ),
                    const SizedBox(height: 12),
                  ],
                _ExportAuditTimeline(records: state.exportAudit),
                const SizedBox(height: 12),
                _AuditEventTimeline(events: state.auditEvents),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProtectedExportState {
  const _ProtectedExportState({
    required this.requests,
    required this.exportAudit,
    required this.auditEvents,
  });

  const _ProtectedExportState.empty()
    : requests = const [],
      exportAudit = const [],
      auditEvents = const [];

  final List<ExportRequest> requests;
  final List<ExportAuditRecord> exportAudit;
  final List<AuditEvent> auditEvents;
}

class _MvpBoundaryNotice extends StatelessWidget {
  const _MvpBoundaryNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Protected/raw export is not implemented in MVP. This page only models authorization state, expiration, revocation, and audit-backed governance.',
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onDeny,
    required this.onRevoke,
    required this.onAttemptExport,
  });

  final ExportRequest request;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final VoidCallback onRevoke;
  final VoidCallback onAttemptExport;

  @override
  Widget build(BuildContext context) {
    final canReview = request.status == ExportRequestStatus.pending;
    final canRevoke = request.status == ExportRequestStatus.approved;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.id, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Status: ${request.status.name}'),
            Text('Reason: ${request.reason.name}'),
            Text('Requested by: ${request.requestedBy}'),
            Text('Expires: ${request.expiresAt.toLocal()}'),
            Text(
              'Concepts: ${request.requestedConcepts.map((concept) => concept.name).join(', ')}',
            ),
            if (request.decisionSummary != null)
              Text('Decision: ${request.decisionSummary}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: canReview ? onApprove : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve Mock'),
                ),
                OutlinedButton.icon(
                  onPressed: canReview ? onDeny : null,
                  icon: const Icon(Icons.block),
                  label: const Text('Deny'),
                ),
                OutlinedButton.icon(
                  onPressed: canRevoke ? onRevoke : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Revoke'),
                ),
                OutlinedButton.icon(
                  onPressed: onAttemptExport,
                  icon: const Icon(Icons.lock),
                  label: const Text('Attempt Protected Export'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportAuditTimeline extends StatelessWidget {
  const _ExportAuditTimeline({required this.records});

  final List<ExportAuditRecord> records;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export audit history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (records.isEmpty)
              const Text('No export audit records yet.')
            else
              for (final record in records)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long),
                  title: Text(record.action),
                  subtitle: Text(
                    '${record.summary}\n${record.createdAt.toLocal()}',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AuditEventTimeline extends StatelessWidget {
  const _AuditEventTimeline({required this.events});

  final List<AuditEvent> events;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System audit timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (events.isEmpty)
              const Text('No system audit events yet.')
            else
              for (final event in events.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fact_check),
                  title: Text(event.type.name),
                  subtitle: Text(
                    '${event.summary}\n${event.timestamp.toLocal()}',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
