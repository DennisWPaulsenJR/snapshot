import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/audit_log_service.dart';
import '../core/services/ble_scan_service.dart';
import '../core/services/location_service.dart';
import '../core/services/network_context_service.dart';
import '../core/services/retention_service.dart';
import '../core/services/snapshot_service.dart';
import '../core/storage/snapshot_storage_service.dart';
import 'router.dart';

class SnapshotApp extends StatefulWidget {
  const SnapshotApp({super.key});

  @override
  State<SnapshotApp> createState() => _SnapshotAppState();
}

class _SnapshotAppState extends State<SnapshotApp> {
  late final Future<SnapshotService> _snapshotService;

  @override
  void initState() {
    super.initState();
    _snapshotService = _createSnapshotService();
  }

  Future<SnapshotService> _createSnapshotService() async {
    final preferences = await SharedPreferences.getInstance();
    final auditLogService = InMemoryAuditLogService();
    final service = LocalSnapshotService(
      bleScanService: MockBleScanService(),
      networkContextService: MockNetworkContextService(),
      locationService: MockLocationService(),
      retentionService: DefaultRetentionService(),
      auditLogService: auditLogService,
      snapshotStorageService: SharedPreferencesSnapshotStorageService(
        preferences,
      ),
    );
    await service.initialize();
    return service;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SnapshotService>(
      future: _snapshotService,
      builder: (context, snapshot) {
        final service = snapshot.data;
        if (service == null) {
          return MaterialApp(
            title: 'Snapshot Safety',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            home: const _LoadingPage(),
          );
        }

        return SnapshotScope(
          snapshotService: service,
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
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
