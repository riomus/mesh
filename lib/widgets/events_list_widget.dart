import 'dart:async';

import 'package:flutter/material.dart';

import '../services/device_communication_event_service.dart';
import 'meshtastic_event_tiles.dart';
import '../pages/event_details_page.dart';

/// EventsListWidget
///
/// Displays a live-updating list of device communication events with:
/// - Search input (text contains)
/// - Filter chips (by network and deviceId discovered from incoming events)
/// - Compact list items rendered based on typed payloads (Meshtastic supported)
class EventsListWidget extends StatefulWidget {
  /// If provided, widget will pre-filter by this deviceId.
  final String? deviceId;
  /// If provided, widget will pre-filter by this network.
  final String? network;
  /// Maximum number of events rendered (helps performance on long sessions)
  final int maxVisible;

  const EventsListWidget({super.key, this.deviceId, this.network, this.maxVisible = 1000});

  @override
  State<EventsListWidget> createState() => _EventsListWidgetState();
}

class _EventsListWidgetState extends State<EventsListWidget> {
  final _svc = DeviceCommunicationEventService.instance;
  late StreamSubscription<DeviceEvent> _sub;
  final List<DeviceEvent> _events = <DeviceEvent>[];

  // dynamic filters
  String _search = '';
  String? _selectedNetwork;
  String? _selectedDeviceId;

  // values discovered from incoming events (for chips)
  final Set<String> _networkValues = <String>{};
  final Set<String> _deviceIds = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedNetwork = widget.network;
    _selectedDeviceId = widget.deviceId;
    _sub = _svc.listenAll().listen(_onEvent);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _onEvent(DeviceEvent e) {
    // collect chip values
    final networks = e.tags['network'] ?? const <String>[];
    _networkValues.addAll(networks);
    final devices = e.tags['deviceId'] ?? const <String>[];
    _deviceIds.addAll(devices);

    setState(() {
      _events.add(e);
      final overflow = _events.length - widget.maxVisible;
      if (overflow > 0) _events.removeRange(0, overflow);
    });
  }

  bool _matchFilters(DeviceEvent e) {
    if (_selectedNetwork != null && !(e.tags['network'] ?? const <String>[]).contains(_selectedNetwork)) {
      return false;
    }
    if (_selectedDeviceId != null && !(e.tags['deviceId'] ?? const <String>[]).contains(_selectedDeviceId)) {
      return false;
    }
    if (_search.isNotEmpty) {
      final s = _search.toLowerCase();
      // search in summary and tag values
      final summaryHit = (e.summary ?? '').toLowerCase().contains(s);
      final tagsHit = e.tags.entries.any((kv) => kv.value.any((v) => v.toLowerCase().contains(s)));
      if (!(summaryHit || tagsHit)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _events.where(_matchFilters).toList().reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(
          search: _search,
          onSearchChanged: (v) => setState(() => _search = v),
          networks: _networkValues.toList()..sort(),
          selectedNetwork: _selectedNetwork,
          onNetworkSelected: (v) => setState(() => _selectedNetwork = v),
          deviceIds: _deviceIds.toList()..sort(),
          selectedDeviceId: _selectedDeviceId,
          onDeviceIdSelected: (v) => setState(() => _selectedDeviceId = v),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const _Empty()
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _EventTile(e: filtered[i]),
                ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  final String search;
  final ValueChanged<String> onSearchChanged;
  final List<String> networks;
  final String? selectedNetwork;
  final ValueChanged<String?> onNetworkSelected;
  final List<String> deviceIds;
  final String? selectedDeviceId;
  final ValueChanged<String?> onDeviceIdSelected;

  const _Toolbar({
    required this.search,
    required this.onSearchChanged,
    required this.networks,
    required this.selectedNetwork,
    required this.onNetworkSelected,
    required this.deviceIds,
    required this.selectedDeviceId,
    required this.onDeviceIdSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search events…',
            isDense: true,
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(selectedNetwork == null ? 'Any network' : 'Network: $selectedNetwork'),
              selected: selectedNetwork != null,
              onSelected: (sel) => onNetworkSelected(sel ? (networks.isNotEmpty ? networks.first : null) : null),
            ),
            if (selectedNetwork != null)
              Wrap(
                spacing: 6,
                children: networks
                    .map((n) => ChoiceChip(
                          label: Text(n),
                          selected: selectedNetwork == n,
                          onSelected: (_) => onNetworkSelected(n),
                        ))
                    .toList(),
              ),
            FilterChip(
              label: Text(selectedDeviceId == null ? 'Any device' : 'Device: $selectedDeviceId'),
              selected: selectedDeviceId != null,
              onSelected: (sel) => onDeviceIdSelected(sel ? (deviceIds.isNotEmpty ? deviceIds.first : null) : null),
            ),
            if (selectedDeviceId != null)
              Wrap(
                spacing: 6,
                children: deviceIds
                    .map((d) => ChoiceChip(
                          label: Text(d),
                          selected: selectedDeviceId == d,
                          onSelected: (_) => onDeviceIdSelected(d),
                        ))
                    .toList(),
              ),
          ],
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No events yet'),
    );
  }
}

class _EventTile extends StatelessWidget {
  final DeviceEvent e;
  const _EventTile({required this.e});

  @override
  Widget build(BuildContext context) {
    final p = e.payload;
    if (p is MeshtasticDeviceEventPayload) {
      // Render using existing Meshtastic tiles for nicer UX
      return InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailsPage(event: e)),
        ),
        child: MeshtasticEventTile(event: p.event),
      );
    }
    // Fallback generic tile
    return ListTile(
      leading: const Text('🧩', style: TextStyle(fontSize: 18)),
      title: Text(e.summary ?? 'Event'),
      subtitle: Text(_tagsSummary(e.tags)),
      dense: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailsPage(event: e)),
      ),
    );
  }

  String _tagsSummary(Map<String, List<String>> tags) {
    if (tags.isEmpty) return '';
    return tags.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join(' · ');
  }
}
