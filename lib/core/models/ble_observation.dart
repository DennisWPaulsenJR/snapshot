class BleObservation {
  const BleObservation({
    required this.hashedBeaconId,
    required this.rssi,
    required this.observedAt,
    this.displayName,
  });

  final String hashedBeaconId;
  final int rssi;
  final DateTime observedAt;
  final String? displayName;
}
