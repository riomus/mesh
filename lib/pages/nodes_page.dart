import 'package:flutter/material.dart';

import '../widgets/nodes_list_widget.dart';
import '../widgets/mesh_app_bar.dart';

/// Nodes page that hosts the reusable NodesListWidget component.
class NodesPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const NodesPage({super.key, this.onToggleTheme, this.themeMode, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeshAppBar(
        title: const Text('Nodes'),
        onToggleTheme: onToggleTheme,
        themeMode: themeMode,
        onOpenSettings: onOpenSettings,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: NodesListWidget(),
      ),
    );
  }
}
