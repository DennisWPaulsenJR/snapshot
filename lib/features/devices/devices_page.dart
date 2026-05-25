import 'package:flutter/material.dart';

import '../../core/models/safety_device.dart';
import '../../core/security/identifier_protection.dart';
import '../shared/app_scaffold.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const identifierProtection = IdentifierProtection();
    final localPhone = identifierProtection.protectMockIdentifier(
      'mock_local_app_device',
    );
    final mockBeacon = identifierProtection.protectMockIdentifier(
      'mock_ble_family_beacon_01',
    );
    final devices = [
      SafetyDevice(
        id: 'device_local_phone',
        displayName: 'Local phone profile',
        type: SafetyDeviceType.phone,
        idHash: localPhone.idHash,
        rawIdProtected: localPhone.rawIdProtected,
        registeredAt: DateTime.now().subtract(const Duration(days: 1)),
        consentConfirmed: true,
      ),
      SafetyDevice(
        id: 'device_mock_beacon',
        displayName: 'Mock backpack beacon',
        type: SafetyDeviceType.bleBeacon,
        idHash: mockBeacon.idHash,
        rawIdProtected: mockBeacon.rawIdProtected,
        registeredAt: DateTime.now(),
        consentConfirmed: true,
      ),
    ];

    return AppScaffold(
      title: 'Devices',
      currentIndex: 3,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _ConsentNotice();
          }
          final device = devices[index - 1];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.sensors),
              title: Text(device.displayName),
              subtitle: Text('${device.type.name} | id hash: ${device.idHash}'),
              trailing: Icon(
                device.consentConfirmed ? Icons.verified_user : Icons.warning,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConsentNotice extends StatelessWidget {
  const _ConsentNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Devices shown here are mock registered safety devices. The system materially reduces misuse risk while preserving emergency evidentiary value. Raw identifiers are never shown in normal UI.',
        ),
      ),
    );
  }
}
