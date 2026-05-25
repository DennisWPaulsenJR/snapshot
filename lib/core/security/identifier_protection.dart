class ProtectedIdentifier {
  const ProtectedIdentifier({required this.idHash, this.rawIdProtected});

  final String idHash;
  final String? rawIdProtected;
}

class IdentifierProtection {
  const IdentifierProtection({this.sessionSalt = 'mock_local_session_salt'});

  final String sessionSalt;

  // Future real OS-permitted identifiers must enter storage/display only after
  // salted hashing and protected-field handling. Mock raw values here model the
  // pipeline shape without enabling real scanning or identifier lookup.
  ProtectedIdentifier protectMockIdentifier(String mockRawId) {
    return ProtectedIdentifier(
      idHash: 'mock_session_hash_${_mockHash('$sessionSalt:$mockRawId')}',
      rawIdProtected: 'mock_encrypted:$mockRawId',
    );
  }

  String _mockHash(String value) {
    final hash = value.codeUnits.fold<int>(17, (current, unit) {
      return (current * 31 + unit) & 0x3fffffff;
    });
    return hash.toRadixString(16);
  }
}
