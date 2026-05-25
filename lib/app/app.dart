import 'package:flutter/material.dart';

import '../core/services/audit_log_service.dart';
import '../core/services/ble_scan_service.dart';
import '../core/services/location_service.dart';
import '../core/services/network_context_service.dart';
import '../core/services/retention_service.dart';
import '../core/services/snapshot_service.dart';
import 'router.dart';

class SnapshotApp extends StatefulWidget {
  const SnapshotApp({super.key});

  @override
  State<SnapshotApp> createState() => _SnapshotAppState();
}

class _SnapshotAppState extends State<SnapshotApp> {
  late final SnapshotService snapshotService;

  @override
  void initState() {
    super.initState();
    final auditLogService = InMemoryAuditLogService();
    snapshotService = InMemorySnapshotService(
      bleScanService: MockBleScanService(),
      networkContextService: MockNetworkContextService(),
      locationService: MockLocationService(),
      retentionService: DefaultRetentionService(),
      auditLogService: auditLogService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SnapshotScope(
      snapshotService: snapshotService,
      child: MaterialApp(
        title: 'Snapshot Safety',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.home,
        routes: buildAppRoutes(),
      ),
    );
  }
}

class SnapshotScope extends InheritedWidget {
  const SnapshotScope({
    required this.snapshotService,
    required super.child,
    super.key,
  });

  final SnapshotService snapshotService;

  static SnapshotService snapshotsOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SnapshotScope>();
    assert(scope != null, 'SnapshotScope is missing from the widget tree.');
    return scope!.snapshotService;
  }

  @override
  bool updateShouldNotify(SnapshotScope oldWidget) {
    return snapshotService != oldWidget.snapshotService;
  }
}
