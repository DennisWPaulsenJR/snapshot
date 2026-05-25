import '../models/ble_observation.dart';
import '../security/identifier_protection.dart';

abstract class BleScanService {
  Future<List<BleObservation>> scanNearbyBeacons();
}

class MockBleScanService implements BleScanService {
  MockBleScanService({
    IdentifierProtection identifierProtection = const IdentifierProtection(),
  }) : _identifierProtection = identifierProtection;

  final IdentifierProtection _identifierProtection;

  @override
  Future<List<BleObservation>> scanNearbyBeacons() async {
    final observedAt = DateTime.now();
    final backpackBeacon = _identifierProtection.protectMockIdentifier(
      'mock_ble_family_beacon_01',
    );
    final safetyTag = _identifierProtection.protectMockIdentifier(
      'mock_ble_safety_tag_02',
    );

    return [
      BleObservation(
        idHash: backpackBeacon.idHash,
        rawIdProtected: backpackBeacon.rawIdProtected,
        rssi: -63,
        observedAt: observedAt,
        displayName: 'Registered backpack beacon',
      ),
      BleObservation(
        idHash: safetyTag.idHash,
        rawIdProtected: safetyTag.rawIdProtected,
        rssi: -78,
        observedAt: observedAt,
        displayName: 'Mock safety tag',
      ),
    ];
  }
}
