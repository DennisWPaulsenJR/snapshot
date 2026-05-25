import '../models/signal_snapshot.dart';

class PrivacySafeSnapshotExportService {
  const PrivacySafeSnapshotExportService();

  List<Map<String, Object?>> exportSnapshots(List<SignalSnapshot> snapshots) {
    return snapshots.map(exportSnapshot).toList();
  }

  Map<String, Object?> exportSnapshot(SignalSnapshot snapshot) {
    return {
      'id': snapshot.id,
      'appDeviceId': snapshot.appDeviceId,
      'createdAt': snapshot.createdAt.toIso8601String(),
      'retentionExpiresAt': snapshot.retentionExpiresAt.toIso8601String(),
      'emergencyCaseId': snapshot.emergencyCaseId,
      'bleObservations': snapshot.bleObservations
          .map(
            (observation) => {
              'idHash': observation.idHash,
              'rssi': observation.rssi,
              'observedAt': observation.observedAt.toIso8601String(),
              'displayName': observation.displayName,
            },
          )
          .toList(),
      'wifiObservation': switch (snapshot.wifiObservation) {
        final wifi? => {
          'idHash': wifi.idHash,
          'observedAt': wifi.observedAt.toIso8601String(),
          'displayName': wifi.displayName,
          'signalStrength': wifi.signalStrength,
        },
        _ => null,
      },
      'locationObservation': switch (snapshot.locationObservation) {
        final location? => {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracyMeters': location.accuracyMeters,
          'observedAt': location.observedAt.toIso8601String(),
          'permissionGranted': location.permissionGranted,
        },
        _ => null,
      },
    };
  }
}
