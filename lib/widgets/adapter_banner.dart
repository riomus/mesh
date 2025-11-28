import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
            text = 'Bluetooth is ON';
            icon = Icons.bluetooth_connected;
            color = Colors.green;
            break;
          case BluetoothAdapterState.off:
            text = 'Bluetooth is OFF';
            icon = Icons.bluetooth_disabled;
            color = Colors.red;
            break;
          default:
            text = 'Bluetooth state: ${state?.name ?? 'unknown'}';
            icon = Icons.bluetooth;
            color = Colors.orange;
        }
        return Material(
          color: color.withOpacity(0.1),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(text),
            subtitle: const Text(
                'On Web, scanning shows a chooser after tapping Scan (HTTPS required).'),
          ),
        );
      },
    );
  }
}
