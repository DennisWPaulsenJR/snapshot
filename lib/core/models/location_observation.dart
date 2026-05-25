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

  Map<String, Object?> toStorageJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'observedAt': observedAt.toIso8601String(),
      'permissionGranted': permissionGranted,
    };
  }

  factory LocationObservation.fromStorageJson(Map<String, Object?> json) {
    return LocationObservation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num).toDouble(),
      observedAt: DateTime.parse(json['observedAt'] as String),
      permissionGranted: json['permissionGranted'] as bool,
    );
  }
}
