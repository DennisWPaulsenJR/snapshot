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

  Map<String, Object?> toStorageJson() {
    return {
      'idHash': idHash,
      'rssi': rssi,
      'observedAt': observedAt.toIso8601String(),
      'rawIdProtected': rawIdProtected,
      'displayName': displayName,
    };
  }

  factory BleObservation.fromStorageJson(Map<String, Object?> json) {
    return BleObservation(
      idHash: json['idHash'] as String,
      rssi: json['rssi'] as int,
      observedAt: DateTime.parse(json['observedAt'] as String),
      rawIdProtected: json['rawIdProtected'] as String?,
      displayName: json['displayName'] as String?,
    );
  }
}
