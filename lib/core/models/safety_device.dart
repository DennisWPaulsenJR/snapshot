enum SafetyDeviceType { phone, bleBeacon, wearable, homeNetwork }

class SafetyDevice {
  const SafetyDevice({
    required this.id,
    required this.displayName,
    required this.type,
    required this.hashedIdentifier,
    required this.registeredAt,
    required this.consentConfirmed,
  });

  final String id;
  final String displayName;
  final SafetyDeviceType type;
  final String hashedIdentifier;
  final DateTime registeredAt;
  final bool consentConfirmed;
}
