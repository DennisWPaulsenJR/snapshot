import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/router.dart';
import '../shared/app_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isCreating = false;

  Future<void> _createSnapshot() async {
    setState(() => _isCreating = true);
    final service = SnapshotScope.snapshotsOf(context);
    final snapshot = await service.createTestSnapshot();
    if (!mounted) {
      return;
    }
    setState(() => _isCreating = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Created ${snapshot.id}')));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Snapshot Safety',
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Consent-based emergency signal snapshots',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Create local mock snapshots for QA without real BLE scanning, raw MAC collection, cloud sync, or background tracking.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isCreating ? null : _createSnapshot,
            icon: _isCreating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_location_alt),
            label: const Text('Create Test Snapshot'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.snapshots);
            },
            icon: const Icon(Icons.history),
            label: const Text('View Snapshot History'),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Privacy baseline: this MVP uses mock services, hashed identifiers, explicit user action, and 72-hour normal snapshot retention.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
