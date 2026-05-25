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
                'Mock BLE and Wi-Fi identifiers are hashed labels. Raw MAC storage is out of scope.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.fact_check),
              title: Text('Emergency review'),
              subtitle: Text(
                'Escalation requires guardian authority, verification, and audit records.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
