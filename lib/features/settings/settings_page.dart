import 'package:flutter/material.dart';

import '../shared/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings & Consent',
      currentIndex: 4,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Consent mode: local profile only. The app does not run silent tracking, cloud sync, or real sensor access in this MVP.',
              ),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.security),
              title: Text('Misuse risk model'),
              subtitle: Text(
                'The system materially reduces misuse risk while preserving emergency evidentiary value.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.timer),
              title: Text('Default retention'),
              subtitle: Text('Normal mock snapshots expire after 72 hours.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Identifier handling'),
              subtitle: Text(
                'Mock BLE and Wi-Fi identifiers are represented as salted session hashes. Protected raw fields are internal only and never displayed.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.fact_check),
              title: Text('Emergency review'),
              subtitle: Text(
                'Raw export requires guardian authority, verified emergency/legal workflow, encryption controls, and audit records.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
