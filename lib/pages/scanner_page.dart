import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../services/meshtastic_ble_client.dart';
import '../services/recent_devices_service.dart';
import '../widgets/device_tile.dart';
import '../widgets/empty_state.dart';
import '../config/lora_config.dart';
import '../config/manufacturer_db.dart';
import '../config/version_info.dart';
import '../widgets/mesh_app_bar.dart';
import '../services/device_status_store.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class ScannerPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const ScannerPage({
    super.key,
    this.onToggleTheme,
    this.themeMode,
    this.onOpenSettings,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  StreamSubscription<List<ScanResult>>? _sub;
  bool _scanning = false;
  final Map<DeviceIdentifier, ScanResult> _results = {};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;
  bool _loraOnly = false; // ticker: show only LoRa devices by default

  void initState() {
    super.initState();
    _refreshSerialPorts();
    _sub = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        for (final r in results) {
          _results[r.device.remoteId] = r;
        }
      });
    });
    // Warm up LoRa config (async). When loaded, refresh list.
    // Ignore errors; defaults will be used.
    // Delayed to next event loop to avoid setState during build warnings.
    Future.microtask(() async {
      try {
        // lazy-load config
        await LoraConfig.ensureLoaded();
        // Also warm up Manufacturer database for company identifiers
        await ManufacturerDb.ensureLoaded();
        // Load app version info (from assets)
        await VersionInfo.ensureLoaded();

        // Load recent devices
        await RecentDevicesService.instance.load();

        if (mounted) setState(() {});
      } catch (_) {
        // ignore
      }
    });

    // Subscribe to recent devices updates
    RecentDevicesService.instance.devicesStream.listen((devices) {
      if (mounted) setState(() {});
    });
  }

  final TextEditingController _ipHostController = TextEditingController();
  final TextEditingController _ipPortController = TextEditingController(
    text: '4403',
  );
  bool _ipConnecting = false;

  // USB State
  List<String> _serialPorts = [];
  String? _selectedPort;
  bool _usbConnecting = false;

  @override
  void dispose() {
    _sub?.cancel();
    _debounce?.cancel();
    _searchController.dispose();
    _ipHostController.dispose();
    _ipPortController.dispose();
    super.dispose();
  }

  Future<void> _ensurePermissions() async {
    // Web & desktop (macOS, Windows, Linux) do not use runtime permissions.
    if (kIsWeb) return;

    final platform = Theme.of(context).platform;
    // Only Android/iOS need runtime permission requests via permission_handler.
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return; // e.g., macOS → avoid calling into permission_handler (not implemented)
    }

    final requests = <Permission>[];
    if (platform == TargetPlatform.android) {
      requests.addAll([Permission.bluetoothScan, Permission.bluetoothConnect]);
      requests.add(Permission.locationWhenInUse); // for pre-Android 12
    } else if (platform == TargetPlatform.iOS) {
      requests.add(Permission.bluetooth);
    }

    if (requests.isEmpty)
      return; // Safety: do not invoke plugin with empty list
    await requests.request();
  }

  Future<void> _startScan() async {
    await _ensurePermissions();
    setState(() => _scanning = true);
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      webOptionalServices: [Guid(MeshtasticBleClient.serviceUuid)],
    );
    // Listen for scan completion and update UI
    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 1));
    }
    FlutterBluePlus.isScanning.listen((isScanning) {
      if (mounted) {
        setState(() {
          _scanning = isScanning;
        });
      }
    });
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => _scanning = false);
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _query = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    // Combine scan results with recent devices
    final recentDevices = RecentDevicesService.instance.currentDevices;
    final Map<String, ScanResult> allDevices = {};

    // Add recent devices first (converted to ScanResult)
    for (final rd in recentDevices) {
      allDevices[rd.id] = rd.toScanResult();
    }

    for (final r in _results.values) {
      allDevices[r.device.remoteId.str] = r;
    }

    final base = _filteredDevices(allDevices.values, _query);

    // Sort: Recent devices first (by last connected time), then others by RSSI
    final recentIds = recentDevices.map((d) => d.id).toSet();

    final devices = (_loraOnly ? base.where(isLoraDevice).toList() : base)
      ..sort((a, b) {
        final aIsRecent = recentIds.contains(a.device.remoteId.str);
        final bIsRecent = recentIds.contains(b.device.remoteId.str);

        if (aIsRecent && !bIsRecent) return -1;
        if (!aIsRecent && bIsRecent) return 1;

        if (aIsRecent && bIsRecent) {
          final aRecent = recentDevices.firstWhere(
            (d) => d.id == a.device.remoteId.str,
          );
          final bRecent = recentDevices.firstWhere(
            (d) => d.id == b.device.remoteId.str,
          );
          return bRecent.lastConnected.compareTo(aRecent.lastConnected);
        }

        return b.rssi.compareTo(a.rssi);
      });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: MeshAppBar(
          title: Text(t.nearbyDevicesTitle),
          onToggleTheme: widget.onToggleTheme,
          themeMode: widget.themeMode,
          onOpenSettings: widget.onOpenSettings,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'BLE', icon: Icon(Icons.bluetooth)),
              Tab(text: 'IP', icon: Icon(Icons.wifi)),
              Tab(text: 'USB', icon: Icon(Icons.usb)),
            ],
          ),
          extraActions: [
            if (VersionInfo.instance != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Tooltip(
                    message:
                        '${t.buildPrefix}${VersionInfo.instance!.displayDescribe}'
                        '${VersionInfo.instance!.buildTimeUtc != null ? '\n${t.builtPrefix}${VersionInfo.instance!.buildTimeUtc!.toIso8601String()}' : ''}',
                    child: Text(
                      VersionInfo.instance!.displayDescribe,
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                _scanning ? Icons.stop : Icons.refresh,
                color: _scanning ? Colors.red : null,
              ),
              tooltip: _scanning ? t.stop : t.scan,
              onPressed: _scanning ? _stopScan : _startScan,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildBleTab(context, t, devices),
            _buildIpTab(context, t),
            _buildUsbTab(context, t),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _scanning ? _stopScan : _startScan,
          icon: Icon(_scanning ? Icons.stop : Icons.search),
          label: Text(_scanning ? t.stop : t.scan),
        ),
      ),
    );
  }

  Widget _buildBleTab(
    BuildContext context,
    AppLocalizations t,
    List<ScanResult> devices,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final searchField = TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: t.searchHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).deleteButtonTooltip,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onQueryChanged('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _onQueryChanged,
                );

                final filterChip = FilterChip(
                  label: Text(t.loraOnlyFilterLabel),
                  avatar: Icon(
                    Icons.sensors,
                    color: _loraOnly
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  selected: _loraOnly,
                  showCheckmark: false,
                  onSelected: (v) => setState(() => _loraOnly = v),
                );

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchField,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerLeft, child: filterChip),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: searchField),
                      const SizedBox(width: 8),
                      filterChip,
                    ],
                  );
                }
              },
            ),
          ),
        ),
        Expanded(
          child: devices.isEmpty
              ? const EmptyState()
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final r = devices[index];
                    return DeviceTile(
                      result: r,
                      onToggleTheme: widget.onToggleTheme,
                      themeMode: widget.themeMode,
                      onOpenSettings: widget.onOpenSettings,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIpTab(BuildContext context, AppLocalizations t) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.connectToIpDevice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ipHostController,
                decoration: InputDecoration(
                  labelText: t.hostInputLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.computer),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ipPortController,
                decoration: InputDecoration(
                  labelText: t.portInputLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _ipConnecting ? null : _connectIp,
                icon: _ipConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(_ipConnecting ? t.statusConnecting : t.connect),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _connectIp() async {
    final host = _ipHostController.text.trim();
    final portText = _ipPortController.text.trim();
    final port = int.tryParse(portText);

    if (host.isEmpty || port == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).invalidHostPort)),
      );
      return;
    }

    setState(() => _ipConnecting = true);

    try {
      await DeviceStatusStore.instance.connectIp(host, port);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).connectedToIpDevice),
          ),
        );
      }
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
      if (mounted) {
        setState(() => _ipConnecting = false);
      }
    }
  }

  Future<void> _refreshSerialPorts() async {
    try {
      setState(() {
        _serialPorts = SerialPort.availablePorts;
        if (_selectedPort != null && !_serialPorts.contains(_selectedPort)) {
          _selectedPort = null;
        }
        if (_selectedPort == null && _serialPorts.isNotEmpty) {
          _selectedPort = _serialPorts.first;
        }
      });
    } catch (e) {
      print('Error listing serial ports: $e');
    }
  }

  Widget _buildUsbTab(BuildContext context, AppLocalizations t) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.connectViaUsb,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshSerialPorts,
                    tooltip: t.refreshPorts,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_serialPorts.isEmpty)
                Center(child: Text(t.noSerialPortsFound))
              else
                DropdownButtonFormField<String>(
                  value: _selectedPort,
                  decoration: InputDecoration(
                    labelText: t.selectSerialPort,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.usb),
                  ),
                  items: _serialPorts.map((port) {
                    return DropdownMenuItem(value: port, child: Text(port));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPort = value;
                    });
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _usbConnecting || _selectedPort == null
                    ? null
                    : _connectUsb,
                icon: _usbConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(_usbConnecting ? t.statusConnecting : t.connect),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _connectUsb() async {
    if (_selectedPort == null) return;

    setState(() => _usbConnecting = true);

    try {
      await DeviceStatusStore.instance.connectUsb(_selectedPort!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).connectedToUsbDevice),
          ),
        );
      }
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
      if (mounted) {
        setState(() => _usbConnecting = false);
      }
    }
  }
}

List<ScanResult> _filteredDevices(Iterable<ScanResult> input, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return input.toList();

  final tokens = q.split(RegExp(r"\s+")).where((t) => t.isNotEmpty).toList();

  bool matches(ScanResult r) {
    final advName = r.advertisementData.advName;
    final id = r.device.remoteId.str;
    // Include manufacturer names in searchable fields
    final manufIds = r.advertisementData.manufacturerData.keys;
    final manufNames = manufIds
        .map((mid) => ManufacturerDb.nameNow(mid))
        .whereType<String>()
        .map((s) => s.toLowerCase());

    String normalize(String s) => s.toLowerCase();

    final fields = <String>{normalize(advName), normalize(id), ...manufNames}
      ..removeWhere((e) => e.isEmpty);

    // A device matches if every token is found in any field (AND across tokens, OR across fields)

    for (final tok in tokens) {
      final tokNorm = tok;
      final ok = fields.any((f) => f.contains(tokNorm));
      if (!ok) return false;
    }
    return true;
  }

  return input.where(matches).toList();
}
