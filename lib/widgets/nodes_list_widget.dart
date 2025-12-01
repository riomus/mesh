import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../services/nodes_service.dart';
import '../utils/text_sanitize.dart';

// Logs-like chip filtering primitives for Nodes
enum _NodeChipOp { exact, regex }

class _NodeChipFilter {
  final String key;
  final String value; // empty + exact => presence-only
  final _NodeChipOp op;
  RegExp? _compiledRegex;
  _NodeChipFilter({required this.key, required this.value, required this.op});
  String get label => op == _NodeChipOp.exact ? (value.isEmpty ? key : '$key=$value') : '$key~/$value/i';
}

class NodesListWidget extends StatefulWidget {
  const NodesListWidget({super.key});

  @override
  State<NodesListWidget> createState() => _NodesListWidgetState();
}

class _NodesListWidgetState extends State<NodesListWidget>
    with AutomaticKeepAliveClientMixin {
  final _svc = NodesService.instance;
  StreamSubscription<List<MeshNodeView>>? _sub;
  final List<MeshNodeView> _nodes = <MeshNodeView>[];

  // Logs-like filtering schema using chips added from a modal
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Set<String> _seenKeys = <String>{};
  final Map<String, Set<String>> _seenValuesByKey = <String, Set<String>>{};
  final List<_NodeChipFilter> _chips = <_NodeChipFilter>[];

  // Local chip types (hints removed as unused)
  // Sorting configuration
  static const _defaultSort = <_SortEntry>[
    _SortEntry(_SortField.favoriteFirst, true),
    _SortEntry(_SortField.lastSeen, false), // desc (most recent first)
    _SortEntry(_SortField.name, true),
  ];
  List<_SortEntry> _sorters = List<_SortEntry>.from(_defaultSort);

  String? _firstOrNull(List<String>? list) => (list == null || list.isEmpty) ? null : list.first;

  @override
  void initState() {
    super.initState();
    _sub = _svc.listenAll().listen((list) {
      setState(() {
        _nodes
          ..clear()
          ..addAll(list);
        // collect keys/values for modal suggestions
        for (final n in list) {
          for (final entry in n.tags.entries) {
            _seenKeys.add(entry.key);
            final set = _seenValuesByKey.putIfAbsent(entry.key, () => <String>{});
            set.addAll(entry.value);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _matches(MeshNodeView n) {
    // Chips: AND across keys, OR within the same key
    if (_chips.isNotEmpty) {
      final chipsByKey = <String, List<_NodeChipFilter>>{};
      for (final c in _chips) {
        chipsByKey.putIfAbsent(c.key, () => <_NodeChipFilter>[]).add(c);
      }
      for (final entry in chipsByKey.entries) {
        final key = entry.key;
        final chips = entry.value;
        final values = n.tags[key] ?? const <String>[];
        bool groupMatch = false;
        for (final chip in chips) {
          if (chip.op == _NodeChipOp.exact) {
            if (chip.value.isEmpty) {
              if (values.isNotEmpty) {
                groupMatch = true;
                break;
              }
            } else {
              final target = chip.value.toLowerCase();
              if (values.any((v) => v.toLowerCase() == target)) {
                groupMatch = true;
                break;
              }
            }
          } else {
            final re = chip._compiledRegex ?? RegExp(chip.value, caseSensitive: false);
            chip._compiledRegex = re;
            if (values.any((v) => re.hasMatch(v))) {
              groupMatch = true;
              break;
            }
          }
        }
        if (!groupMatch) return false; // AND across keys
      }
    }
    if (_search.isNotEmpty) {
      final s = _search.toLowerCase();
      final name = n.displayName.toLowerCase();
      final hex = (n.num?.toRadixString(16) ?? '').toLowerCase();
      if (!(name.contains(s) || hex.contains(s))) return false;
    }
    return true;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtered = _nodes.where(_matches).toList()
      ..sort((a, b) => _compareNodes(a, b));

    return Column(
      children: [
        _buildTopBar(context),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, index2) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = filtered[index];
              return ListTile(
                leading: CircleAvatar(child: Text(safeInitial(n.displayName))),
                title: Text(safeText(n.displayName)),
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
    if (n.lastHeard != null) parts.add('⏱️ ${_formatAgo(n.lastHeard!)}');
    final srcHex = _firstOrNull(n.tags['sourceDeviceId']);
    final srcName = _firstOrNull(n.tags['sourceNodeName']);
    if (srcHex != null || srcName != null) {
      final label = [if (srcName != null) srcName, if (srcHex != null) '0x$srcHex'].join(' ');
      parts.add('via $label');
    }
    return Text(safeText(parts.join(' • ')));
  }
  Widget _buildTopBar(BuildContext context) {
    final chips = _chips
        .asMap()
        .entries
        .map((entry) => InputChip(
              label: Text(safeText(entry.value.label)),
              onDeleted: () => setState(() => _chips.removeAt(entry.key)),
            ))
        .toList(growable: false);

    // sync controller text with state
    if (_searchCtrl.text != _search) {
      _searchCtrl.text = _search;
      _searchCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _searchCtrl.text.length));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _searchFocus.requestFocus(),
              child: InputDecorator(
                isFocused: _searchFocus.hasFocus,
                isEmpty: false,
                decoration: const InputDecoration(
                  labelText: 'Search nodes',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...chips,
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 120),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: _searchFocus,
                              controller: _searchCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Find by name or id ...',
                                isDense: true,
                                border: InputBorder.none,
                              ),
                              onChanged: (v) => setState(() => _search = v),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Clear',
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Add filter',
            child: FilledButton.icon(
              icon: const Icon(Icons.filter_alt),
              label: const Text('Add filter'),
              onPressed: _openAddChipDialog,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Sorting',
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.sort),
              label: const Text('Sort'),
              onPressed: _openSortDialog,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Clear filters',
            child: IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => setState(() => _chips.clear()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddChipDialog() async {
    if (_seenKeys.isEmpty) return;
    String? draftKey = _seenKeys.contains('role') ? 'role' : (_seenKeys.toList()..sort()).first;
    _NodeChipOp draftOp = _NodeChipOp.exact;
    final Set<String> selectedValues = <String>{};
    final TextEditingController customCtrl = TextEditingController();
    bool presence = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlg) {
          void addSelected() {
            final key = draftKey;
            if (key == null) return;
            if (draftOp == _NodeChipOp.regex) {
              final pattern = customCtrl.text.trim();
              if (pattern.isEmpty) return;
              try {
                RegExp(pattern, caseSensitive: false);
              } catch (_) {
                return;
              }
              final c = _NodeChipFilter(key: key, value: pattern, op: _NodeChipOp.regex);
              setState(() => _addChipUnique(c));
              Navigator.of(context).pop();
              return;
            }
            bool any = false;
            if (presence) {
              any |= _addChipUnique(_NodeChipFilter(key: key, value: '', op: _NodeChipOp.exact));
            }
            for (final v in selectedValues) {
              any |= _addChipUnique(_NodeChipFilter(key: key, value: v, op: _NodeChipOp.exact));
            }
            final custom = customCtrl.text.trim();
            if (custom.isNotEmpty) {
              any |= _addChipUnique(_NodeChipFilter(key: key, value: custom, op: _NodeChipOp.exact));
            }
            if (any) setState(() {});
            Navigator.of(context).pop();
          }

          final values = draftKey == null ? const <String>{} : (_seenValuesByKey[draftKey!] ?? const <String>{});
          final valuesSorted = values.toList()..sort();
          final keyItems = (_seenKeys.toList()..sort())
              .map((k) => DropdownMenuItem<String>(value: k, child: Text(safeText(k))))
              .toList();

          return AlertDialog(
            title: const Text('Add filter'),
            content: SizedBox(
              width: 480,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Key'),
                        initialValue: draftKey,
                        items: keyItems,
                        onChanged: (v) => setDlg(() {
                          draftKey = v;
                          selectedValues.clear();
                          presence = false;
                          customCtrl.clear();
                        }),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<_NodeChipOp>(
                        segments: const [
                          ButtonSegment(value: _NodeChipOp.exact, label: Text('Exact')),
                          ButtonSegment(value: _NodeChipOp.regex, label: Text('Regex')),
                        ],
                        selected: {draftOp},
                        onSelectionChanged: (s) => setDlg(() => draftOp = s.first),
                      ),
                      const SizedBox(height: 12),
                      if (draftOp == _NodeChipOp.exact) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: Text(safeText('has ${draftKey ?? 'value'}')),
                              selected: presence,
                              onSelected: (v) => setDlg(() => presence = v),
                            ),
                            ...valuesSorted.map((v) => FilterChip(
                                  label: Text(safeText(v)),
                                  selected: selectedValues.contains(v),
                                  onSelected: (sel) => setDlg(() {
                                    if (sel) {
                                      selectedValues.add(v);
                                    } else {
                                      selectedValues.remove(v);
                                    }
                                  }),
                                )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: customCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Custom value (optional)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => addSelected(),
                        ),
                      ] else ...[
                        TextField(
                          controller: customCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Regex (case-insensitive)',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Cancel')),
              FilledButton(onPressed: addSelected, child: const Text('Add')),
            ],
          );
        },
      ),
    );
  }

  // ===== Sorting helpers =====
  int _compareNodes(MeshNodeView a, MeshNodeView b) {
    for (final s in _sorters) {
      int r = 0;
      switch (s.field) {
        case _SortField.favoriteFirst:
          final fa = (a.isFavorite ?? false) ? 0 : 1;
          final fb = (b.isFavorite ?? false) ? 0 : 1;
          r = fa.compareTo(fb);
          break;
        case _SortField.distance:
          final da = _distanceMeters(a);
          final db = _distanceMeters(b);
          r = _nullSafeCompare(da, db);
          break;
        case _SortField.snr:
          r = _nullSafeCompare(a.snr, b.snr);
          break;
        case _SortField.lastSeen:
          // Higher lastHeard means more recent; default desc -> nearest begin
          r = _nullSafeCompare(a.lastHeard, b.lastHeard);
          break;
        case _SortField.role:
          r = _stringCompare(a.user?.role, b.user?.role);
          break;
        case _SortField.name:
          r = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
          break;
      }
      if (r != 0) return s.asc ? r : -r;
    }
    return 0;
  }

  int _nullSafeCompare<T extends num>(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1; // nulls last
    if (b == null) return -1;
    return a.compareTo(b);
  }

  int _stringCompare(String? a, String? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  double? _distanceMeters(MeshNodeView n) {
    final ref = _svc.effectiveDistanceReference;
    final p = n.position;
    if (ref == null || p?.latitudeI == null || p?.longitudeI == null) return null;
    final lat1 = ref.$1 * math.pi / 180.0;
    final lon1 = ref.$2 * math.pi / 180.0;
    final lat2 = (p!.latitudeI! / 1e7) * math.pi / 180.0;
    final lon2 = (p.longitudeI! / 1e7) * math.pi / 180.0;
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = math.pow(math.sin(dLat / 2), 2) + math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a.toDouble()), math.sqrt(1 - a.toDouble()));
    const R = 6371000.0; // meters
    return R * c;
  }

  String _formatAgo(int seconds) {
    if (seconds < 60) return '${seconds}s ago';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '${hours}h ago';
    final days = hours ~/ 24;
    return '${days}d ago';
  }

  Future<void> _openSortDialog() async {
    List<_SortEntry> local = List<_SortEntry>.from(_sorters);
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlg) {
          void addIfMissing(_SortField f) {
            if (!local.any((e) => e.field == f)) local.add(_SortEntry(f, true));
          }
          return AlertDialog(
            title: const Text('Sorting'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(onPressed: () { setDlg(() { addIfMissing(_SortField.distance); }); }, icon: const Icon(Icons.place), label: const Text('Distance')),
                        OutlinedButton.icon(onPressed: () { setDlg(() { addIfMissing(_SortField.snr); }); }, icon: const Icon(Icons.network_cell), label: const Text('SNR')),
                        OutlinedButton.icon(onPressed: () { setDlg(() { addIfMissing(_SortField.lastSeen); }); }, icon: const Icon(Icons.access_time), label: const Text('Last seen')),
                        OutlinedButton.icon(onPressed: () { setDlg(() { addIfMissing(_SortField.role); }); }, icon: const Icon(Icons.badge), label: const Text('Role')),
                        OutlinedButton.icon(onPressed: () { setDlg(() { addIfMissing(_SortField.name); }); }, icon: const Icon(Icons.abc), label: const Text('Name')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ReorderableListView(
                      shrinkWrap: true,
                      onReorder: (oldIndex, newIndex) {
                        setDlg(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = local.removeAt(oldIndex);
                          local.insert(newIndex, item);
                        });
                      },
                      children: [
                        for (int i = 0; i < local.length; i++)
                          ListTile(
                            key: ValueKey('sort_$i'),
                            title: Text(_labelForField(local[i].field)),
                            leading: const Icon(Icons.drag_handle),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(local[i].asc ? 'ASC' : 'DESC'),
                                IconButton(
                                  icon: const Icon(Icons.swap_vert),
                                  onPressed: () => setDlg(() => local[i] = local[i].toggle()),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => setDlg(() => local.removeAt(i)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(spacing: 8, children: [
                      FilledButton.tonal(
                        onPressed: () { setDlg(() { local = List<_SortEntry>.from(_defaultSort); }); },
                        child: const Text('Reset to default'),
                      ),
                      TextButton(
                        onPressed: () { _svc.setCustomDistanceReference(lat: null, lon: null); Navigator.of(context).maybePop(); },
                        child: const Text('Use source device as distance ref'),
                      ),
                      Text('Tip: set a custom reference by long‑pressing on the Map tab'),
                    ]),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              FilledButton(onPressed: () { setState(() { _sorters = List<_SortEntry>.from(local); }); Navigator.of(context).pop(); }, child: const Text('Apply')),
            ],
          );
        },
      ),
    );
  }

  String _labelForField(_SortField f) {
    switch (f) {
      case _SortField.favoriteFirst:
        return 'Favorites first';
      case _SortField.distance:
        return 'Distance';
      case _SortField.snr:
        return 'SNR';
      case _SortField.lastSeen:
        return 'Last seen';
      case _SortField.role:
        return 'Role';
      case _SortField.name:
        return 'Name';
    }
    // Fallback (should be unreachable)
    return 'Unknown';
  }
  bool _addChipUnique(_NodeChipFilter c) {
    final exists = _chips.any((x) => x.key == c.key && x.value == c.value && x.op == c.op);
    if (!exists) {
      _chips.add(c);
      return true;
    }
    return false;
  }
}

enum _SortField { favoriteFirst, distance, snr, lastSeen, role, name }

class _SortEntry {
  final _SortField field;
  final bool asc;
  const _SortEntry(this.field, this.asc);
  _SortEntry toggle() => _SortEntry(field, !asc);
}
