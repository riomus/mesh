import 'package:flutter/material.dart';
import 'pages/scanner_page.dart';

import '../l10n/app_localizations.dart';
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

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

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
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
      home: ScannerPage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        onChangeLocale: _setLocale,
        locale: _locale,
      ),
    );
  }
}
