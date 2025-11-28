import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesh BLE Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  StreamSubscription<List<ScanResult>>? _sub;
  bool _scanning = false;
  final Map<DeviceIdentifier, ScanResult> _results = {};

  @override
  void initState() {
    super.initState();
    // Listen for results to update UI.
    _sub = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (final r in results) {
          _results[r.device.remoteId] = r;
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _ensurePermissions() async {
    // On Web, permissions are handled by the browser (via user gesture dialog).
    if (kIsWeb) return;

    // Android/iOS permissions
    final requests = <Permission>[];
    if (Theme.of(context).platform == TargetPlatform.android) {
      requests.addAll([
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ]);
      // Pre Android 12 needs location for BLE scan
      requests.add(Permission.locationWhenInUse);
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      requests.add(Permission.bluetooth);
    }

    await requests.request();
  }

  Future<void> _startScan() async {
    await _ensurePermissions();
    setState(() => _scanning = true);
    // 10 second scan timeout by default, allow duplicates for RSSI updates.
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    setState(() => _scanning = false);
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final devices = _results.values.toList()
      ..sort((a, b) => (b.rssi).compareTo(a.rssi));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Bluetooth Devices'),
        actions: [
          IconButton(
            icon: Icon(_scanning ? Icons.stop : Icons.refresh),
            tooltip: _scanning ? 'Stop' : 'Scan',
            onPressed: _scanning ? _stopScan : _startScan,
          )
        ],
      ),
      body: Column(
        children: [
          _Banner(),
          Expanded(
            child: devices.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final r = devices[index];
                      return _DeviceTile(result: r);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? _stopScan : _startScan,
        icon: Icon(_scanning ? Icons.stop : Icons.search),
        label: Text(_scanning ? 'Stop' : 'Scan'),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
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

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  const _DeviceTile({required this.result});

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
            _RssiBar(rssi: result.rssi),
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
    // Simple heuristic: pick icon based on common service UUIDs or name hints.
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

class _RssiBar extends StatelessWidget {
  final int rssi; // typically [-100..-20]
  const _RssiBar({required this.rssi});

  int get bars {
    if (rssi >= -50) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= 4; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              Icons.signal_cellular_alt,
              size: 16 + (i * 2),
              color: i <= bars ? Colors.green : Colors.grey.shade300,
            ),
          ),
        const SizedBox(width: 8),
        Text('$rssi dBm', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_searching,
              size: 48, color: Colors.indigo.withOpacity(0.6)),
          const SizedBox(height: 12),
          const Text('Tap Scan to discover nearby Bluetooth devices'),
        ],
      ),
    );
  }
}
