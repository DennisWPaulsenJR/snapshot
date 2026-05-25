import '../export/privacy_safe_snapshot_export_service.dart';
import '../models/audit_event.dart';
import '../models/signal_snapshot.dart';
import '../storage/snapshot_storage_service.dart';
import 'audit_log_service.dart';
import 'ble_scan_service.dart';
import 'location_service.dart';
import 'network_context_service.dart';
import 'retention_service.dart';

abstract class SnapshotService {
  Future<void> initialize();
  Future<SignalSnapshot> createTestSnapshot();
  Future<List<SignalSnapshot>> listSnapshots();
  Future<int> deleteExpiredSnapshots();
  Future<void> clearSnapshots();
  Future<List<Map<String, Object?>>> exportPrivacySafeSnapshots();
}

class LocalSnapshotService implements SnapshotService {
  LocalSnapshotService({
    required BleScanService bleScanService,
    required NetworkContextService networkContextService,
    required LocationService locationService,
    required RetentionService retentionService,
    required AuditLogService auditLogService,
    required SnapshotStorageService snapshotStorageService,
    PrivacySafeSnapshotExportService exportService =
        const PrivacySafeSnapshotExportService(),
  }) : _bleScanService = bleScanService,
       _networkContextService = networkContextService,
       _locationService = locationService,
       _retentionService = retentionService,
       _auditLogService = auditLogService,
       _snapshotStorageService = snapshotStorageService,
       _exportService = exportService;

  final BleScanService _bleScanService;
  final NetworkContextService _networkContextService;
  final LocationService _locationService;
  final RetentionService _retentionService;
  final AuditLogService _auditLogService;
  final SnapshotStorageService _snapshotStorageService;
  final PrivacySafeSnapshotExportService _exportService;
  final List<SignalSnapshot> _snapshots = [];
  bool _isLoaded = false;

  @override
  Future<void> initialize() async {
    await _ensureLoaded();
    await deleteExpiredSnapshots();
  }

  @override
  Future<SignalSnapshot> createTestSnapshot() async {
    await _ensureLoaded();
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
    await _persistSnapshots();
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
    await _ensureLoaded();
    await deleteExpiredSnapshots();
    return List.unmodifiable(_snapshots);
  }

  @override
  Future<int> deleteExpiredSnapshots() async {
    await _ensureLoaded();
    final now = DateTime.now();
    final before = _snapshots.length;
    _snapshots.removeWhere(
      (snapshot) => !snapshot.retentionExpiresAt.isAfter(now),
    );
    final deleted = before - _snapshots.length;
    if (deleted > 0) {
      await _persistSnapshots();
      await _auditLogService.record(
        AuditEvent(
          id: 'audit_retention_${now.microsecondsSinceEpoch}',
          type: AuditEventType.retentionApplied,
          timestamp: now,
          actor: 'local_retention_service',
          summary: 'Deleted $deleted expired local snapshots',
          metadata: {'deletedCount': deleted},
        ),
      );
    }
    return deleted;
  }

  @override
  Future<void> clearSnapshots() async {
    await _ensureLoaded();
    _snapshots.clear();
    await _snapshotStorageService.clearSnapshots();
  }

  @override
  Future<List<Map<String, Object?>>> exportPrivacySafeSnapshots() async {
    await _ensureLoaded();
    await deleteExpiredSnapshots();
    final export = _exportService.exportSnapshots(_snapshots);
    final now = DateTime.now();
    await _auditLogService.record(
      AuditEvent(
        id: 'audit_export_preview_${now.microsecondsSinceEpoch}',
        type: AuditEventType.exportPreviewGenerated,
        timestamp: now,
        actor: 'local_debug_user',
        summary: 'Generated privacy-safe export preview',
        metadata: {'snapshotCount': export.length},
      ),
    );
    return export;
  }

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }
    _snapshots
      ..clear()
      ..addAll(await _snapshotStorageService.loadSnapshots());
    _isLoaded = true;
  }

  Future<void> _persistSnapshots() async {
    await _snapshotStorageService.saveSnapshots(_snapshots);
  }
}
