import 'package:flutter/material.dart';
import 'pages/scanner_page.dart';
import 'pages/settings_page.dart';
import 'services/settings_service.dart';
import 'pages/logs_page.dart';
import 'pages/events_page.dart';
import 'pages/nodes_page.dart';

import 'l10n/app_localizations.dart';
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  final SettingsService _settings = SettingsService();
  bool _loaded = false;
  int _selectedIndex = 0; // 0 = Scanner, 1 = Logs, 2 = Events, 3 = Nodes

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await _settings.load();
    setState(() {
      _locale = s.locale;
      _loaded = true;
    });
  }

  void _toggleTheme() {
    // Toggle relative to the current EFFECTIVE brightness.
    // If we're in system mode, respect the platform's brightness for the first toggle.
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isCurrentlyDark = _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    setState(() {
      _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    // Persist
    _settings.save(AppSettings(locale: locale));
  }

  @override
  Widget build(BuildContext context) {
    final baseSeed = Colors.indigo;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: baseSeed, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: baseSeed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: !_loaded
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Home(
              locale: _locale,
              setLocale: _setLocale,
              toggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
    );
  }
}

class Home extends StatefulWidget {
  final Locale? locale;
  final ValueChanged<Locale?> setLocale;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  const Home({
    super.key,
    required this.locale,
    required this.setLocale,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // 0 = Scanner, 1 = Logs, 2 = Events, 3 = Nodes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ScannerPage(
            onToggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
            onOpenSettings: (ctx) {
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    initialLocale: widget.locale,
                    onChangedLocale: widget.setLocale,
                    onToggleTheme: widget.toggleTheme,
                    themeMode: widget.themeMode,
                  ),
                ),
              );
            },
          ),
          LogsPage(
            onToggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
            onOpenSettings: (ctx) {
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    initialLocale: widget.locale,
                    onChangedLocale: widget.setLocale,
                    onToggleTheme: widget.toggleTheme,
                    themeMode: widget.themeMode,
                  ),
                ),
              );
            },
          ),
          EventsPage(
            onToggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
            onOpenSettings: (ctx) {
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    initialLocale: widget.locale,
                    onChangedLocale: widget.setLocale,
                    onToggleTheme: widget.toggleTheme,
                    themeMode: widget.themeMode,
                  ),
                ),
              );
            },
          ),
          NodesPage(
            onToggleTheme: widget.toggleTheme,
            themeMode: widget.themeMode,
            onOpenSettings: (ctx) {
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    initialLocale: widget.locale,
                    onChangedLocale: widget.setLocale,
                    onToggleTheme: widget.toggleTheme,
                    themeMode: widget.themeMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.devices), label: AppLocalizations.of(context).devicesTab),
          NavigationDestination(icon: const Icon(Icons.list_alt), label: AppLocalizations.of(context).logsTitle),
          NavigationDestination(icon: const Icon(Icons.event_note), label: AppLocalizations.of(context).eventsTitle),
          NavigationDestination(icon: const Icon(Icons.hub), label: AppLocalizations.of(context).nodesTitle),
        ],
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
