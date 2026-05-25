import '../models/wifi_observation.dart';
import '../security/identifier_protection.dart';

abstract class NetworkContextService {
  Future<WifiObservation?> getCurrentWifiContext();
}

class MockNetworkContextService implements NetworkContextService {
  MockNetworkContextService({
    IdentifierProtection identifierProtection = const IdentifierProtection(),
  }) : _identifierProtection = identifierProtection;

  final IdentifierProtection _identifierProtection;

  @override
  Future<WifiObservation?> getCurrentWifiContext() async {
    final networkId = _identifierProtection.protectMockIdentifier(
      'mock_wifi_home_network_01',
    );

    return WifiObservation(
      idHash: networkId.idHash,
      rawIdProtected: networkId.rawIdProtected,
      observedAt: DateTime.now(),
      displayName: 'Mock home network',
      signalStrength: -51,
    );
  }
}
