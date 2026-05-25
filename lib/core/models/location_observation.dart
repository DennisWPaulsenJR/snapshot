class LocationObservation {
  const LocationObservation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.observedAt,
    required this.permissionGranted,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime observedAt;
  final bool permissionGranted;
}
