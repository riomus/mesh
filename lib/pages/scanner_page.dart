import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../services/meshtastic_ble_client.dart';
import '../widgets/device_tile.dart';
import '../widgets/empty_state.dart';
import '../config/lora_config.dart';
import '../config/manufacturer_db.dart';
import '../config/version_info.dart';

class ScannerPage extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(Locale? locale)? onChangeLocale;
  final Locale? locale;
  const ScannerPage({super.key, this.onToggleTheme, this.themeMode, this.onChangeLocale, this.locale});

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
  bool _loraOnly = true; // ticker: show only LoRa devices by default

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
        if (mounted) setState(() {});
      } catch (_) {
        // ignore
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _debounce?.cancel();
    _searchController.dispose();
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
      requests.addAll([
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ]);
      requests.add(Permission.locationWhenInUse); // for pre-Android 12
    } else if (platform == TargetPlatform.iOS) {
      requests.add(Permission.bluetooth);
    }

    if (requests.isEmpty) return; // Safety: do not invoke plugin with empty list
    await requests.request();
  }

  Future<void> _startScan() async {
    await _ensurePermissions();
    setState(() => _scanning = true);
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10), webOptionalServices: [Guid(MeshtasticBleClient.serviceUuid)]);
    // Listen for scan completion and update UI
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
    final t = AppLocalizations.of(context)!;
    final base = _filteredDevices(_results.values, _query);
    final devices = (_loraOnly ? base.where(isLoraDevice).toList() : base)
      ..sort((a, b) => (b.rssi).compareTo(a.rssi));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.nearbyDevicesTitle),
        actions: [
          if (VersionInfo.instance != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Tooltip(
                  message: 'Build: ${VersionInfo.instance!.displayDescribe}' +
                      (VersionInfo.instance!.buildTimeUtc != null
                          ? '\nBuilt: ${VersionInfo.instance!.buildTimeUtc!.toIso8601String()}'
                          : ''),
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
              // While scanning, show the stop icon in red to indicate active scanning
              color: _scanning ? Colors.red : null,
            ),
            tooltip: _scanning ? t.stop : t.scan,
            onPressed: _scanning ? _stopScan : _startScan,
          ),
          // Bluetooth adapter state indicator in the top-right corner
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
                  tooltip = AppLocalizations.of(context)!.bluetoothOn;
                  break;
                case BluetoothAdapterState.off:
                  icon = Icons.bluetooth_disabled;
                  color = Colors.red;
                  tooltip = AppLocalizations.of(context)!.bluetoothOff;
                  break;
                default:
                  final name = state?.name ?? AppLocalizations.of(context)!.unknown;
                  icon = Icons.bluetooth;
                  color = Colors.orange;
                  tooltip = AppLocalizations.of(context)!.bluetoothState(name);
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
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: t.toggleThemeTooltip,
            onPressed: widget.onToggleTheme,
          ),
          PopupMenuButton<Locale?>(
            tooltip: t.languageTooltip,
            icon: const Icon(Icons.language),
            onSelected: (value) => widget.onChangeLocale?.call(value),
            itemBuilder: (context) {
              final items = <PopupMenuEntry<Locale?>>[];
              // System default option (null locale → follow system language)
              items.add(
                PopupMenuItem<Locale?> (
                  value: null,
                  child: Row(
                    children: const [
                      Icon(Icons.settings_suggest, size: 18),
                      SizedBox(width: 8),
                      Text('System default'),
                    ],
                  ),
                ),
              );
              items.add(const PopupMenuDivider());
              for (final loc in AppLocalizations.supportedLocales) {
                final label = _localeLabel(loc);
                items.add(
                  PopupMenuItem<Locale?>(
                    value: loc,
                    child: Text(label),
                  ),
                );
              }
              return items;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: t.searchHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onQueryChanged('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onQueryChanged,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(t.loraOnlyFilterLabel),
                  // Avoid the checkmark (ticker) drawing over the icon by hiding it
                  // and use icon color to indicate selection state.
                  avatar: Icon(
                    Icons.sensors,
                    color: _loraOnly ? Theme.of(context).colorScheme.primary : null,
                  ),
                  selected: _loraOnly,
                  showCheckmark: false,
                  onSelected: (v) => setState(() => _loraOnly = v),
                ),
              ],
            ),
          ),
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
        label: Text(_scanning ? t.stop : t.scan),
      ),
    );
  }
}

String _localeLabel(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return 'English';
    case 'pl':
      return 'Polski';
    default:
      return locale.toLanguageTag();
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

    final fields = <String>{
      normalize(advName),
      normalize(id),
      ...manufNames,
    }..removeWhere((e) => e.isEmpty);

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
