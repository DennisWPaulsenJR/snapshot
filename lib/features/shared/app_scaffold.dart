import 'package:flutter/material.dart';

import '../../app/router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.currentIndex,
    required this.child,
    super.key,
  });

  final String title;
  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          final route = switch (index) {
            0 => AppRoutes.home,
            1 => AppRoutes.emergency,
            2 => AppRoutes.snapshots,
            3 => AppRoutes.devices,
            _ => AppRoutes.settings,
          };
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.emergency),
            label: 'Emergency',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.sensors), label: 'Devices'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
