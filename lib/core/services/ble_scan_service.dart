import '../models/ble_observation.dart';

abstract class BleScanService {
  Future<List<BleObservation>> scanNearbyBeacons();
}

class MockBleScanService implements BleScanService {
  @override
  Future<List<BleObservation>> scanNearbyBeacons() async {
    final observedAt = DateTime.now();
    return [
      BleObservation(
        hashedBeaconId: 'hash_ble_family_beacon_01',
        rssi: -63,
        observedAt: observedAt,
        displayName: 'Registered backpack beacon',
      ),
      BleObservation(
        hashedBeaconId: 'hash_ble_safety_tag_02',
        rssi: -78,
        observedAt: observedAt,
        displayName: 'Mock safety tag',
      ),
    ];
  }
}
