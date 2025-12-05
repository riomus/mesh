import 'package:flutter/material.dart';
import 'navigation/navigator_key.dart';
import 'pages/scanner_page.dart';
import 'pages/settings_page.dart';
import 'services/settings_service.dart';
import 'pages/logs_page.dart';
import 'pages/events_page.dart';
import 'pages/nodes_page.dart';
import 'pages/traces_page.dart';
import 'services/device_state_service.dart';
import 'services/notification_service.dart';
import 'services/traceroute_service.dart';

import 'l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  AppSettings _settingsData = const AppSettings();
  final SettingsService _settings = SettingsService();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    DeviceStateService.instance.init();
    NotificationService.instance.init();
    // Initialize TracerouteService to ensure it subscribes to events immediately
    TracerouteService.instance;
  }

  Future<void> _loadSettings() async {
    final s = await _settings.load();
    setState(() {
      _settingsData = s;
      _loaded = true;
    });
  }

  void _toggleTheme() {
    // Toggle relative to the current EFFECTIVE brightness.
    // If we're in system mode, respect the platform's brightness for the first toggle.
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isCurrentlyDark =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    setState(() {
      _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _settingsData = newSettings;
    });
    // Persist
    _settings.save(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final baseSeed = Colors.indigo;
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: baseSeed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: baseSeed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      locale: _settingsData.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: !_loaded
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : Home(
              settings: _settingsData,
              onUpdateSettings: _updateSettings,
              toggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
    );
  }
}

class Home extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onUpdateSettings;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  const Home({
    super.key,
    required this.settings,
    required this.onUpdateSettings,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex =
      0; // 0 = Scanner, 1 = Logs, 2 = Events, 3 = Nodes, 4 = Traces

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isProtected =
        widget.settings.adminPassword != null &&
        widget.settings.adminPassword!.isNotEmpty;

    // Define all possible pages and destinations
    final allPages = <Widget>[
      ScannerPage(
        onToggleTheme: widget.toggleTheme,
        themeMode: widget.themeMode,
        onOpenSettings: (ctx) {
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => SettingsPage(
                settings: widget.settings,
                onChangedSettings: widget.onUpdateSettings,
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
                settings: widget.settings,
                onChangedSettings: widget.onUpdateSettings,
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
                settings: widget.settings,
                onChangedSettings: widget.onUpdateSettings,
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
                settings: widget.settings,
                onChangedSettings: widget.onUpdateSettings,
                onToggleTheme: widget.toggleTheme,
                themeMode: widget.themeMode,
              ),
            ),
          );
        },
      ),
      const TracesPage(),
    ];

    final allDestinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.devices),
        label: t.devicesTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.list_alt),
        label: t.logsTitle,
      ),
      NavigationDestination(
        icon: const Icon(Icons.event_note),
        label: t.eventsTitle,
      ),
      NavigationDestination(icon: const Icon(Icons.hub), label: t.nodesTitle),
      NavigationDestination(icon: const Icon(Icons.route), label: t.traces),
    ];

    final allRailDestinations = <NavigationRailDestination>[
      NavigationRailDestination(
        icon: const Icon(Icons.devices),
        label: Text(t.devicesTab),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.list_alt),
        label: Text(t.logsTitle),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.event_note),
        label: Text(t.eventsTitle),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.hub),
        label: Text(t.nodesTitle),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.route),
        label: Text(t.traces),
      ),
    ];

    // Filter based on protection
    final visiblePages = <Widget>[];
    final visibleDestinations = <NavigationDestination>[];
    final visibleRailDestinations = <NavigationRailDestination>[];

    // Always show Scanner (Devices)
    visiblePages.add(allPages[0]);
    visibleDestinations.add(allDestinations[0]);
    visibleRailDestinations.add(allRailDestinations[0]);

    if (!isProtected) {
      // Show Logs
      visiblePages.add(allPages[1]);
      visibleDestinations.add(allDestinations[1]);
      visibleRailDestinations.add(allRailDestinations[1]);
      // Show Events
      visiblePages.add(allPages[2]);
      visibleDestinations.add(allDestinations[2]);
      visibleRailDestinations.add(allRailDestinations[2]);
      // Show Nodes
      visiblePages.add(allPages[3]);
      visibleDestinations.add(allDestinations[3]);
      visibleRailDestinations.add(allRailDestinations[3]);
      // Show Traces
      visiblePages.add(allPages[4]);
      visibleDestinations.add(allDestinations[4]);
      visibleRailDestinations.add(allRailDestinations[4]);
    } else {
      // If protected, maybe we still want Nodes?
      // "only chatting should be left".
      // I'll hide Nodes too as it is "advanced" mesh info.
      // If the user wants it back, they can ask.
      // But wait, I decided to keep Nodes in my thought process?
      // "I will hide Logs and Events. I will keep Nodes for now as it wasn't explicitly named"
      // Let's keep Nodes for now.
      visiblePages.add(allPages[3]);
      visibleDestinations.add(allDestinations[3]);
      visibleRailDestinations.add(allRailDestinations[3]);
      // Also show Traces
      visiblePages.add(allPages[4]);
      visibleDestinations.add(allDestinations[4]);
      visibleRailDestinations.add(allRailDestinations[4]);
    }

    // Ensure selected index is valid
    if (_selectedIndex >= visiblePages.length) {
      _selectedIndex = 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Mobile layout
          return Scaffold(
            body: IndexedStack(index: _selectedIndex, children: visiblePages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              destinations: visibleDestinations,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            ),
          );
        } else {
          // Desktop/Tablet layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (i) =>
                      setState(() => _selectedIndex = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: visibleRailDestinations,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: visiblePages,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
