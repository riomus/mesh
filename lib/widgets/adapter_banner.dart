import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../l10n/app_localizations.dart';
class AdapterBanner extends StatelessWidget {
  const AdapterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
      stream: FlutterBluePlus.adapterState,
      initialData: FlutterBluePlus.adapterStateNow,
      builder: (context, snapshot) {
        final state = snapshot.data;
        String text;
        IconData icon;
        Color color;
        switch (state) {
          case BluetoothAdapterState.on:
            text = AppLocalizations.of(context)!.bluetoothOn;
            icon = Icons.bluetooth_connected;
            color = Colors.green;
            break;
          case BluetoothAdapterState.off:
            text = AppLocalizations.of(context)!.bluetoothOff;
            icon = Icons.bluetooth_disabled;
            color = Colors.red;
            break;
          default:
            final name = state?.name ?? AppLocalizations.of(context)!.unknown;
            text = AppLocalizations.of(context)!.bluetoothState(name);
            icon = Icons.bluetooth;
            color = Colors.orange;
        }
        return Material(
          color: color.withOpacity(0.1),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(text),
            subtitle: Text(AppLocalizations.of(context)!.webNote),
          ),
        );
      },
    );
  }
}
