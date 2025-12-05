import 'package:flutter/material.dart';

import '../widgets/nodes_list_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../widgets/nodes_map_widget.dart';
import '../l10n/app_localizations.dart';
import '../models/trace_models.dart';

/// Nodes page that hosts the reusable NodesListWidget component.
class NodesPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  final TraceResult? highlightedTrace;
  final int? initialTabIndex;

  const NodesPage({
    super.key,
    this.onToggleTheme,
    this.themeMode,
    this.onOpenSettings,
    this.highlightedTrace,
    this.initialTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex ?? 0,
      child: Scaffold(
        appBar: MeshAppBar(
          title: Text(AppLocalizations.of(context).nodesTitle),
          onToggleTheme: onToggleTheme,
          themeMode: themeMode,
          onOpenSettings: onOpenSettings,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.list),
                text: AppLocalizations.of(context).tabList,
              ),
              Tab(
                icon: const Icon(Icons.map),
                text: AppLocalizations.of(context).tabMap,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(padding: EdgeInsets.all(8.0), child: NodesListWidget()),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: NodesMapWidget(
                highlightedTrace: highlightedTrace,
                showAllNodes:
                    highlightedTrace ==
                    null, // Only show trace nodes when viewing a trace
              ),
            ),
          ],
        ),
      ),
    );
  }
}
