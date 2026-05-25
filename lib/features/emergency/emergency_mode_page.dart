import 'package:flutter/material.dart';

import '../../core/models/emergency_case.dart';
import '../shared/app_scaffold.dart';

class EmergencyModePage extends StatelessWidget {
  const EmergencyModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockCase = EmergencyCase(
      id: 'case_draft_local',
      personDisplayName: 'Protected person profile',
      guardianDisplayName: 'Local guardian profile',
      status: EmergencyCaseStatus.draft,
      createdAt: DateTime.now(),
      snapshotIds: const [],
      auditEventIds: const [],
    );

    return AppScaffold(
      title: 'Emergency Mode',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guardian-authorized emergency package',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This placeholder prepares the workflow for verified emergencies. It does not create law-enforcement access, carrier requests, or covert tracking.',
                  ),
                  const SizedBox(height: 16),
                  Text('Case: ${mockCase.id}'),
                  Text('Person: ${mockCase.personDisplayName}'),
                  Text('Guardian: ${mockCase.guardianDisplayName}'),
                  Text('Status: ${mockCase.status.name}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Emergency escalation must be consent-based, guardian-authorized, verified, and audited before any sensitive data is shared.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
