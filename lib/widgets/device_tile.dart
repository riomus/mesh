import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'rssi_bar.dart';

class DeviceTile extends StatelessWidget {
  final ScanResult result;
  const DeviceTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final device = result.device;
    final name = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : (device.platformName.isNotEmpty
            ? device.platformName
            : device.remoteId.str);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _iconFor(result),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.remoteId.str,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            RssiBar(rssi: result.rssi),
          ],
        ),
        trailing: result.advertisementData.connectable
            ? const Chip(
                avatar: Icon(Icons.link, size: 16),
                label: Text('Connectable'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _iconFor(ScanResult r) {
    final name = r.advertisementData.advName.toLowerCase();
    IconData icon = Icons.bluetooth;
    if (name.contains('head') || name.contains('buds')) {
      icon = Icons.headphones;
    } else if (name.contains('watch')) {
      icon = Icons.watch;
    } else if (name.contains('phone')) {
      icon = Icons.phone_android;
    }
    return CircleAvatar(
      backgroundColor: Colors.indigo.withOpacity(0.1),
      child: Icon(icon, color: Colors.indigo),
    );
  }
}
