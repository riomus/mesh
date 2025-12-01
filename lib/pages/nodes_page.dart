import 'package:flutter/material.dart';

import '../widgets/nodes_list_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../widgets/nodes_map_widget.dart';

/// Nodes page that hosts the reusable NodesListWidget component.
class NodesPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const NodesPage({super.key, this.onToggleTheme, this.themeMode, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: MeshAppBar(
          title: const Text('Nodes'),
          onToggleTheme: onToggleTheme,
          themeMode: themeMode,
          onOpenSettings: onOpenSettings,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'List'),
              Tab(icon: Icon(Icons.map), text: 'Map'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Padding(padding: EdgeInsets.all(8.0), child: NodesListWidget()),
            Padding(padding: EdgeInsets.all(8.0), child: NodesMapWidget()),
          ],
        ),
      ),
    );
  }
}
