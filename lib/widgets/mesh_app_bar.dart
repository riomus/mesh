import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../l10n/app_localizations.dart';
import '../services/device_status_store.dart';
import '../pages/device_details_page.dart';

class MeshAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  final List<Widget>? extraActions;
  final PreferredSizeWidget? bottom;

  const MeshAppBar({
    super.key,
    required this.title,
    this.onToggleTheme,
    this.themeMode,
    this.onOpenSettings,
    this.extraActions,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AppBar(
      title: title,
      bottom: bottom,
      actions: [
        if (extraActions != null) ...extraActions!,
        // Connected devices indicator (scrollable)
        StreamBuilder<List<BluetoothDevice>>(
          stream: DeviceStatusStore.instance.connectedDevicesStream,
          initialData: DeviceStatusStore.instance.connectedDevices,
          builder: (context, snapshot) {
            final devices = snapshot.data ?? [];
            if (devices.isEmpty) return const SizedBox.shrink();

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final device in devices)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(
                          avatar: const Icon(Icons.link, size: 16),
                          label: Text(
                            device.platformName.isNotEmpty
                                ? device.platformName
                                : device.remoteId.str,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DeviceDetailsPage(
                                  device: device,
                                  onToggleTheme: onToggleTheme,
                                  themeMode: themeMode,
                                  onOpenSettings: onOpenSettings,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
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
