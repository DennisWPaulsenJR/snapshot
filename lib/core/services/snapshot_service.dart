import '../models/audit_event.dart';
import '../models/signal_snapshot.dart';
import 'audit_log_service.dart';
import 'ble_scan_service.dart';
import 'location_service.dart';
import 'network_context_service.dart';
import 'retention_service.dart';

abstract class SnapshotService {
  Future<SignalSnapshot> createTestSnapshot();
  Future<List<SignalSnapshot>> listSnapshots();
}

class InMemorySnapshotService implements SnapshotService {
  InMemorySnapshotService({
    required BleScanService bleScanService,
    required NetworkContextService networkContextService,
    required LocationService locationService,
    required RetentionService retentionService,
    required AuditLogService auditLogService,
  }) : _bleScanService = bleScanService,
       _networkContextService = networkContextService,
       _locationService = locationService,
       _retentionService = retentionService,
       _auditLogService = auditLogService;

  final BleScanService _bleScanService;
  final NetworkContextService _networkContextService;
  final LocationService _locationService;
  final RetentionService _retentionService;
  final AuditLogService _auditLogService;
  final List<SignalSnapshot> _snapshots = [];

  @override
  Future<SignalSnapshot> createTestSnapshot() async {
    final createdAt = DateTime.now();
    final snapshot = SignalSnapshot(
      id: 'snapshot_${createdAt.microsecondsSinceEpoch}',
      appDeviceId: 'local_mock_device',
      createdAt: createdAt,
      retentionExpiresAt: _retentionService.expirationForNormalSnapshot(
        createdAt,
      ),
      bleObservations: await _bleScanService.scanNearbyBeacons(),
      wifiObservation: await _networkContextService.getCurrentWifiContext(),
      locationObservation: await _locationService.getCurrentLocation(),
    );

    _snapshots.insert(0, snapshot);
    await _auditLogService.record(
      AuditEvent(
        id: 'audit_${createdAt.microsecondsSinceEpoch}',
        type: AuditEventType.snapshotCreated,
        timestamp: createdAt,
        actor: 'local_profile',
        summary: 'Created local mock signal snapshot',
        subjectId: snapshot.id,
        metadata: {
          'retentionExpiresAt': snapshot.retentionExpiresAt.toIso8601String(),
        },
      ),
    );
    return snapshot;
  }

  @override
  Future<List<SignalSnapshot>> listSnapshots() async {
    return List.unmodifiable(_snapshots);
  }
}
