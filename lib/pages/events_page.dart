import 'package:flutter/material.dart';

import '../widgets/events_list_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../l10n/app_localizations.dart';

/// Events page that hosts the reusable EventsListWidget component.
class EventsPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const EventsPage({super.key, this.onToggleTheme, this.themeMode, this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeshAppBar(
        title: Text(AppLocalizations.of(context).eventsTitle),
        onToggleTheme: onToggleTheme,
        themeMode: themeMode,
        onOpenSettings: onOpenSettings,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: EventsListWidget(),
      ),
    );
  }
}
