import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../l10n/app_localizations.dart';

class MeshAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  final List<Widget>? extraActions;

  const MeshAppBar({
    super.key,
    required this.title,
    this.onToggleTheme,
    this.themeMode,
    this.onOpenSettings,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppBar(
      title: title,
      actions: [
        if (extraActions != null) ...extraActions!,
        // Bluetooth adapter state indicator
        StreamBuilder<BluetoothAdapterState>(
          stream: FlutterBluePlus.adapterState,
          initialData: FlutterBluePlus.adapterStateNow,
          builder: (context, snapshot) {
            final state = snapshot.data;
            IconData icon;
            Color color;
            String tooltip;
            switch (state) {
              case BluetoothAdapterState.on:
                icon = Icons.bluetooth_connected;
                color = Colors.green;
                tooltip = t.bluetoothOn;
                break;
              case BluetoothAdapterState.off:
                icon = Icons.bluetooth_disabled;
                color = Colors.red;
                tooltip = t.bluetoothOff;
                break;
              default:
                final name = state?.name ?? t.unknown;
                icon = Icons.bluetooth;
                color = Colors.orange;
                tooltip = t.bluetoothState(name);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Tooltip(
                message: tooltip,
                child: Icon(icon, color: color),
              ),
            );
          },
        ),
        // Theme toggle
        if (onToggleTheme != null)
          IconButton(
            icon: Icon(
              // Use effective brightness if ThemeMode.system
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: t.toggleThemeTooltip,
            onPressed: onToggleTheme,
          ),
        // Settings shortcut
        if (onOpenSettings != null)
          IconButton(
            tooltip: t.settingsButtonLabel,
            icon: const Icon(Icons.settings),
            onPressed: () => onOpenSettings!.call(context),
          ),
      ],
    );
  }
}
