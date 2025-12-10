import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// Removed: import 'dart:ui' show FontFeature; (unnecessary)

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/logging_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/text_sanitize.dart';

/// A reusable logs viewer widget with rich filtering, searching and formatting.
///
/// By default it subscribes to `LoggingService.instance.listenAll()`, but you can
/// provide a custom [stream] to scope logs (e.g., to a specific device).
class LogsViewer extends StatefulWidget {
  final Stream<LogEvent>? stream;
  final int maxItems;
  final double? maxHeight; // when embedded inside another page/section

  const LogsViewer({
    super.key,
    this.stream,
    this.maxItems = 500,
    this.maxHeight,
  });

  @override
  State<LogsViewer> createState() => _LogsViewerState();
}

// Filter chip operator
enum _ChipOp { exact, regex }

// Filter chip kind (separates level from generic tag chips)
enum _ChipKind { tag, level }

// Single filter chip descriptor
class _ChipFilter {
  final _ChipKind kind;
  final String key; // only meaningful for tag chips
  final String
  value; // for tag: empty + exact => presence-only; for level: must be non-empty
  final _ChipOp op;

  const _ChipFilter._({
    required this.kind,
    required this.key,
    required this.value,
    required this.op,
  });

  // Tag chip factory
  factory _ChipFilter.tag({
    required String key,
    required String value,
    required _ChipOp op,
  }) => _ChipFilter._(kind: _ChipKind.tag, key: key, value: value, op: op);

  // Level chip factory (key is ignored but kept as 'level' for label consistency)
  factory _ChipFilter.level({required String value, required _ChipOp op}) =>
      _ChipFilter._(kind: _ChipKind.level, key: 'level', value: value, op: op);

  bool get isPresenceOnly =>
      kind == _ChipKind.tag && op == _ChipOp.exact && value.isEmpty;
  bool get isLevel => kind == _ChipKind.level;

  _ChipFilter copyWith({
    String? key,
    String? value,
    _ChipOp? op,
    _ChipKind? kind,
  }) => _ChipFilter._(
    kind: kind ?? this.kind,
    key: key ?? this.key,
    value: value ?? this.value,
    op: op ?? this.op,
  );
}

class _LogsViewerState extends State<LogsViewer> {
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
  final String _newFilterValue = '';
  final _ChipOp _newFilterOp = _ChipOp.exact;

  // Value pattern filter (contains/regex). Optionally scoped to a single key.
  final TextEditingController _valuePatternCtrl =
      TextEditingController(); // partial/regex filter for values
  String? _patternKey; // when null, search across all tag values
  // ignore: prefer_final_fields
  bool _useRegex = false;
  // ignore: prefer_final_fields
  bool _caseSensitive = false;
  final TextEditingController _textCtrl =
      TextEditingController(); // global search across rendered line
  final FocusNode _searchFocus = FocusNode();
  final Set<String> _levels = {
    'debug',
    'info',
    'warn',
    'error',
  }; // selected levels (legacy support)
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _sub = (widget.stream ?? LoggingService.instance.listenWithReplay()).listen(
      (e) {
        if (_paused) return;
        setState(() {
          _all.add(e);
          // collect keys and values
          for (final entry in e.tags.entries) {
            _seenKeys.add(entry.key);
            final set = _seenValuesByKey.putIfAbsent(
              entry.key,
              () => <String>{},
            );
            for (final v in entry.value) {
              set.add(v);
            }
          }
          if (_all.length > widget.maxItems) {
            _all.removeRange(0, _all.length - widget.maxItems);
          }
        });
      },
    );
    _normalizeLegacyLevelChips();
    _dedupeChipsOnce();
  }

  @override
  void didUpdateWidget(covariant LogsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _sub?.cancel();
      _sub = (widget.stream ?? LoggingService.instance.listenWithReplay())
          .listen((e) {
            if (_paused) return;
            setState(() {
              _all.add(e);
              for (final entry in e.tags.entries) {
                _seenKeys.add(entry.key);
                final set = _seenValuesByKey.putIfAbsent(
                  entry.key,
                  () => <String>{},
                );
                for (final v in entry.value) {
                  set.add(v);
                }
              }
              if (_all.length > widget.maxItems) {
                _all.removeRange(0, _all.length - widget.maxItems);
              }
            });
          });
    }
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
    final list = ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final e = filtered[index];
        return _LogTile(event: e);
      },
    );

    final content = Column(
      children: [
        _buildTopBar(context),
        const Divider(height: 1),
        Expanded(child: list),
      ],
    );

    if (widget.maxHeight != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: content,
      );
    }
    return content;
  }

  // UI: filters row + text search and chip area with add-filter button and pause/clear controls
  Widget _buildTopBar(BuildContext context) {
    final chips = <Widget>[
      // Render level chips first for prominence
      ..._chips
          .asMap()
          .entries
          .where((e) => e.value.isLevel)
          .map((entry) => _buildChip(entry.key, entry.value)),
      ..._chips
          .asMap()
          .entries
          .where((e) => !e.value.isLevel)
          .map((entry) => _buildChip(entry.key, entry.value)),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          final searchInput = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _searchFocus.requestFocus(),
            child: InputDecorator(
              isFocused: _searchFocus.hasFocus,
              isEmpty: false,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).searchLogs,
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
                            controller: _textCtrl,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              ).searchLogsHint,
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
                            tooltip: AppLocalizations.of(context).clear,
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
          );

          final actions = Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Tooltip(
                message: AppLocalizations.of(context).shareLogs,
                child: IconButton(
                  key: const Key('logs_share_button'),
                  icon: const Icon(Icons.ios_share),
                  onPressed: _shareFilteredLogs,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: AppLocalizations.of(context).fullscreen,
                child: IconButton(
                  key: const Key('logs_fullscreen_button'),
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => Scaffold(
                          appBar: AppBar(
                            title: Text(AppLocalizations.of(context).logsTitle),
                            actions: [
                              IconButton(
                                tooltip: AppLocalizations.of(context).close,
                                icon: const Icon(Icons.close_fullscreen),
                                onPressed: () => Navigator.of(ctx).maybePop(),
                              ),
                            ],
                          ),
                          body: LogsViewer(stream: widget.stream),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: AppLocalizations.of(context).addFilters,
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openAddChipDialog,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _paused
                    ? AppLocalizations.of(context).resume
                    : AppLocalizations.of(context).pause,
                child: IconButton(
                  icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                  onPressed: () => setState(() => _paused = !_paused),
                ),
              ),
              Tooltip(
                message: AppLocalizations.of(context).clearAll,
                child: IconButton(
                  onPressed: _all.isEmpty
                      ? null
                      : () => setState(() {
                          _all.clear();
                        }),
                  icon: const Icon(Icons.clear_all),
                ),
              ),
            ],
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchInput,
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: actions,
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(child: searchInput),
                const SizedBox(width: 8),
                actions,
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _shareFilteredLogs() async {
    try {
      final items = _filtered()
          .map(
            (e) => {
              'timestamp': e.timestamp.toIso8601String(),
              'tags': e.tags,
              'level': e.level,
              'message': e.message,
            },
          )
          .toList(growable: false);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(items);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      final ts = DateTime.now();
      final name =
          'logs-${ts.year.toString().padLeft(4, '0')}'
          '${ts.month.toString().padLeft(2, '0')}'
          '${ts.day.toString().padLeft(2, '0')}-'
          '${ts.hour.toString().padLeft(2, '0')}'
          '${ts.minute.toString().padLeft(2, '0')}'
          '${ts.second.toString().padLeft(2, '0')}.json';
      final file = XFile.fromData(
        bytes,
        name: name,
        mimeType: 'application/json',
      );
      await Share.shareXFiles([
        file,
      ], text: AppLocalizations.of(context).logsExport);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToShareLogs(err.toString()),
            ),
          ),
        );
      }
    }
  }

  // Build a single filter chip
  Widget _buildChip(int index, _ChipFilter chip) {
    final label = chip.isLevel
        ? 'level:${chip.value}'
        : chip.op == _ChipOp.exact
        ? (chip.value.isEmpty ? chip.key : '${chip.key}=${chip.value}')
        : '${chip.key}~/${chip.value}/i';
    return InputChip(
      label: Text(safeText(label)),
      onDeleted: () => setState(() => _chips.removeAt(index)),
    );
  }

  // Dialog to add a new chip or level selection
  Future<void> _openAddChipDialog() async {
    // Prepare defaults
    String? draftKey =
        _newFilterKey ?? (_seenKeys.isNotEmpty ? _seenKeys.first : null);
    String draftValue = _newFilterValue;
    _ChipOp draftOp = _newFilterOp;
    _ChipKind draftKind = _ChipKind.tag;
    final draftSelectedLevels = <String>{};

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlg) {
            void doAddTag() {
              final key = draftKey!;
              if (draftOp == _ChipOp.exact) {
                final c = _ChipFilter.tag(
                  key: key,
                  value: draftValue.trim(),
                  op: _ChipOp.exact,
                );
                setState(() => _addChipUnique(c));
              } else {
                final valueTrim = draftValue.trim();
                if (valueTrim.isEmpty) return; // regex value must not be empty
                try {
                  RegExp(valueTrim, caseSensitive: false);
                } catch (_) {
                  return; // invalid regex
                }
                final c = _ChipFilter.tag(
                  key: key,
                  value: valueTrim,
                  op: _ChipOp.regex,
                );
                setState(() => _addChipUnique(c));
              }
              Navigator.of(context).pop();
            }

            void doAddLevelMulti(Set<String> levels) {
              bool added = false;
              for (final l in levels) {
                final c = _ChipFilter.level(value: l, op: _ChipOp.exact);
                if (_addChipUnique(c)) added = true;
              }
              if (added) setState(() {});
              Navigator.of(context).pop();
            }

            return AlertDialog(
              title: Text(AppLocalizations.of(context).addFilterTitle),
              content: SizedBox(
                width: 420,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Cap the dialog content height and allow scrolling when overflowing
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Toggle between tag or level filters
                        SegmentedButton<_ChipKind>(
                          segments: [
                            ButtonSegment(
                              value: _ChipKind.tag,
                              label: Text(AppLocalizations.of(context).tag),
                            ),
                            ButtonSegment(
                              value: _ChipKind.level,
                              label: Text(AppLocalizations.of(context).level),
                            ),
                          ],
                          selected: {draftKind},
                          onSelectionChanged: (s) =>
                              setDlg(() => draftKind = s.first),
                        ),
                        const SizedBox(height: 8),
                        if (draftKind == _ChipKind.tag) ...[
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).key,
                            ),
                            initialValue: draftKey,
                            items: [
                              if (draftKey != null)
                                DropdownMenuItem(
                                  value: draftKey,
                                  child: Text(safeText(draftKey!)),
                                ),
                              ..._seenKeys
                                  .where((k) => k != draftKey)
                                  .toList()
                                  .map(
                                    (k) => DropdownMenuItem(
                                      value: k,
                                      child: Text(safeText(k)),
                                    ),
                                  ),
                            ],
                            onChanged: (v) => setDlg(() => draftKey = v),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: draftValue,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      context,
                                    ).valueEmptyPresence,
                                  ),
                                  onChanged: (v) => draftValue = v,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<_ChipOp>(
                                value: draftOp,
                                items: [
                                  DropdownMenuItem(
                                    value: _ChipOp.exact,
                                    child: Text(
                                      AppLocalizations.of(context).exact,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: _ChipOp.regex,
                                    child: Text(
                                      AppLocalizations.of(context).regex,
                                    ),
                                  ),
                                ],
                                onChanged: (op) =>
                                    setDlg(() => draftOp = op ?? _ChipOp.exact),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (draftKey != null) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final v
                                    in (_seenValuesByKey[draftKey!] ??
                                            const <String>{})
                                        .take(18))
                                  ActionChip(
                                    label: Text(safeText(v)),
                                    onPressed: () =>
                                        setDlg(() => draftValue = v),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).regexTip,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ] else ...[
                          // Level chip UI (no regex; multi-select via checkboxes)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context).selectLevels,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
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
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (draftKind == _ChipKind.tag) {
                      final keyOk = draftKey != null;
                      if (!keyOk) return;
                      if (draftOp == _ChipOp.regex) {
                        final valueTrim = draftValue.trim();
                        if (valueTrim.isEmpty) return;
                        try {
                          RegExp(valueTrim, caseSensitive: false);
                        } catch (_) {
                          return;
                        }
                      }
                      // For exact, no further validation needed; presence-only allowed
                      doAddTag();
                    } else {
                      if (draftSelectedLevels.isEmpty) return;
                      doAddLevelMulti(draftSelectedLevels);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).addAction),
                ),
              ],
            );
          },
        );
      },
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
        if (_levels.isNotEmpty && !_levels.contains(e.level)) {
          return false; // legacy selection
        }
      } else {
        bool anyLevelMatch = false;
        for (final c in levelChips) {
          if (e.level == c.value) {
            anyLevelMatch = true;
            break;
          }
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
            if (c.isPresenceOnly) {
              anyMatch = true;
              break;
            }
            if (c.op == _ChipOp.exact) {
              if (eventVals.contains(c.value)) {
                anyMatch = true;
                break;
              }
            } else {
              // regex, case-insensitive by default
              try {
                final r = RegExp(c.value, caseSensitive: false);
                for (int i = 0; i < lowerVals.length; i++) {
                  if (r.hasMatch(eventVals[i])) {
                    anyMatch = true;
                    break;
                  }
                }
              } catch (_) {
                // invalid regex chip -> treat as no match for safety
              }
            }
            if (anyMatch) break;
          }
          if (!anyMatch) return false; // AND across keys
        }
      }
      // value partial/pattern filter
      if (valueQuery.isNotEmpty || regex != null) {
        final Iterable<String> values = _patternKey != null
            ? (e.tags[_patternKey!] ?? const <String>[])
            : e.tags.values.expand((v) => v);
        bool hit = false;
        final r = regex; // may be null
        if (r != null) {
          for (final v in values) {
            if (r.hasMatch(v)) {
              hit = true;
              break;
            }
          }
        } else {
          if (_caseSensitive) {
            for (final v in values) {
              if (v.contains(valueQuery)) {
                hit = true;
                break;
              }
            }
          } else {
            final needle = valueQuery.toLowerCase();
            for (final v in values) {
              if (v.toLowerCase().contains(needle)) {
                hit = true;
                break;
              }
            }
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
    if (e.tags.isEmpty) return AppLocalizations.of(context).unspecified;
    final keys = e.tags.keys.toList()..sort();
    final parts = <String>[];
    for (final k in keys) {
      final values = e.tags[k] ?? const <String>[];
      if (values.isEmpty) continue;
      final v = values.length == 1 ? values.first : '[${values.join(', ')}]';
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
    final srcDisplay = _joinedTagsStatic(context, event);
    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, size: 12, color: color),
      title: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '[$time] ',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            TextSpan(
              text: level,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
            const TextSpan(text: '  '),
            TextSpan(
              text: safeText(srcDisplay),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
      subtitle: Text(safeText(event.message)),
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

  static String _joinedTagsStatic(BuildContext context, LogEvent e) {
    if (e.tags.isEmpty) return AppLocalizations.of(context).unspecified;
    final keys = e.tags.keys.toList()..sort();
    final parts = <String>[];
    for (final k in keys) {
      final values = e.tags[k] ?? const <String>[];
      if (values.isEmpty) continue;
      final v = values.length == 1 ? values.first : '[${values.join(', ')}]';
      parts.add('$k=$v');
    }
    return parts.join(' • ');
  }
}
