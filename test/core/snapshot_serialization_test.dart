import 'package:flutter_test/flutter_test.dart';
import 'package:snapshot/core/models/ble_observation.dart';
import 'package:snapshot/core/models/location_observation.dart';
import 'package:snapshot/core/models/signal_snapshot.dart';
import 'package:snapshot/core/models/wifi_observation.dart';

void main() {
  test(
    'signal snapshot storage serialization preserves protected internals',
    () {
      final createdAt = DateTime.utc(2026, 5, 24, 12);
      final snapshot = SignalSnapshot(
        id: 'snapshot_test',
        appDeviceId: 'local_mock_device',
        createdAt: createdAt,
        retentionExpiresAt: createdAt.add(const Duration(hours: 72)),
        bleObservations: [
          BleObservation(
            idHash: 'hash_ble',
            rawIdProtected: 'mock_encrypted:ble',
            rssi: -60,
            observedAt: createdAt,
            displayName: 'Mock BLE',
          ),
        ],
        wifiObservation: WifiObservation(
          idHash: 'hash_wifi',
          rawIdProtected: 'mock_encrypted:wifi',
          observedAt: createdAt,
          displayName: 'Mock Wi-Fi',
          signalStrength: -50,
        ),
        locationObservation: LocationObservation(
          latitude: 1,
          longitude: 2,
          accuracyMeters: 3,
          observedAt: createdAt,
          permissionGranted: true,
        ),
      );

      final restored = SignalSnapshot.fromStorageJson(snapshot.toStorageJson());

      expect(restored.id, snapshot.id);
      expect(restored.bleObservations.single.idHash, 'hash_ble');
      expect(
        restored.bleObservations.single.rawIdProtected,
        'mock_encrypted:ble',
      );
      expect(restored.wifiObservation?.rawIdProtected, 'mock_encrypted:wifi');
      expect(restored.locationObservation?.accuracyMeters, 3);
    },
  );
}
