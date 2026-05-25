import 'ble_observation.dart';
import 'location_observation.dart';
import 'wifi_observation.dart';

class SignalSnapshot {
  const SignalSnapshot({
    required this.id,
    required this.appDeviceId,
    required this.createdAt,
    required this.retentionExpiresAt,
    required this.bleObservations,
    required this.wifiObservation,
    required this.locationObservation,
    this.emergencyCaseId,
  });

  final String id;
  final String appDeviceId;
  final DateTime createdAt;
  final DateTime retentionExpiresAt;
  final List<BleObservation> bleObservations;
  final WifiObservation? wifiObservation;
  final LocationObservation? locationObservation;
  final String? emergencyCaseId;

  Map<String, Object?> toStorageJson() {
    return {
      'id': id,
      'appDeviceId': appDeviceId,
      'createdAt': createdAt.toIso8601String(),
      'retentionExpiresAt': retentionExpiresAt.toIso8601String(),
      'bleObservations': bleObservations
          .map((observation) => observation.toStorageJson())
          .toList(),
      'wifiObservation': wifiObservation?.toStorageJson(),
      'locationObservation': locationObservation?.toStorageJson(),
      'emergencyCaseId': emergencyCaseId,
    };
  }

  factory SignalSnapshot.fromStorageJson(Map<String, Object?> json) {
    final bleJson = json['bleObservations'] as List<Object?>? ?? const [];
    return SignalSnapshot(
      id: json['id'] as String,
      appDeviceId: json['appDeviceId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retentionExpiresAt: DateTime.parse(json['retentionExpiresAt'] as String),
      bleObservations: bleJson
          .cast<Map<String, Object?>>()
          .map(BleObservation.fromStorageJson)
          .toList(),
      wifiObservation: switch (json['wifiObservation']) {
        final Map<String, Object?> wifi => WifiObservation.fromStorageJson(
          wifi,
        ),
        _ => null,
      },
      locationObservation: switch (json['locationObservation']) {
        final Map<String, Object?> location =>
          LocationObservation.fromStorageJson(location),
        _ => null,
      },
      emergencyCaseId: json['emergencyCaseId'] as String?,
    );
  }
}
