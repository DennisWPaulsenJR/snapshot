class WifiObservation {
  const WifiObservation({
    required this.hashedNetworkId,
    required this.observedAt,
    this.displayName,
    this.signalStrength,
  });

  final String hashedNetworkId;
  final DateTime observedAt;
  final String? displayName;
  final int? signalStrength;
}
