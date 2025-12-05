import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for persisting settings
class _PrefsKeys {
  static const String languageCode = 'settings.languageCode';
  static const String countryCode = 'settings.countryCode';
  static const String adminPassword = 'settings.adminPassword';
}

/// Simple model for app settings.
class AppSettings {
  final Locale? locale; // null → follow system
  final String? adminPassword;

  const AppSettings({this.locale, this.adminPassword});

  AppSettings copyWith({Locale? locale, String? adminPassword}) => AppSettings(
    locale: locale ?? this.locale,
    adminPassword: adminPassword ?? this.adminPassword,
  );
}

/// Service responsible for loading/saving settings to local storage.
class SettingsService {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_PrefsKeys.languageCode);
    final country = prefs.getString(_PrefsKeys.countryCode);
    final adminPassword = prefs.getString(_PrefsKeys.adminPassword);

    Locale? locale;
    if (lang != null && lang.isNotEmpty) {
      locale = country != null && country.isNotEmpty
          ? Locale(lang, country)
          : Locale(lang);
    }

    return AppSettings(locale: locale, adminPassword: adminPassword);
  }

  Future<void> save(AppSettings settings) async {
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
  }
}
