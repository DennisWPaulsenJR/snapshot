import 'package:flutter_test/flutter_test.dart';
import 'package:snapshot/core/models/signal_snapshot.dart';
import 'package:snapshot/core/services/audit_log_service.dart';
import 'package:snapshot/core/services/ble_scan_service.dart';
import 'package:snapshot/core/services/location_service.dart';
import 'package:snapshot/core/services/network_context_service.dart';
import 'package:snapshot/core/services/retention_service.dart';
import 'package:snapshot/core/services/snapshot_service.dart';
import 'package:snapshot/core/storage/snapshot_storage_service.dart';

void main() {
  test('retention cleanup deletes expired snapshots from storage', () async {
    final now = DateTime.now();
    final expired = SignalSnapshot(
      id: 'expired',
      appDeviceId: 'local_mock_device',
      createdAt: now.subtract(const Duration(days: 4)),
      retentionExpiresAt: now.subtract(const Duration(minutes: 1)),
      bleObservations: const [],
      wifiObservation: null,
      locationObservation: null,
    );
    final active = SignalSnapshot(
      id: 'active',
      appDeviceId: 'local_mock_device',
      createdAt: now,
      retentionExpiresAt: now.add(const Duration(hours: 1)),
      bleObservations: const [],
      wifiObservation: null,
      locationObservation: null,
    );
    final storage = InMemorySnapshotStorageService([expired, active]);
    final service = LocalSnapshotService(
      bleScanService: MockBleScanService(),
      networkContextService: MockNetworkContextService(),
      locationService: MockLocationService(),
      retentionService: DefaultRetentionService(),
      auditLogService: InMemoryAuditLogService(),
      snapshotStorageService: storage,
    );

    await service.initialize();

    expect(await service.deleteExpiredSnapshots(), 0);
    expect((await service.listSnapshots()).map((snapshot) => snapshot.id), [
      'active',
    ]);
    expect((await storage.loadSnapshots()).map((snapshot) => snapshot.id), [
      'active',
    ]);
  });
}
