enum SafetyDeviceType { phone, bleBeacon, wearable, homeNetwork }

class SafetyDevice {
  const SafetyDevice({
    required this.id,
    required this.displayName,
    required this.type,
    required this.idHash,
    required this.registeredAt,
    required this.consentConfirmed,
    this.rawIdProtected,
  });

  final String id;
  final String displayName;
  final SafetyDeviceType type;
  final String idHash;
  final DateTime registeredAt;
  final bool consentConfirmed;
  final String? rawIdProtected;
}
