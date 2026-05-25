import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/audit_log_service.dart';
import '../core/services/ble_scan_service.dart';
import '../core/services/location_service.dart';
import '../core/services/network_context_service.dart';
import '../core/services/protected_export_service.dart';
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
  late final Future<_AppServices> _services;

  @override
  void initState() {
    super.initState();
    _services = _createServices();
  }

  Future<_AppServices> _createServices() async {
    final preferences = await SharedPreferences.getInstance();
    final auditLogService = InMemoryAuditLogService();
    final snapshotService = LocalSnapshotService(
      bleScanService: MockBleScanService(),
      networkContextService: MockNetworkContextService(),
      locationService: MockLocationService(),
      retentionService: DefaultRetentionService(),
      auditLogService: auditLogService,
      snapshotStorageService: SharedPreferencesSnapshotStorageService(
        preferences,
      ),
    );
    await snapshotService.initialize();
    return _AppServices(
      snapshotService: snapshotService,
      auditLogService: auditLogService,
      protectedExportService: MockProtectedExportService(
        auditLogService: auditLogService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppServices>(
      future: _services,
      builder: (context, snapshot) {
        final services = snapshot.data;
        if (services == null) {
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
          snapshotService: services.snapshotService,
          auditLogService: services.auditLogService,
          protectedExportService: services.protectedExportService,
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

class _AppServices {
  const _AppServices({
    required this.snapshotService,
    required this.auditLogService,
    required this.protectedExportService,
  });

  final SnapshotService snapshotService;
  final AuditLogService auditLogService;
  final ProtectedExportService protectedExportService;
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
    required this.auditLogService,
    required this.protectedExportService,
    required super.child,
    super.key,
  });

  final SnapshotService snapshotService;
  final AuditLogService auditLogService;
  final ProtectedExportService protectedExportService;

  static SnapshotService snapshotsOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SnapshotScope>();
    assert(scope != null, 'SnapshotScope is missing from the widget tree.');
    return scope!.snapshotService;
  }

  static AuditLogService auditOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SnapshotScope>();
    assert(scope != null, 'SnapshotScope is missing from the widget tree.');
    return scope!.auditLogService;
  }

  static ProtectedExportService protectedExportsOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SnapshotScope>();
    assert(scope != null, 'SnapshotScope is missing from the widget tree.');
    return scope!.protectedExportService;
  }

  @override
  bool updateShouldNotify(SnapshotScope oldWidget) {
    return snapshotService != oldWidget.snapshotService ||
        auditLogService != oldWidget.auditLogService ||
        protectedExportService != oldWidget.protectedExportService;
  }
}
