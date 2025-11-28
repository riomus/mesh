import 'package:flutter/material.dart';
import 'pages/scanner_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

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

  @override
  Widget build(BuildContext context) {
    final baseSeed = Colors.indigo;
    return MaterialApp(
      title: 'Mesh BLE Scanner',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: baseSeed, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: baseSeed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: ScannerPage(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}
