import '../models/location_observation.dart';

abstract class LocationService {
  Future<LocationObservation?> getCurrentLocation();
}

class MockLocationService implements LocationService {
  @override
  Future<LocationObservation?> getCurrentLocation() async {
    return LocationObservation(
      latitude: 39.7392,
      longitude: -104.9903,
      accuracyMeters: 28,
      observedAt: DateTime.now(),
      permissionGranted: true,
    );
  }
}
