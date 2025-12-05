import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for persisting settings
class _PrefsKeys {
  static const String languageCode = 'settings.languageCode';
  static const String countryCode = 'settings.countryCode';
  static const String adminPassword = 'settings.adminPassword';
  static const String bleHeartbeatInterval = 'settings.bleHeartbeatInterval';
  static const String configTimeout = 'settings.configTimeout';
  static const String tracerouteMinInterval = 'settings.tracerouteMinInterval';
}

/// Simple model for app settings.
class AppSettings {
  final Locale? locale; // null → follow system
  final String? adminPassword;
  final int
  bleHeartbeatIntervalSeconds; // BLE heartbeat interval in seconds (default: 60)
  final int
  configTimeoutSeconds; // Config complete timeout in seconds (default: 15)
  final int
  tracerouteMinIntervalSeconds; // Minimum seconds between traceroute requests (default: 30)

  const AppSettings({
    this.locale,
    this.adminPassword,
    this.bleHeartbeatIntervalSeconds = 60,
    this.configTimeoutSeconds = 15,
    this.tracerouteMinIntervalSeconds = 30,
  });

  AppSettings copyWith({
    Locale? locale,
    String? adminPassword,
    int? bleHeartbeatIntervalSeconds,
    int? configTimeoutSeconds,
    int? tracerouteMinIntervalSeconds,
  }) => AppSettings(
    locale: locale ?? this.locale,
    adminPassword: adminPassword ?? this.adminPassword,
    bleHeartbeatIntervalSeconds:
        bleHeartbeatIntervalSeconds ?? this.bleHeartbeatIntervalSeconds,
    configTimeoutSeconds: configTimeoutSeconds ?? this.configTimeoutSeconds,
    tracerouteMinIntervalSeconds:
        tracerouteMinIntervalSeconds ?? this.tracerouteMinIntervalSeconds,
  );
}

/// Service responsible for loading/saving settings to local storage.
class SettingsService {
  static final SettingsService instance = SettingsService._internal();

  factory SettingsService() {
    return instance;
  }

  SettingsService._internal();

  /// Cached settings, loaded on app start
  AppSettings? _cachedSettings;

  /// Get current settings synchronously (returns null if not yet loaded)
  AppSettings? get current => _cachedSettings;

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_PrefsKeys.languageCode);
    final country = prefs.getString(_PrefsKeys.countryCode);
    final adminPassword = prefs.getString(_PrefsKeys.adminPassword);
    final bleHeartbeatInterval =
        prefs.getInt(_PrefsKeys.bleHeartbeatInterval) ?? 60;
    final configTimeout = prefs.getInt(_PrefsKeys.configTimeout) ?? 15;
    final tracerouteMinInterval =
        prefs.getInt(_PrefsKeys.tracerouteMinInterval) ?? 30;

    Locale? locale;
    if (lang != null && lang.isNotEmpty) {
      locale = country != null && country.isNotEmpty
          ? Locale(lang, country)
          : Locale(lang);
    }

    final settings = AppSettings(
      locale: locale,
      adminPassword: adminPassword,
      bleHeartbeatIntervalSeconds: bleHeartbeatInterval,
      configTimeoutSeconds: configTimeout,
      tracerouteMinIntervalSeconds: tracerouteMinInterval,
    );
    _cachedSettings = settings;
    return settings;
  }

  Future<void> save(AppSettings settings) async {
    _cachedSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    final loc = settings.locale;
    if (loc == null) {
      await prefs.remove(_PrefsKeys.languageCode);
      await prefs.remove(_PrefsKeys.countryCode);
    } else {
      await prefs.setString(_PrefsKeys.languageCode, loc.languageCode);
      final cc = loc.countryCode;
      if (cc == null || cc.isEmpty) {
        await prefs.remove(_PrefsKeys.countryCode);
      } else {
        await prefs.setString(_PrefsKeys.countryCode, cc);
      }
    }

    final pwd = settings.adminPassword;
    if (pwd == null || pwd.isEmpty) {
      await prefs.remove(_PrefsKeys.adminPassword);
    } else {
      await prefs.setString(_PrefsKeys.adminPassword, pwd);
    }

    await prefs.setInt(
      _PrefsKeys.bleHeartbeatInterval,
      settings.bleHeartbeatIntervalSeconds,
    );

    await prefs.setInt(_PrefsKeys.configTimeout, settings.configTimeoutSeconds);

    await prefs.setInt(
      _PrefsKeys.tracerouteMinInterval,
      settings.tracerouteMinIntervalSeconds,
    );
  }
}
