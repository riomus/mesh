import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/rssi_bar.dart';

class DeviceDetailsPage extends StatelessWidget {
  final ScanResult result;
  const DeviceDetailsPage({super.key, required this.result});

  String _bestName(ScanResult r) {
    if (r.advertisementData.advName.isNotEmpty) return r.advertisementData.advName;
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    return r.device.remoteId.str;
  }

  @override
  Widget build(BuildContext context) {
    final ad = result.advertisementData;
    final device = result.device;

    return Scaffold(
      appBar: AppBar(
        title: Text(_bestName(result)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // General section
          _Section(
            title: AppLocalizations.of(context)!.general,
            children: [
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(AppLocalizations.of(context)!.identifier),
                subtitle: Text(device.remoteId.str),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: Text(AppLocalizations.of(context)!.platformName),
                subtitle: Text(device.platformName.isNotEmpty ? device.platformName : '—'),
              ),
              ListTile(
                leading: const Icon(Icons.network_cell),
                title: Text(AppLocalizations.of(context)!.signalRssi),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RssiBar(rssi: result.rssi),
                ),
                trailing: Text('${result.rssi} dBm'),
              ),
            ],
          ),
          // Advertisement section
          _Section(
            title: AppLocalizations.of(context)!.advertisement,
            children: [
              ListTile(
                leading: const Icon(Icons.label),
                title: Text(AppLocalizations.of(context)!.advertisedName),
                subtitle: Text(ad.advName.isNotEmpty ? ad.advName : '—'),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(AppLocalizations.of(context)!.connectable),
                subtitle: Text(ad.connectable
                    ? AppLocalizations.of(context)!.yes
                    : AppLocalizations.of(context)!.no),
              ),
              // Service UUIDs
              if (ad.serviceUuids.isNotEmpty)
                _ExpandableMap<List<Guid>>(
                  icon: Icons.widgets,
                  title: AppLocalizations.of(context)!
                      .serviceUuidsWithCount(ad.serviceUuids.length),
                  items: {
                    for (var i = 0; i < ad.serviceUuids.length; i++)
                      '${AppLocalizations.of(context)!.service} ${i + 1}': [ad.serviceUuids[i]]
                  },
                  valueBuilder: (gList) => gList.map((g) => g.str).join(', '),
                )
              else
                ListTile(
                  leading: const Icon(Icons.widgets),
                  title: Text(AppLocalizations.of(context)!.serviceUuids),
                  subtitle: Text(AppLocalizations.of(context)!.noneAdvertised),
                ),
              // Manufacturer Data
              if (ad.manufacturerData.isNotEmpty)
                _ExpandableMap<List<int>>(
                  icon: Icons.factory,
                  title: AppLocalizations.of(context)!
                      .manufacturerDataWithCount(ad.manufacturerData.length),
                  items: ad.manufacturerData.map((k, v) => MapEntry('0x${k.toRadixString(16).padLeft(4, '0')}', v)),
                  valueBuilder: (bytes) => _hex(bytes),
                )
              else
                ListTile(
                  leading: const Icon(Icons.factory),
                  title: Text(AppLocalizations.of(context)!.manufacturerData),
                  subtitle: Text(AppLocalizations.of(context)!.noneAdvertised),
                ),
              // Service Data
              if (ad.serviceData.isNotEmpty)
                _ExpandableMap<List<int>>(
                  icon: Icons.storage,
                  title:
                      AppLocalizations.of(context)!.serviceDataWithCount(ad.serviceData.length),
                  items: ad.serviceData.map((k, v) => MapEntry(k.str, v)),
                  valueBuilder: (bytes) => _hex(bytes),
                )
              else
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text(AppLocalizations.of(context)!.serviceData),
                  subtitle: Text(AppLocalizations.of(context)!.noneAdvertised),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static String _hex(List<int> bytes) {
    if (bytes.isEmpty) return '—';
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
      sb.write(' ');
    }
    return sb.toString().trim().toUpperCase();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _ExpandableMap<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final Map<String, T> items;
  final String Function(T value) valueBuilder;
  const _ExpandableMap({
    required this.icon,
    required this.title,
    required this.items,
    required this.valueBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: items.entries
          .map(
            (e) => ListTile(
              dense: true,
              title: Text(e.key),
              subtitle: Text(valueBuilder(e.value)),
            ),
          )
          .toList(),
    );
  }
}
