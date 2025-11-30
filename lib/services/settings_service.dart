import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for persisting settings
class _PrefsKeys {
  static const String languageCode = 'settings.languageCode';
  static const String countryCode = 'settings.countryCode';
}

/// Simple model for app settings.
class AppSettings {
  final Locale? locale; // null → follow system

  const AppSettings({this.locale});

  AppSettings copyWith({Locale? locale}) => AppSettings(locale: locale);
}

/// Service responsible for loading/saving settings to local storage.
class SettingsService {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_PrefsKeys.languageCode);
    final country = prefs.getString(_PrefsKeys.countryCode);
    if (lang == null || lang.isEmpty) {
      return const AppSettings(locale: null);
    }
    return AppSettings(
      locale: country != null && country.isNotEmpty ? Locale(lang, country) : Locale(lang),
    );
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
  }
}
