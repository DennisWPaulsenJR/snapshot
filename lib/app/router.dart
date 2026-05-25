import 'package:flutter/material.dart';

import '../features/devices/devices_page.dart';
import '../features/emergency/emergency_mode_page.dart';
import '../features/home/home_page.dart';
import '../features/protected_export/protected_export_review_page.dart';
import '../features/settings/settings_page.dart';
import '../features/snapshots/snapshot_history_page.dart';

class AppRoutes {
  static const home = '/';
  static const emergency = '/emergency';
  static const snapshots = '/snapshots';
  static const devices = '/devices';
  static const protectedExport = '/protected-export';
  static const settings = '/settings';
}

Map<String, WidgetBuilder> buildAppRoutes() {
  return {
    AppRoutes.home: (_) => const HomePage(),
    AppRoutes.emergency: (_) => const EmergencyModePage(),
    AppRoutes.snapshots: (_) => const SnapshotHistoryPage(),
    AppRoutes.devices: (_) => const DevicesPage(),
    AppRoutes.protectedExport: (_) => const ProtectedExportReviewPage(),
    AppRoutes.settings: (_) => const SettingsPage(),
  };
}
