import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/adapter_banner.dart';
import '../widgets/device_tile.dart';
import '../widgets/empty_state.dart';

class ScannerPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  const ScannerPage({super.key, this.onToggleTheme, this.themeMode});

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
    if (kIsWeb) return;

    final requests = <Permission>[];
    if (Theme.of(context).platform == TargetPlatform.android) {
      requests.addAll([
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ]);
      requests.add(Permission.locationWhenInUse); // for pre-Android 12
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      requests.add(Permission.bluetooth);
    }

    await requests.request();
  }

  Future<void> _startScan() async {
    await _ensurePermissions();
    setState(() => _scanning = true);
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
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle dark mode',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          const AdapterBanner(),
          Expanded(
            child: devices.isEmpty
                ? const EmptyState()
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final r = devices[index];
                      return DeviceTile(result: r);
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
