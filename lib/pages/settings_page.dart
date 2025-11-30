import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  final Locale? initialLocale; // null → system default
  final void Function(Locale? locale) onChangedLocale;

  const SettingsPage({
    super.key,
    required this.initialLocale,
    required this.onChangedLocale,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = <Locale?>[null, ...AppLocalizations.supportedLocales];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language),
                      const SizedBox(width: 8),
                      Text(
                        t.languageTooltip, // reuse existing label
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final loc in options)
                        ChoiceChip(
                          label: Text(_localeLabel(loc)),
                          selected: _equalsLocale(loc, initialLocale),
                          onSelected: (selected) {
                            if (!selected) return;
                            onChangedLocale(loc);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _localeDescription(initialLocale),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _equalsLocale(Locale? a, Locale? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b; // both null → true, else false
  return a.languageCode == b.languageCode && (a.countryCode ?? '') == (b.countryCode ?? '');
}

String _localeLabel(Locale? locale) {
  if (locale == null) return 'System';
  switch (locale.languageCode) {
    case 'en':
      return 'English';
    case 'pl':
      return 'Polski';
    default:
      return locale.toLanguageTag();
  }
}

String _localeDescription(Locale? locale) {
  if (locale == null) {
    return 'Follow system language';
  }
  return 'App language: ${_localeLabel(locale)}';
}
