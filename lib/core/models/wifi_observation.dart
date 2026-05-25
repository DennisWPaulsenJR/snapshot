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

  Map<String, Object?> toStorageJson() {
    return {
      'idHash': idHash,
      'observedAt': observedAt.toIso8601String(),
      'rawIdProtected': rawIdProtected,
      'displayName': displayName,
      'signalStrength': signalStrength,
    };
  }

  factory WifiObservation.fromStorageJson(Map<String, Object?> json) {
    return WifiObservation(
      idHash: json['idHash'] as String,
      observedAt: DateTime.parse(json['observedAt'] as String),
      rawIdProtected: json['rawIdProtected'] as String?,
      displayName: json['displayName'] as String?,
      signalStrength: json['signalStrength'] as int?,
    );
  }
}
