import 'dart:async';

import 'package:flutter/material.dart';

import '../services/nodes_service.dart';

class NodesListWidget extends StatefulWidget {
  const NodesListWidget({super.key});

  @override
  State<NodesListWidget> createState() => _NodesListWidgetState();
}

class _NodesListWidgetState extends State<NodesListWidget> {
  final _svc = NodesService.instance;
  StreamSubscription<List<MeshNodeView>>? _sub;
  final List<MeshNodeView> _nodes = <MeshNodeView>[];

  // Filters
  String _search = '';
  String? _role;
  String? _deviceId;
  String? _favorite; // 'true'/'false'
  String? _viaMqtt; // 'true'/'false'

  // Discovered chip values
  final Set<String> _roles = <String>{};
  final Set<String> _deviceIds = <String>{};

  @override
  void initState() {
    super.initState();
    _sub = _svc.listenAll().listen((list) {
      setState(() {
        _nodes
          ..clear()
          ..addAll(list);
        // populate chips
        for (final n in list) {
          final r = n.tags['role'];
          if (r != null) _roles.addAll(r);
          final d = n.tags['deviceId'];
          if (d != null) _deviceIds.addAll(d);
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool _matches(MeshNodeView n) {
    if (_role != null && !(n.tags['role'] ?? const <String>[]).contains(_role)) return false;
    if (_deviceId != null && !(n.tags['deviceId'] ?? const <String>[]).contains(_deviceId)) return false;
    if (_favorite != null && !(n.tags['favorite'] ?? const <String>[]).contains(_favorite)) return false;
    if (_viaMqtt != null && !(n.tags['viaMqtt'] ?? const <String>[]).contains(_viaMqtt)) return false;

    if (_search.isNotEmpty) {
      final s = _search.toLowerCase();
      final name = n.displayName.toLowerCase();
      final hex = (n.num?.toRadixString(16) ?? '').toLowerCase();
      if (!(name.contains(s) || hex.contains(s))) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _nodes.where(_matches).toList()
      ..sort((a, b) {
        // Sort favorites first, then most recently heard, then by name
        final fa = (a.isFavorite ?? false) ? 0 : 1;
        final fb = (b.isFavorite ?? false) ? 0 : 1;
        final byFav = fa.compareTo(fb);
        if (byFav != 0) return byFav;
        final la = a.lastHeard ?? 0;
        final lb = b.lastHeard ?? 0;
        final byHeard = lb.compareTo(la); // desc
        if (byHeard != 0) return byHeard;
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });

    return Column(
      children: [
        _SearchAndActions(
          onChanged: (v) => setState(() => _search = v),
          onClear: () => setState(() => _search = ''),
          value: _search,
        ),
        const SizedBox(height: 8),
        _Chips(
          roles: _roles,
          deviceIds: _deviceIds,
          role: _role,
          onRole: (v) => setState(() => _role = v),
          deviceId: _deviceId,
          onDeviceId: (v) => setState(() => _deviceId = v),
          favorite: _favorite,
          onFavorite: (v) => setState(() => _favorite = v),
          viaMqtt: _viaMqtt,
          onViaMqtt: (v) => setState(() => _viaMqtt = v),
          onClearAll: () => setState(() {
            _role = null;
            _deviceId = null;
            _favorite = null;
            _viaMqtt = null;
          }),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = filtered[index];
              return ListTile(
                leading: CircleAvatar(child: Text(n.displayName.isNotEmpty ? n.displayName[0] : '?')),
                title: Text(n.displayName),
                subtitle: _buildSubtitle(n),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (n.isFavorite == true) const Icon(Icons.star, color: Colors.amber),
                    if (n.viaMqtt == true) const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.cloud, color: Colors.blueAccent),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(MeshNodeView n) {
    final parts = <String>[];
    if (n.user?.shortName != null && n.user!.shortName!.isNotEmpty) parts.add('@${n.user!.shortName!}');
    if (n.num != null) parts.add('0x${n.num!.toRadixString(16)}');
    if (n.hopsAway != null) parts.add('${n.hopsAway} hops');
    if (n.position?.latitudeI != null && n.position?.longitudeI != null) parts.add('📍');
    if (n.deviceMetrics?.batteryLevel != null) parts.add('🔋${n.deviceMetrics!.batteryLevel}%');
    if (n.lastHeard != null) parts.add('⏱️ ${n.lastHeard}s');
    return Text(parts.join(' • '));
  }
}

class _SearchAndActions extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchAndActions({required this.value, required this.onChanged, required this.onClear});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or id ...',
            ),
            onChanged: onChanged,
            controller: TextEditingController(text: value),
          ),
        ),
        IconButton(
          tooltip: 'Clear',
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  final Set<String> roles;
  final Set<String> deviceIds;
  final String? role;
  final String? deviceId;
  final String? favorite;
  final String? viaMqtt;
  final ValueChanged<String?> onRole;
  final ValueChanged<String?> onDeviceId;
  final ValueChanged<String?> onFavorite;
  final ValueChanged<String?> onViaMqtt;
  final VoidCallback onClearAll;

  const _Chips({
    required this.roles,
    required this.deviceIds,
    required this.role,
    required this.deviceId,
    required this.favorite,
    required this.viaMqtt,
    required this.onRole,
    required this.onDeviceId,
    required this.onFavorite,
    required this.onViaMqtt,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        FilterChip(
          label: const Text('Fav: yes'),
          selected: favorite == 'true',
          onSelected: (s) => onFavorite(s ? 'true' : null),
        ),
        FilterChip(
          label: const Text('Fav: no'),
          selected: favorite == 'false',
          onSelected: (s) => onFavorite(s ? 'false' : null),
        ),
        FilterChip(
          label: const Text('via MQTT'),
          selected: viaMqtt == 'true',
          onSelected: (s) => onViaMqtt(s ? 'true' : null),
        ),
        for (final r in roles)
          FilterChip(
            label: Text('role:$r'),
            selected: role == r,
            onSelected: (s) => onRole(s ? r : null),
          ),
        for (final d in deviceIds)
          FilterChip(
            label: Text('device:$d'),
            selected: deviceId == d,
            onSelected: (s) => onDeviceId(s ? d : null),
          ),
        ActionChip(
          label: const Text('Clear filters'),
          onPressed: onClearAll,
        ),
      ],
    );
  }
}
