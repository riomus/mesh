import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentDevice {
  final String id;
  final String name;
  final int rssi;
  final DateTime lastConnected;
  final Map<int, List<int>> manufacturerData;

  RecentDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.lastConnected,
    this.manufacturerData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'lastConnected': lastConnected.toIso8601String(),
      'manufacturerData': manufacturerData.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
    };
  }

  factory RecentDevice.fromJson(Map<String, dynamic> json) {
    return RecentDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      rssi: json['rssi'] as int? ?? -100,
      lastConnected: DateTime.parse(json['lastConnected'] as String),
      manufacturerData:
          (json['manufacturerData'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), (v as List).cast<int>()),
          ) ??
          const {},
    );
  }

  ScanResult toScanResult() {
    return ScanResult(
      device: BluetoothDevice(remoteId: DeviceIdentifier(id)),
      advertisementData: AdvertisementData(
        advName: name,
        txPowerLevel: null,
        connectable: true,
        manufacturerData: manufacturerData,
        serviceData: {},
        serviceUuids: [],
        appearance: null,
      ),
      rssi: rssi,
      timeStamp: DateTime.now(),
    );
  }
}

class RecentDevicesService {
  static final RecentDevicesService instance = RecentDevicesService._();
  RecentDevicesService._();

  static const _prefsKey = 'recent_devices';
  final StreamController<List<RecentDevice>> _controller =
      StreamController.broadcast();
  List<RecentDevice> _devices = [];

  Stream<List<RecentDevice>> get devicesStream => _controller.stream;
  List<RecentDevice> get currentDevices => List.unmodifiable(_devices);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonString);
        _devices = list.map((e) => RecentDevice.fromJson(e)).toList();
        _sort();
        _controller.add(_devices);
      } catch (e) {
        // ignore corruption
      }
    }
  }

  Future<void> add(ScanResult result) async {
    final id = result.device.remoteId.str;
    final name = result.advertisementData.advName.isNotEmpty
        ? result.advertisementData.advName
        : (result.device.platformName.isNotEmpty
              ? result.device.platformName
              : id);

    // Remove existing entry if any
    _devices.removeWhere((d) => d.id == id);

    _devices.add(
      RecentDevice(
        id: id,
        name: name,
        rssi: result.rssi,
        lastConnected: DateTime.now(),
        manufacturerData: result.advertisementData.manufacturerData,
      ),
    );

    _sort();
    _controller.add(_devices);
    await _save();
  }

  void _sort() {
    _devices.sort((a, b) => b.lastConnected.compareTo(a.lastConnected));
    // Keep only top 5 recent devices to avoid clutter
    if (_devices.length > 5) {
      _devices = _devices.sublist(0, 5);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_devices.map((d) => d.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }
}
