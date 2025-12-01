import 'dart:async';

import 'package:flutter/material.dart';

import '../services/nodes_service.dart';

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

class _NodesListWidgetState extends State<NodesListWidget> {
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

  // Local chip types
  static const _presenceHint = 'Value (empty = presence)';
  static const _regexHint = 'Regex (case-insensitive)';

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
        _buildTopBar(context),
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
  Widget _buildTopBar(BuildContext context) {
    final chips = _chips
        .asMap()
        .entries
        .map((entry) => InputChip(
              label: Text(entry.value.label),
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
              .map((k) => DropdownMenuItem<String>(value: k, child: Text(k)))
              .toList();

          return AlertDialog(
            title: const Text('Add filter'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Key'),
                    value: draftKey,
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
                          label: Text('has ${draftKey ?? 'value'}'),
                          selected: presence,
                          onSelected: (v) => setDlg(() => presence = v),
                        ),
                        ...valuesSorted.map((v) => FilterChip(
                              label: Text(v),
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
            actions: [
              TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Cancel')),
              FilledButton(onPressed: addSelected, child: const Text('Add')),
            ],
          );
        },
      ),
    );
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
