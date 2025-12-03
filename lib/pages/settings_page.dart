import 'package:flutter/material.dart';
import 'package:mesh/services/notification_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/mesh_app_bar.dart';

class SettingsPage extends StatelessWidget {
  final Locale? initialLocale; // null → system default
  final void Function(Locale? locale) onChangedLocale;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;

  const SettingsPage({
    super.key,
    required this.initialLocale,
    required this.onChangedLocale,
    this.onToggleTheme,
    this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = <Locale?>[null, ...AppLocalizations.supportedLocales];

    return Scaffold(
      appBar: MeshAppBar(
        title: Text(t.appTitle),
        onToggleTheme: onToggleTheme,
        themeMode: themeMode,
        // Do not show settings button on the Settings page itself
        onOpenSettings: null,
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
                          label: Text(_localeLabel(context, loc)),
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
                    _localeDescription(context, initialLocale),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications),
                      const SizedBox(width: 8),
                      Text(
                        t.notifications,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      NotificationService.instance.requestPermissions();
                    },
                    child: Text(t.enableNotifications),
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
  return a.languageCode == b.languageCode &&
      (a.countryCode ?? '') == (b.countryCode ?? '');
}

String _localeLabel(BuildContext context, Locale? locale) {
  if (locale == null) return AppLocalizations.of(context).languageSystem;
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizations.of(context).languageEnglish;
    case 'pl':
      return AppLocalizations.of(context).languagePolish;
    default:
      return locale.toLanguageTag();
  }
}

String _localeDescription(BuildContext context, Locale? locale) {
  if (locale == null) {
    return AppLocalizations.of(context).languageFollowSystem;
  }
  return AppLocalizations.of(
    context,
  ).languageAppLanguage(_localeLabel(context, locale));
}
