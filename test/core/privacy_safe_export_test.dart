import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snapshot/core/export/privacy_safe_snapshot_export_service.dart';
import 'package:snapshot/core/models/ble_observation.dart';
import 'package:snapshot/core/models/signal_snapshot.dart';
import 'package:snapshot/core/models/wifi_observation.dart';

void main() {
  test('privacy-safe export excludes protected raw fields', () {
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
        ),
      ],
      wifiObservation: WifiObservation(
        idHash: 'hash_wifi',
        rawIdProtected: 'mock_encrypted:wifi',
        observedAt: createdAt,
      ),
      locationObservation: null,
    );

    final export = const PrivacySafeSnapshotExportService().exportSnapshot(
      snapshot,
    );
    final encoded = jsonEncode(export);

    expect(encoded, contains('hash_ble'));
    expect(encoded, contains('hash_wifi'));
    expect(encoded, isNot(contains('rawIdProtected')));
    expect(encoded, isNot(contains('mock_encrypted')));
  });
}
