import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapshot/core/models/signal_snapshot.dart';
import 'package:snapshot/core/storage/snapshot_storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('shared preferences storage loads snapshots saved earlier', () async {
    final now = DateTime.utc(2026, 5, 24, 12);
    final snapshot = SignalSnapshot(
      id: 'snapshot_persisted',
      appDeviceId: 'local_mock_device',
      createdAt: now,
      retentionExpiresAt: now.add(const Duration(hours: 72)),
      bleObservations: const [],
      wifiObservation: null,
      locationObservation: null,
    );

    final preferences = await SharedPreferences.getInstance();
    final firstStorage = SharedPreferencesSnapshotStorageService(preferences);
    await firstStorage.saveSnapshots([snapshot]);

    final secondStorage = SharedPreferencesSnapshotStorageService(preferences);
    final loaded = await secondStorage.loadSnapshots();

    expect(loaded.single.id, 'snapshot_persisted');
    expect(loaded.single.retentionExpiresAt, snapshot.retentionExpiresAt);
  });
}
