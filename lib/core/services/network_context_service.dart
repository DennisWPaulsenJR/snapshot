import '../models/wifi_observation.dart';

abstract class NetworkContextService {
  Future<WifiObservation?> getCurrentWifiContext();
}

class MockNetworkContextService implements NetworkContextService {
  @override
  Future<WifiObservation?> getCurrentWifiContext() async {
    return WifiObservation(
      hashedNetworkId: 'hash_wifi_home_network_01',
      observedAt: DateTime.now(),
      displayName: 'Mock home network',
      signalStrength: -51,
    );
  }
}
