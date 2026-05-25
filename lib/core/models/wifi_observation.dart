class WifiObservation {
  const WifiObservation({
    required this.idHash,
    required this.observedAt,
    this.rawIdProtected,
    this.displayName,
    this.signalStrength,
  });

  final String idHash;
  final DateTime observedAt;
  final String? rawIdProtected;
  final String? displayName;
  final int? signalStrength;
}
