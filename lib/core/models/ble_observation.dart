class BleObservation {
  const BleObservation({
    required this.idHash,
    required this.rssi,
    required this.observedAt,
    this.rawIdProtected,
    this.displayName,
  });

  final String idHash;
  final int rssi;
  final DateTime observedAt;
  final String? rawIdProtected;
  final String? displayName;
}
