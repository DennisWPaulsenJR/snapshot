import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../core/models/signal_snapshot.dart';
import '../shared/app_scaffold.dart';

class SnapshotHistoryPage extends StatefulWidget {
  const SnapshotHistoryPage({super.key});

  @override
  State<SnapshotHistoryPage> createState() => _SnapshotHistoryPageState();
}

class _SnapshotHistoryPageState extends State<SnapshotHistoryPage> {
  late Future<_SnapshotHistoryState> _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = _loadState();
  }

  Future<_SnapshotHistoryState> _loadState() async {
    final service = SnapshotScope.snapshotsOf(context);
    final snapshots = await service.listSnapshots();
    final export = await service.exportPrivacySafeSnapshots();
    return _SnapshotHistoryState(snapshots: snapshots, export: export);
  }

  Future<void> _refresh() async {
    setState(() {
      _state = _loadState();
    });
  }

  Future<void> _deleteExpired() async {
    final deleted = await SnapshotScope.snapshotsOf(
      context,
    ).deleteExpiredSnapshots();
    if (!mounted) {
      return;
    }
    await _refresh();
    _showMessage('Deleted $deleted expired snapshots');
  }

  Future<void> _clearAll() async {
    await SnapshotScope.snapshotsOf(context).clearSnapshots();
    if (!mounted) {
      return;
    }
    await _refresh();
    _showMessage('Cleared local snapshot history');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Snapshot History',
      currentIndex: 2,
      child: FutureBuilder<_SnapshotHistoryState>(
        future: _state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const _SnapshotHistoryState.empty();
          final snapshots = state.snapshots;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HistoryActions(
                  onDeleteExpired: _deleteExpired,
                  onClearAll: _clearAll,
                ),
                const SizedBox(height: 12),
                _PrivacySafeExportPreview(export: state.export),
                const SizedBox(height: 12),
                if (snapshots.isEmpty)
                  const _EmptyHistory()
                else
                  for (final snapshot in snapshots) ...[
                    _SnapshotCard(snapshot: snapshot),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SnapshotHistoryState {
  const _SnapshotHistoryState({required this.snapshots, required this.export});

  const _SnapshotHistoryState.empty() : snapshots = const [], export = const [];

  final List<SignalSnapshot> snapshots;
  final List<Map<String, Object?>> export;
}

class _HistoryActions extends StatelessWidget {
  const _HistoryActions({
    required this.onDeleteExpired,
    required this.onClearAll,
  });

  final VoidCallback onDeleteExpired;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onDeleteExpired,
          icon: const Icon(Icons.auto_delete),
          label: const Text('Purge Expired'),
        ),
        OutlinedButton.icon(
          onPressed: onClearAll,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear All Debug'),
        ),
      ],
    );
  }
}

class _PrivacySafeExportPreview extends StatelessWidget {
  const _PrivacySafeExportPreview({required this.export});

  final List<Map<String, Object?>> export;

  @override
  Widget build(BuildContext context) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(export);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy-safe export preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Normal exports include idHash values and exclude rawIdProtected fields.',
            ),
            const SizedBox(height: 12),
            SelectableText(prettyJson),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'No local snapshots yet. Use Create Test Snapshot on Home to generate mock QA data.',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.snapshot});

  final SignalSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final location = snapshot.locationObservation;
    final wifi = snapshot.wifiObservation;
    final timeRemaining = snapshot.retentionExpiresAt.difference(
      DateTime.now(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(snapshot.id, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Created: ${snapshot.createdAt.toLocal()}'),
            Text('Retention expires: ${snapshot.retentionExpiresAt.toLocal()}'),
            Text('Retention remaining: ${_formatDuration(timeRemaining)}'),
            Text('BLE observations: ${snapshot.bleObservations.length}'),
            if (wifi != null) Text('Wi-Fi context hash: ${wifi.idHash}'),
            if (location != null)
              Text(
                'Location: ${location.latitude}, ${location.longitude} (+/- ${location.accuracyMeters}m)',
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return 'expired';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
