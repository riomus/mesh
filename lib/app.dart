import 'package:flutter/material.dart';
import 'pages/scanner_page.dart';
import 'pages/settings_page.dart';
import 'services/settings_service.dart';
import 'pages/logs_page.dart';

import '../l10n/app_localizations.dart';
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
  int _selectedIndex = 0; // 0 = Scanner, 1 = Logs

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
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
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
          : Scaffold(
              body: IndexedStack(
                index: _selectedIndex,
                children: [
                  ScannerPage(
                    onToggleTheme: _toggleTheme,
                    themeMode: _themeMode,
                    onOpenSettings: (ctx) {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            initialLocale: _locale,
                            onChangedLocale: _setLocale,
                            onToggleTheme: _toggleTheme,
                            themeMode: _themeMode,
                          ),
                        ),
                      );
                    },
                  ),
                  LogsPage(
                    onToggleTheme: _toggleTheme,
                    themeMode: _themeMode,
                    onOpenSettings: (ctx) {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsPage(
                            initialLocale: _locale,
                            onChangedLocale: _setLocale,
                            onToggleTheme: _toggleTheme,
                            themeMode: _themeMode,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _selectedIndex,
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.devices), label: 'Devices'),
                  NavigationDestination(icon: Icon(Icons.list_alt), label: 'Logs'),
                ],
                onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              ),
            ),
    );
  }
}
