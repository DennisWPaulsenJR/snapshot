import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/signal_snapshot.dart';

abstract class SnapshotStorageService {
  Future<List<SignalSnapshot>> loadSnapshots();
  Future<void> saveSnapshots(List<SignalSnapshot> snapshots);
  Future<void> clearSnapshots();
}

class SharedPreferencesSnapshotStorageService
    implements SnapshotStorageService {
  SharedPreferencesSnapshotStorageService(this._preferences);

  static const snapshotsKey = 'snapshot.signal_snapshots.v1';

  final SharedPreferences _preferences;

  @override
  Future<List<SignalSnapshot>> loadSnapshots() async {
    final encoded = _preferences.getString(snapshotsKey);
    if (encoded == null || encoded.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(encoded) as List<Object?>;
    return decoded
        .cast<Map<String, Object?>>()
        .map(SignalSnapshot.fromStorageJson)
        .toList();
  }

  @override
  Future<void> saveSnapshots(List<SignalSnapshot> snapshots) async {
    final encoded = jsonEncode(
      snapshots.map((snapshot) => snapshot.toStorageJson()).toList(),
    );
    await _preferences.setString(snapshotsKey, encoded);
  }

  @override
  Future<void> clearSnapshots() async {
    await _preferences.remove(snapshotsKey);
  }
}

class InMemorySnapshotStorageService implements SnapshotStorageService {
  List<SignalSnapshot> _snapshots;

  InMemorySnapshotStorageService([List<SignalSnapshot> snapshots = const []])
    : _snapshots = List.of(snapshots);

  @override
  Future<List<SignalSnapshot>> loadSnapshots() async {
    return List.unmodifiable(_snapshots);
  }

  @override
  Future<void> saveSnapshots(List<SignalSnapshot> snapshots) async {
    _snapshots = List.of(snapshots);
  }

  @override
  Future<void> clearSnapshots() async {
    _snapshots = [];
  }
}
