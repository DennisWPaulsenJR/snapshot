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
  late Future<List<SignalSnapshot>> _snapshots;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _snapshots = SnapshotScope.snapshotsOf(context).listSnapshots();
  }

  Future<void> _refresh() async {
    setState(() {
      _snapshots = SnapshotScope.snapshotsOf(context).listSnapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Snapshot History',
      currentIndex: 2,
      child: FutureBuilder<List<SignalSnapshot>>(
        future: _snapshots,
        builder: (context, snapshot) {
          final snapshots = snapshot.data ?? const <SignalSnapshot>[];
          if (snapshots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No local snapshots yet. Use Create Test Snapshot on Home to generate mock QA data.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: snapshots.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _SnapshotCard(snapshot: snapshots[index]);
              },
            ),
          );
        },
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
            Text('BLE observations: ${snapshot.bleObservations.length}'),
            if (wifi != null) Text('Wi-Fi context: ${wifi.hashedNetworkId}'),
            if (location != null)
              Text(
                'Location: ${location.latitude}, ${location.longitude} (+/- ${location.accuracyMeters}m)',
              ),
          ],
        ),
      ),
    );
  }
}
