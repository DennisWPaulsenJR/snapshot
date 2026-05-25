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
}
