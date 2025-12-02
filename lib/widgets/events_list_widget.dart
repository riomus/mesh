import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/device_communication_event_service.dart';
import 'meshtastic_event_tiles.dart';
import '../pages/event_details_page.dart';
import '../l10n/app_localizations.dart';

// Logs-like filter primitives (private to this file)
enum _EventChipOp { exact, regex }

class _EventChipFilter {
  final String key;
  final String value; // empty + exact => presence-only
  final _EventChipOp op;
  RegExp? _compiledRegex; // cache for regex matching
  _EventChipFilter({required this.key, required this.value, required this.op});
  String get label => op == _EventChipOp.exact
      ? (value.isEmpty ? key : '$key=$value')
      : '$key~/$value/i';
}

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
  /// Optional initial list of events to seed the view (used for fullscreen to mirror current view).
  final List<DeviceEvent>? initialEvents;
  /// Optional initial search text to seed the view.
  final String? initialSearch;

  const EventsListWidget({
    super.key,
    this.deviceId,
    this.network,
    this.maxVisible = 1000,
    this.initialEvents,
    this.initialSearch,
  });

  @override
  State<EventsListWidget> createState() => _EventsListWidgetState();
}

class _EventsListWidgetState extends State<EventsListWidget> {
  final _svc = DeviceCommunicationEventService.instance;
  // Make subscription nullable to allow safe cancel before first assignment
  StreamSubscription<DeviceEvent>? _sub;
  final List<DeviceEvent> _events = <DeviceEvent>[];

  // dynamic filters
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String? _selectedNetwork; // kept for initial seeding only
  String? _selectedDeviceId; // kept for initial seeding only

  // Logs-like chip filtering model
  // Seen keys and their values discovered from events
  final Set<String> _seenKeys = <String>{};
  final Map<String, Set<String>> _seenValuesByKey = <String, Set<String>>{};
  // User-defined filter chips (tag-based)
  final List<_EventChipFilter> _chips = <_EventChipFilter>[];

  @override
  void initState() {
    super.initState();
    _selectedNetwork = widget.network;
    _selectedDeviceId = widget.deviceId;
    // Seed from provided initial state (e.g., when opening fullscreen so content matches).
    if (widget.initialEvents != null && widget.initialEvents!.isNotEmpty) {
      for (final e in widget.initialEvents!) {
        // collect keys/values
        for (final entry in e.tags.entries) {
          _seenKeys.add(entry.key);
          final set = _seenValuesByKey.putIfAbsent(entry.key, () => <String>{});
          set.addAll(entry.value);
        }
      }
      _events.addAll(widget.initialEvents!);
      final overflow = _events.length - widget.maxVisible;
      if (overflow > 0) _events.removeRange(0, overflow);
    }
    if (widget.initialSearch != null) {
      _search = widget.initialSearch!;
    }
    _subscribe();
  }

  @override
  void dispose() {
    _sub?.cancel();
    // Controllers are non-null; dispose directly
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _subscribe() {
    // Cancel any previous subscription
    _sub?.cancel();
    // Prefer replay so when the widget remounts (e.g., after navigating back),
    // the recent history is visible immediately.
    final hasInitialSeed = widget.initialEvents != null && widget.initialEvents!.isNotEmpty;
    if (hasInitialSeed) {
      // If the parent already provided an initial set to mirror, avoid double
      // adding by listening live only.
      _sub = _svc.listenAll().listen(_onEvent);
      return;
    }
    // Build pre-filters for replay based on provided network/deviceId
    final allEquals = <String, String>{};
    if (widget.network != null && widget.network!.isNotEmpty) {
      allEquals['network'] = widget.network!;
    }
    if (widget.deviceId != null && widget.deviceId!.isNotEmpty) {
      allEquals['deviceId'] = widget.deviceId!;
    }
    final useFilters = allEquals.isNotEmpty;
    _sub = _svc
        .listenWithReplay(
          allEquals: useFilters ? allEquals : null,
        )
        .listen(_onEvent);
  }

  @override
  void didUpdateWidget(covariant EventsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = oldWidget.deviceId != widget.deviceId ||
        oldWidget.network != widget.network ||
        oldWidget.initialEvents != widget.initialEvents ||
        oldWidget.initialSearch != widget.initialSearch;
    if (changed) {
      // Reset state so the view reflects the new scope cleanly
      setState(() {
        _events.clear();
        _seenKeys.clear();
        _seenValuesByKey.clear();
        _chips.clear();
        _selectedNetwork = widget.network;
        _selectedDeviceId = widget.deviceId;
        if (widget.initialSearch != null) {
          _search = widget.initialSearch!;
        } else {
          _search = '';
        }
      });
      _subscribe();
    }
  }

  void _onEvent(DeviceEvent e) {
    // collect keys and values
    for (final entry in e.tags.entries) {
      _seenKeys.add(entry.key);
      final set = _seenValuesByKey.putIfAbsent(entry.key, () => <String>{});
      set.addAll(entry.value);
    }

    setState(() {
      _events.add(e);
      final overflow = _events.length - widget.maxVisible;
      if (overflow > 0) _events.removeRange(0, overflow);
    });
  }

  bool _matchFilters(DeviceEvent e) {
    // Apply chip filters: AND across keys, OR within same key
    if (_chips.isNotEmpty) {
      final chipsByKey = <String, List<_EventChipFilter>>{};
      for (final c in _chips) {
        chipsByKey.putIfAbsent(c.key, () => <_EventChipFilter>[]).add(c);
      }
      for (final entry in chipsByKey.entries) {
        final key = entry.key;
        final chips = entry.value;
        final values = e.tags[key] ?? const <String>[];
        bool groupMatch = false;
        for (final chip in chips) {
          if (chip.op == _EventChipOp.exact) {
            if (chip.value.isEmpty) {
              // presence-only
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
            // regex (case-insensitive)
            if (chip._compiledRegex?.hasMatch('') == false) {
              // ensure compiled
            }
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
      // search in summary and tag values
      final summaryHit = (e.summary ?? '').toLowerCase().contains(s);
      final tagsHit = e.tags.entries.any((kv) => kv.value.any((v) => v.toLowerCase().contains(s)));
      if (!(summaryHit || tagsHit)) return false;
    }
    return true;
  }

  List<DeviceEvent> _filtered() => _events.where(_matchFilters).toList().reversed.toList();

  Future<void> _shareFilteredEvents() async {
    try {
      final items = _filtered().map((e) {
        final payload = e.payload;
        Object? payloadJson;
        if (payload == null) {
          payloadJson = null;
        } else if (payload is MeshtasticDeviceEventPayload) {
          // Keep it lightweight; include a brief structured snapshot
          payloadJson = {
            'type': 'MeshtasticDeviceEventPayload',
            'eventType': payload.event.runtimeType.toString(),
          };
        } else {
          payloadJson = {'type': payload.runtimeType.toString()};
        }
        return {
          'timestamp': e.timestamp.toIso8601String(),
          'tags': e.tags,
          'summary': e.summary,
          'payload': payloadJson,
        };
      }).toList(growable: false);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(items);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      final ts = DateTime.now();
      final name = 'events-${ts.year.toString().padLeft(4, '0')}'
          '${ts.month.toString().padLeft(2, '0')}'
          '${ts.day.toString().padLeft(2, '0')}-'
          '${ts.hour.toString().padLeft(2, '0')}'
          '${ts.minute.toString().padLeft(2, '0')}'
          '${ts.second.toString().padLeft(2, '0')}.json';
      final file = XFile.fromData(bytes, name: name, mimeType: 'application/json');
      await Share.shareXFiles([file], text: AppLocalizations.of(context).eventsExport);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).failedToShareEvents(err.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(context),
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

  // UI similar to Logs: chips + text search and actions
  Widget _buildTopBar(BuildContext context) {
    final chips = _chips
        .asMap()
        .entries
        .map((entry) => InputChip(
              label: Text(entry.value.label),
              onDeleted: () => setState(() => _chips.removeAt(entry.key)),
            ))
        .toList(growable: false);

    // keep controller text in sync with state (once per build if needed)
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).searchEvents,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
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
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).searchInSummaryOrTags,
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
                              tooltip: AppLocalizations.of(context).clear,
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
            message: AppLocalizations.of(context).addFilter,
            child: FilledButton.icon(
              icon: const Icon(Icons.filter_alt),
              label: Text(AppLocalizations.of(context).addFilter),
              onPressed: _openAddChipDialog,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: AppLocalizations.of(context).shareEvents,
            child: IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: _shareFilteredEvents,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: AppLocalizations.of(context).fullscreen,
            child: IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => Scaffold(
                      appBar: AppBar(
                        title: Text(AppLocalizations.of(ctx).eventsTitle),
                        actions: [
                          IconButton(
                            tooltip: AppLocalizations.of(ctx).close,
                            icon: const Icon(Icons.close_fullscreen),
                            onPressed: () => Navigator.of(ctx).maybePop(),
                          ),
                        ],
                      ),
                      body: EventsListWidget(
                        network: _selectedNetwork,
                        deviceId: _selectedDeviceId,
                        initialEvents: _events.toList(growable: false),
                        initialSearch: _search,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddChipDialog() async {
    if (_seenKeys.isEmpty) return;
    String? draftKey = _selectedNetwork != null
        ? 'network'
        : (_selectedDeviceId != null
            ? 'deviceId'
            : (_seenKeys.isNotEmpty ? (_seenKeys.toList()..sort()).first : null));
    _EventChipOp draftOp = _EventChipOp.exact;
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
            if (draftOp == _EventChipOp.regex) {
              final pattern = customCtrl.text.trim();
              if (pattern.isEmpty) return;
              try {
                RegExp(pattern, caseSensitive: false);
              } catch (_) {
                return;
              }
              final c = _EventChipFilter(key: key, value: pattern, op: _EventChipOp.regex);
              setState(() => _addChipUnique(c));
              Navigator.of(context).pop();
              return;
            }
            bool any = false;
            if (presence) {
              any |= _addChipUnique(_EventChipFilter(key: key, value: '', op: _EventChipOp.exact));
            }
            for (final v in selectedValues) {
              any |= _addChipUnique(_EventChipFilter(key: key, value: v, op: _EventChipOp.exact));
            }
            final custom = customCtrl.text.trim();
            if (custom.isNotEmpty) {
              any |= _addChipUnique(_EventChipFilter(key: key, value: custom, op: _EventChipOp.exact));
            }
            if (any) setState(() {});
            Navigator.of(context).pop();
          }

          final values = draftKey == null ? const <String>{} : (_seenValuesByKey[draftKey!] ?? const <String>{});
          final valuesSorted = values.toList()..sort();
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
                        items: (() {
                          final list = _seenKeys.toList()..sort();
                          return list.map((k) => DropdownMenuItem<String>(value: k, child: Text(k))).toList();
                        })(),
                        onChanged: (v) {
                          setDlg(() {
                            draftKey = v;
                            selectedValues.clear();
                            presence = false;
                            customCtrl.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<_EventChipOp>(
                        segments: const [
                          ButtonSegment(value: _EventChipOp.exact, label: Text('Exact')),
                          ButtonSegment(value: _EventChipOp.regex, label: Text('Regex')),
                        ],
                        selected: {draftOp},
                        onSelectionChanged: (s) => setDlg(() => draftOp = s.first),
                      ),
                      const SizedBox(height: 12),
                      if (draftOp == _EventChipOp.exact) ...[
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

  bool _addChipUnique(_EventChipFilter c) {
    final exists = _chips.any((x) => x.key == c.key && x.value == c.value && x.op == c.op);
    if (!exists) {
      _chips.add(c);
      return true;
    }
    return false;
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
