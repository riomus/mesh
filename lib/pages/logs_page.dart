import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../services/logging_service.dart';

/// Logs viewer page: shows all logs from LoggingService with formatting
/// and allows filtering by source and level.
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

// Filter chip operator
enum _ChipOp { exact, regex }

// Filter chip kind (separates level from generic tag chips)
enum _ChipKind { tag, level }

// Single filter chip descriptor
class _ChipFilter {
  final _ChipKind kind;
  final String key; // only meaningful for tag chips
  final String value; // for tag: empty + exact => presence-only; for level: must be non-empty
  final _ChipOp op;

  const _ChipFilter._({required this.kind, required this.key, required this.value, required this.op});

  // Tag chip factory
  factory _ChipFilter.tag({required String key, required String value, required _ChipOp op}) =>
      _ChipFilter._(kind: _ChipKind.tag, key: key, value: value, op: op);

  // Level chip factory (key is ignored but kept as 'level' for label consistency)
  factory _ChipFilter.level({required String value, required _ChipOp op}) =>
      _ChipFilter._(kind: _ChipKind.level, key: 'level', value: value, op: op);

  bool get isPresenceOnly => kind == _ChipKind.tag && op == _ChipOp.exact && value.isEmpty;
  bool get isLevel => kind == _ChipKind.level;

  _ChipFilter copyWith({String? key, String? value, _ChipOp? op, _ChipKind? kind}) => _ChipFilter._(
        kind: kind ?? this.kind,
        key: key ?? this.key,
        value: value ?? this.value,
        op: op ?? this.op,
      );
}

class _LogsPageState extends State<LogsPage> {
  final List<LogEvent> _all = [];
  // Structured tags insight
  final Set<String> _seenKeys = {};
  final Map<String, Set<String>> _seenValuesByKey = {};
  StreamSubscription<LogEvent>? _sub;

  // Filters
  // Per-chip filters: each chip targets a key with operator (exact | regex) and an optional value
  // Combination: AND across different keys, OR within chips of the same key
  final List<_ChipFilter> _chips = [];

  // Known log levels for exact level chips and styling
  static const Set<String> _knownLevels = {'debug', 'info', 'warn', 'error'};

  // Builder controls for adding a new exact filter pill
  String? _newFilterKey;
  String _newFilterValue = '';
  _ChipOp _newFilterOp = _ChipOp.exact;

  // Value pattern filter (contains/regex). Optionally scoped to a single key.
  final TextEditingController _valuePatternCtrl = TextEditingController(); // partial/regex filter for values
  String? _patternKey; // when null, search across all tag values
  bool _useRegex = false;
  bool _caseSensitive = false;
  final TextEditingController _textCtrl = TextEditingController(); // global search across rendered line
  final FocusNode _searchFocus = FocusNode();
  final Set<String> _levels = {'debug', 'info', 'warn', 'error'}; // selected levels
  bool _paused = false;

  static const int _maxItems = 500;

  @override
  void initState() {
    super.initState();
    _sub = LoggingService.instance.listenAll().listen((e) {
      if (_paused) return;
      setState(() {
        _all.add(e);
        // collect keys and values
        for (final entry in e.tags.entries) {
          _seenKeys.add(entry.key);
          final set = _seenValuesByKey.putIfAbsent(entry.key, () => <String>{});
          for (final v in entry.value) {
            set.add(v);
          }
        }
        if (_all.length > _maxItems) {
          _all.removeRange(0, _all.length - _maxItems);
        }
      });
    });
    // One-time normalization in case there are legacy level-as-tag chips restored by hot reload
    _normalizeLegacyLevelChips();
    _dedupeChipsOnce();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _valuePatternCtrl.dispose();
    _textCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            tooltip: _paused ? 'Resume' : 'Pause',
            onPressed: () => setState(() => _paused = !_paused),
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: _all.isEmpty
                ? null
                : () => setState(() {
                      _all.clear();
                    }),
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final e = filtered[index];
                return _LogTile(event: e);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Convert legacy level-tag chips (kind==tag && key=='level') into proper level kind chips.
  // Drop presence-only level chips (level:any) as they are not meaningful.
  void _normalizeLegacyLevelChips() {
    for (int i = 0; i < _chips.length; i++) {
      final c = _chips[i];
      if (c.kind == _ChipKind.tag && c.key == 'level') {
        if (c.value.trim().isEmpty) {
          // remove presence-only level chip
          _chips.removeAt(i);
          i--;
        } else {
          // migrate to level kind and enforce exact op
          _chips[i] = _ChipFilter.level(value: c.value, op: _ChipOp.exact);
        }
      } else if (c.kind == _ChipKind.level) {
        // enforce exact op for level chips
        if (c.op != _ChipOp.exact) {
          _chips[i] = c.copyWith(op: _ChipOp.exact);
        }
      }
    }
  }

  // Create a stable identity string for a chip to enforce uniqueness
  String _chipId(_ChipFilter c) => '${c.kind}|${c.key}|${c.op}|${c.value}';

  // Returns true if an equivalent chip already exists in `_chips`.
  // Optionally ignore the chip at `exceptIndex` (used when toggling).
  bool _hasChip(_ChipFilter candidate, {int? exceptIndex}) {
    final id = _chipId(candidate);
    for (int i = 0; i < _chips.length; i++) {
      if (exceptIndex != null && i == exceptIndex) continue;
      if (_chipId(_chips[i]) == id) return true;
    }
    return false;
  }

  // Adds chip only if not present; returns true when added, false if duplicate
  bool _addChipUnique(_ChipFilter c) {
    if (_hasChip(c)) return false;
    _chips.add(c);
    return true;
  }

  // One-time deduplication to sanitize any duplicates (e.g., after hot reload)
  void _dedupeChipsOnce() {
    if (_chips.isEmpty) return;
    final seen = <String>{};
    final deduped = <_ChipFilter>[];
    for (final c in _chips) {
      final id = _chipId(c);
      if (seen.add(id)) {
        deduped.add(c);
      }
    }
    if (deduped.length != _chips.length) {
      _chips
        ..clear()
        ..addAll(deduped);
    }
  }

  Widget _buildFilters(BuildContext context) {
    final chips = <Widget>[];
    if (_chips.isNotEmpty) {
      for (int i = 0; i < _chips.length; i++) {
        final c = _chips[i];
        final label = c.isLevel
            ? 'level = ${c.value}'
            : c.isPresenceOnly
                ? '${c.key}: any'
                : c.op == _ChipOp.exact
                    ? '${c.key} = ${c.value}'
                    : '${c.key} ~ /${c.value}/';

        // Special styling for level chips: color according to exact level value when recognized
        Color? levelColor;
        if (c.isLevel) {
          final known = _knownLevels.contains(c.value);
          levelColor = known ? _LogTile._levelColor(context, c.value) : Theme.of(context).colorScheme.primary;
        }

        chips.add(InputChip(
          label: Text(label),
          tooltip: c.isLevel ? 'Delete to remove' : 'Tap to toggle operator, delete to remove',
          backgroundColor: c.isLevel ? levelColor!.withOpacity(0.12) : null,
          labelStyle: c.isLevel ? TextStyle(color: levelColor) : null,
          onPressed: c.isLevel
              ? null
              : () {
                  setState(() {
                    // Toggle operator for non-presence tag chips only
                    if (!c.isPresenceOnly) {
                      if (c.value.trim().isEmpty) return; // cannot be regex with empty
                      final toggled = c.copyWith(op: c.op == _ChipOp.exact ? _ChipOp.regex : _ChipOp.exact);
                      // If toggled variant already exists elsewhere, skip change to keep uniqueness
                      if (_hasChip(toggled, exceptIndex: i)) return;
                      _chips[i] = toggled;
                    }
                  });
                },
          onDeleted: () => setState(() {
            _chips.removeAt(i);
          }),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          // Combined chip + text search input
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _searchFocus.requestFocus(),
              child: InputDecorator(
                isFocused: _searchFocus.hasFocus,
                isEmpty: false,
                decoration: const InputDecoration(
                  labelText: 'Search logs',
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
                    // The free-text search input occupies remaining space
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 120),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Expanded(
                              child: TextField(
                                focusNode: _searchFocus,
                                controller: _textCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Search in time, level, tags or message',
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            if (_textCtrl.text.isNotEmpty)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Clear',
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _textCtrl.clear();
                                  setState(() {});
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
            message: 'Add filters',
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openAddChipDialog,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddChipDialog() async {
    // Drafts for Tag chip
    String? draftKey = _newFilterKey;
    String draftValue = _newFilterValue; // used for regex pattern input
    _ChipOp draftOp = _newFilterOp;
    // Multi-select values for Exact tag chips
    final Set<String> draftSelectedTagValues = <String>{};
    String draftCustomTagValue = '';
    // Drafts for Level chip
    final Set<String> draftSelectedLevels = <String>{};
    // Which kind to add currently
    _ChipKind draftKind = _ChipKind.tag;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlg) {
            void doAddTag() {
              if (draftKey == null) return;
              if (draftOp == _ChipOp.regex) {
                final valueTrim = draftValue.trim();
                if (valueTrim.isEmpty) return;
                try { RegExp(valueTrim, caseSensitive: false); } catch (_) { return; }
                setState(() {
                  _addChipUnique(_ChipFilter.tag(key: draftKey!, value: valueTrim, op: _ChipOp.regex));
                  _newFilterKey = null;
                  _newFilterValue = '';
                  _newFilterOp = _ChipOp.exact;
                });
                Navigator.of(context).pop();
                return;
              }
              // Exact: add multiple values from checkboxes/custom, or presence-only if none
              final valuesToAdd = <String>{...draftSelectedTagValues};
              final customTrim = draftCustomTagValue.trim();
              if (customTrim.isNotEmpty) {
                valuesToAdd.add(customTrim);
              }
              setState(() {
                if (valuesToAdd.isEmpty) {
                  // presence-only chip (exact with empty value)
                  _addChipUnique(_ChipFilter.tag(key: draftKey!, value: '', op: _ChipOp.exact));
                } else {
                  final list = valuesToAdd.toList()..sort();
                  for (final v in list) {
                    _addChipUnique(_ChipFilter.tag(key: draftKey!, value: v, op: _ChipOp.exact));
                  }
                }
                _newFilterKey = null;
                _newFilterValue = '';
                _newFilterOp = _ChipOp.exact;
              });
              Navigator.of(context).pop();
            }

            void doAddLevelMulti(Set<String> levels) {
              if (levels.isEmpty) return;
              setState(() {
                for (final lvl in levels) {
                  if (_knownLevels.contains(lvl)) {
                    _addChipUnique(_ChipFilter.level(value: lvl, op: _ChipOp.exact));
                  }
                }
              });
              Navigator.of(context).pop();
            }

            final keys = (<String>{..._seenKeys}..removeWhere((e) => e.isEmpty)).toList()
              ..sort((a, b) {
                return a.compareTo(b);
              });
            return AlertDialog(
              title: const Text('Add filter'),
              // Wrap the dialog content with SingleChildScrollView to avoid
              // asking a lazy RenderViewport (e.g., ListView) for intrinsic
              // dimensions. This uses a ShrinkWrappingViewport under the hood
              // which supports intrinsics and plays nicely with AlertDialog.
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Kind selector
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<_ChipKind>(
                          segments: const [
                            ButtonSegment<_ChipKind>(value: _ChipKind.tag, label: Text('Tag')),
                            ButtonSegment<_ChipKind>(value: _ChipKind.level, label: Text('Level')),
                          ],
                          selected: {draftKind},
                          onSelectionChanged: (s) => setDlg(() => draftKind = s.first),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Key
                  if (draftKind == _ChipKind.tag) ...[
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Key',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: draftKey,
                          isExpanded: true,
                          hint: const Text('Select a key'),
                          items: [
                            for (final k in keys)
                              DropdownMenuItem<String>(value: k, child: Text(k, overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setDlg(() {
                            // when key changes, clear selections
                            draftKey = v;
                            draftSelectedTagValues.clear();
                            draftCustomTagValue = '';
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Match',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<_ChipOp>(
                          value: draftOp,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem<_ChipOp>(value: _ChipOp.exact, child: Text('Exact value')),
                            DropdownMenuItem<_ChipOp>(value: _ChipOp.regex, child: Text('Regex')),
                          ],
                          onChanged: (v) => setDlg(() {
                            draftOp = v ?? _ChipOp.exact;
                            // clear inputs when switching modes
                            draftSelectedTagValues.clear();
                            draftCustomTagValue = '';
                            draftValue = '';
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (draftOp == _ChipOp.regex) ...[
                      TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Regex pattern',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(text: draftValue),
                        onChanged: (v) => draftValue = v,
                        onSubmitted: (_) => doAddTag(),
                      ),
                    ] else ...[
                      // Exact: show scrollable checkbox list of known values + custom input
                      if (draftKey == null)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Select a key to see its values'),
                        )
                      else ...[
                        // values list
                        Builder(builder: (context) {
                          final vals = (_seenValuesByKey[draftKey!] ?? const <String>{}).toList()
                            ..removeWhere((e) => e.trim().isEmpty)
                            ..sort();
                          if (vals.isEmpty) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('No known values yet'),
                            );
                          }
                          // Avoid ListView inside AlertDialog content to prevent
                          // intrinsic dimension queries on RenderViewport. Use a
                          // fixed-height box with SingleChildScrollView + Column.
                          return SizedBox(
                            height: 240,
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final val in vals)
                                      CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        title: Text(val, overflow: TextOverflow.ellipsis),
                                        value: draftSelectedTagValues.contains(val),
                                        onChanged: (c) {
                                          setDlg(() {
                                            if (c == true) {
                                              draftSelectedTagValues.add(val);
                                            } else {
                                              draftSelectedTagValues.remove(val);
                                            }
                                          });
                                        },
                                        controlAffinity: ListTileControlAffinity.leading,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Or enter a custom value',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          controller: TextEditingController(text: draftCustomTagValue),
                          onChanged: (v) => draftCustomTagValue = v,
                          onSubmitted: (_) => doAddTag(),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tip: Leave all unchecked and custom empty to add presence-only (key:any).',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ] else ...[
                    // Level chip UI (no regex; multi-select via checkboxes)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select levels', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final l in _knownLevels)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(l),
                            value: draftSelectedLevels.contains(l),
                            onChanged: (checked) {
                              setDlg(() {
                                if (checked == true) {
                                  draftSelectedLevels.add(l);
                                } else {
                                  draftSelectedLevels.remove(l);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton.icon(
                  onPressed: () {
                    if (draftKind == _ChipKind.tag) {
                      final keyOk = draftKey != null;
                      if (!keyOk) return;
                      if (draftOp == _ChipOp.regex) {
                        final valueTrim = draftValue.trim();
                        if (valueTrim.isEmpty) return;
                        try { RegExp(valueTrim, caseSensitive: false); } catch (_) { return; }
                      }
                      // For exact, no further validation needed; presence-only allowed
                      doAddTag();
                    } else {
                      if (draftSelectedLevels.isEmpty) return;
                      doAddLevelMulti(draftSelectedLevels);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // (legacy filters modal removed)

  List<LogEvent> _filtered() {
    final globalTxt = _textCtrl.text.trim().toLowerCase();
    final valueQuery = _valuePatternCtrl.text.trim();
    RegExp? regex;
    if (_useRegex && valueQuery.isNotEmpty) {
      try {
        regex = RegExp(valueQuery, caseSensitive: _caseSensitive);
      } catch (_) {
        // invalid regex -> no item matches to avoid crashes
        return const <LogEvent>[];
      }
    }
    return _all.where((e) {
      // Level chips handling
      final levelChips = _chips.where((c) => c.isLevel).toList();
      if (levelChips.isEmpty) {
        if (_levels.isNotEmpty && !_levels.contains(e.level)) return false; // legacy selection
      } else {
        bool anyLevelMatch = false;
        for (final c in levelChips) {
          if (e.level == c.value) { anyLevelMatch = true; break; }
        }
        if (!anyLevelMatch) return false;
      }
      // Per-chip filters: AND across keys, OR within chips for same key
      final tagChips = _chips.where((c) => c.kind == _ChipKind.tag).toList();
      if (tagChips.isNotEmpty) {
        final Map<String, List<_ChipFilter>> byKey = {};
        for (final c in tagChips) {
          byKey.putIfAbsent(c.key, () => <_ChipFilter>[]).add(c);
        }
        for (final entry in byKey.entries) {
          final key = entry.key;
          final chipsForKey = entry.value;

          final eventVals = e.tags[key];
          if (eventVals == null) return false; // key not present
          bool anyMatch = false;
          // Precompute lowercase values for case-insensitive exact shortcut and regex matching
          final lowerVals = eventVals.map((v) => v.toLowerCase()).toList();
          for (final c in chipsForKey) {
            if (c.isPresenceOnly) { anyMatch = true; break; }
            if (c.op == _ChipOp.exact) {
              if (eventVals.contains(c.value)) { anyMatch = true; break; }
            } else {
              // regex, case-insensitive by default
              try {
                final r = RegExp(c.value, caseSensitive: false);
                for (int i = 0; i < lowerVals.length; i++) {
                  if (r.hasMatch(eventVals[i])) { anyMatch = true; break; }
                }
                if (anyMatch) break;
              } catch (_) {
                // invalid regex should not happen
              }
            }
          }
          if (!anyMatch) return false;
        }
      }
      // value partial/pattern filter
      if (valueQuery.isNotEmpty || regex != null) {
        final Iterable<String> values = _patternKey != null
            ? (e.tags[_patternKey!] ?? const <String>[])
            : e.tags.values.expand((v) => v);
        bool hit = false;
        if (regex != null) {
          for (final v in values) { if (regex!.hasMatch(v)) { hit = true; break; } }
        } else {
          if (_caseSensitive) {
            for (final v in values) { if (v.contains(valueQuery)) { hit = true; break; } }
          } else {
            final needle = valueQuery.toLowerCase();
            for (final v in values) { if (v.toLowerCase().contains(needle)) { hit = true; break; } }
          }
        }
        if (!hit) return false;
      }
      // global text search
      if (globalTxt.isNotEmpty) {
        final line = _searchableLine(e);
        if (!line.contains(globalTxt)) return false;
      }
      return true;
    }).toList();
  }

  // Build a normalized single-line representation used for full-text searches.
  String _searchableLine(LogEvent e) {
    final time = _formatTime(e.timestamp);
    final level = e.level.toUpperCase();
    final src = _joinedTags(e);
    final line = '[$time] $level $src — ${e.message}';
    return line.toLowerCase();
  }

  String _joinedTags(LogEvent e) {
    if (e.tags.isEmpty) return '(unspecified)';
    final keys = e.tags.keys.toList()..sort();
    final parts = <String>[];
    for (final k in keys) {
      final values = e.tags[k] ?? const <String>[];
      if (values.isEmpty) continue;
      final v = values.length == 1 ? values.first : '[' + values.join(', ') + ']';
      parts.add('$k=$v');
    }
    return parts.join(' • ');
  }

  static String _formatTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }
}

class _LogTile extends StatelessWidget {
  final LogEvent event;
  const _LogTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(context, event.level);
    final time = _formatTime(event.timestamp);
    final level = event.level.toUpperCase();
    final srcDisplay = _joinedTagsStatic(event);
    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, size: 12, color: color),
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: '[$time] ', style: TextStyle(color: Theme.of(context).hintColor, fontFeatures: const [FontFeature.tabularFigures()])),
            TextSpan(text: level, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            const TextSpan(text: '  '),
            TextSpan(text: srcDisplay, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ],
        ),
      ),
      subtitle: Text(event.message),
    );
  }

  static String _formatTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  static Color _levelColor(BuildContext context, String level) {
    final cs = Theme.of(context).colorScheme;
    switch (level) {
      case 'debug':
        return cs.outline;
      case 'info':
        return cs.primary;
      case 'warn':
        return Colors.orange;
      case 'error':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  static String _joinedTagsStatic(LogEvent e) {
    if (e.tags.isEmpty) return '(unspecified)';
    final keys = e.tags.keys.toList()..sort();
    final parts = <String>[];
    for (final k in keys) {
      final values = e.tags[k] ?? const <String>[];
      if (values.isEmpty) continue;
      final v = values.length == 1 ? values.first : '[' + values.join(', ') + ']';
      parts.add('$k=$v');
    }
    return parts.join(' • ');
  }
}