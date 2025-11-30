import 'package:flutter/material.dart';

import '../widgets/logs_viewer.dart';
import '../widgets/mesh_app_bar.dart';

/// Logs page that hosts the reusable LogsViewer component.
class LogsPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const LogsPage({super.key, this.onToggleTheme, this.themeMode, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeshAppBar(
        title: const Text('Logs'),
        onToggleTheme: onToggleTheme,
        themeMode: themeMode,
        onOpenSettings: onOpenSettings,
      ),
      body: const LogsViewer(),
    );
  }
}