import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'rssi_bar.dart';
import '../pages/device_details_page.dart';
import '../config/lora_config.dart';
import '../config/manufacturer_db.dart';
import '../services/device_status_store.dart';

import '../l10n/app_localizations.dart';

class DeviceTile extends StatefulWidget {
  final ScanResult result;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const DeviceTile({
    super.key,
    required this.result,
    this.onToggleTheme,
    this.themeMode,
    this.onOpenSettings,
  });

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  bool _connecting = false;
  bool _connected = false;
  StreamSubscription<DeviceStatus>? _sub;
  int? _rssi; // live RSSI from DeviceStatusStore while connected

  ScanResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    _subscribeStatus();
  }

  @override
  void didUpdateWidget(covariant DeviceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result.device.remoteId.str !=
        widget.result.device.remoteId.str) {
      _sub?.cancel();
      _connecting = false;
      _connected = false;
      _subscribeStatus();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _subscribeStatus() {
    final id = widget.result.device.remoteId.str;
    _sub = DeviceStatusStore.instance.statusStream(id).listen((s) {
      if (!mounted) return;
      setState(() {
        _connecting = s.state == DeviceConnectionState.connecting;
        _connected = s.state == DeviceConnectionState.connected;
        _rssi = s.rssi ?? _rssi; // keep last known value if null
      });
    });
  }

  Future<void> _connect() async {
    if (_connected || _connecting) return;
    setState(() => _connecting = true);
    try {
      // Get device name (same logic as build method for consistency)
      final name = result.advertisementData.advName.isNotEmpty
          ? result.advertisementData.advName
          : (widget.result.device.platformName.isNotEmpty
                ? widget.result.device.platformName
                : widget.result.device.remoteId.str);

      await DeviceStatusStore.instance.connect(
        widget.result.device,
        deviceName: name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).connectFailedError(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    if (!_connected && !_connecting) return;
    setState(() => _connecting = true);
    try {
      await DeviceStatusStore.instance.disconnect(
        widget.result.device.remoteId.str,
      );
    } catch (_) {
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = result.device;
    final t = AppLocalizations.of(context);
    final name = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : (device.platformName.isNotEmpty
              ? device.platformName
              : device.remoteId.str);
    final lora = isLoraDevice(result);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _iconFor(result),
        title: Row(
          children: [
            Expanded(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (lora) ...[
              const SizedBox(width: 8),
              const Icon(Icons.sensors, size: 16, color: Colors.deepOrange),
              const SizedBox(width: 4),
              Text(
                t.meshtasticLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.remoteId.str,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            _manufacturerLine(context, result),
            const SizedBox(height: 4),
            RssiBar(rssi: _rssi ?? result.rssi),
          ],
        ),
        trailing: result.advertisementData.connectable
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_connecting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_connecting) const SizedBox(width: 8),
                  Tooltip(
                    message: _connected ? t.disconnect : t.connect,
                    child: FilledButton.tonalIcon(
                      onPressed: _connecting
                          ? null
                          : (_connected ? _disconnect : _connect),
                      icon: Icon(_connected ? Icons.link_off : Icons.link),
                      label: Text(_connected ? t.disconnect : t.connect),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DeviceDetailsPage(
                device: result.device,
                scanResult: result,
                onToggleTheme: widget.onToggleTheme,
                themeMode: widget.themeMode,
                onOpenSettings: widget.onOpenSettings,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _manufacturerLine(BuildContext context, ScanResult r) {
    final ids = r.advertisementData.manufacturerData.keys.toList();
    if (ids.isEmpty) return const SizedBox.shrink();
    final id = ids.first;
    final name = ManufacturerDb.nameNow(id);
    final t = AppLocalizations.of(context);
    final idHex = '0x${id.toRadixString(16).padLeft(4, '0').toUpperCase()}';
    final text = name ?? t.unknown;
    final suffix = ids.length > 1 ? ' (+${ids.length - 1})' : '';
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Text(
        '$text ($idHex)$suffix',
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      backgroundColor: Colors.indigo.withValues(alpha: 0.1),
      child: Icon(icon, color: Colors.indigo),
    );
  }
}
