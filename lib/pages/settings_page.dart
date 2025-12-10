import 'package:flutter/material.dart';
import 'package:mesh/services/notification_service.dart';
import 'package:mesh/services/settings_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/mesh_app_bar.dart';

class SettingsPage extends StatelessWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onChangedSettings;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;

  const SettingsPage({
    super.key,
    required this.settings,
    required this.onChangedSettings,
    this.onToggleTheme,
    this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = <Locale?>[null, ...AppLocalizations.supportedLocales];
    final initialLocale = settings.locale;
    final hasPassword =
        settings.adminPassword != null && settings.adminPassword!.isNotEmpty;

    return Scaffold(
      appBar: MeshAppBar(
        title: Text(t.appTitle),
        onToggleTheme: onToggleTheme,
        themeMode: themeMode,
        // Do not show settings button on the Settings page itself
        onOpenSettings: null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
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
                          const Icon(Icons.security),
                          const SizedBox(width: 8),
                          Text(
                            t.security,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!hasPassword)
                        ElevatedButton(
                          onPressed: () => _showSetPasswordDialog(context),
                          child: Text(t.protectApp),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.appProtected,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  _showRemovePasswordDialog(context),
                              child: Text(t.disableProtection),
                            ),
                          ],
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
                                onChangedSettings(
                                  settings.copyWith(locale: loc),
                                );
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bluetooth),
                          const SizedBox(width: 8),
                          Text(
                            t.bluetooth,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Divider(),
                      // BLE Heartbeat Interval
                      Text(
                        t.bleHeartbeatInterval,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.bleHeartbeatIntervalDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: settings.bleHeartbeatIntervalSeconds
                                  .toDouble()
                                  .clamp(10.0, 600.0),
                              min: 10,
                              max: 600,
                              divisions:
                                  118, // (600-10)/5 = 118 steps of 5 seconds
                              label: AppLocalizations.of(context).secondsSuffix(
                                settings.bleHeartbeatIntervalSeconds.toString(),
                              ),
                              onChanged: (value) {
                                onChangedSettings(
                                  settings.copyWith(
                                    bleHeartbeatIntervalSeconds: value.round(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              AppLocalizations.of(context).secondsSuffix(
                                settings.bleHeartbeatIntervalSeconds.toString(),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Auto Reconnection
                      Text(
                        t.autoReconnect,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.autoReconnectDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(t.autoReconnectEnabled),
                        value: settings.autoReconnectEnabled,
                        onChanged: (value) {
                          onChangedSettings(
                            settings.copyWith(autoReconnectEnabled: value),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Max Reconnect Attempts
                      Text(
                        t.maxReconnectAttempts,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.maxReconnectAttemptsDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: settings.maxReconnectAttempts
                                  .toDouble()
                                  .clamp(1.0, 10.0),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: settings.maxReconnectAttempts.toString(),
                              onChanged: (value) {
                                onChangedSettings(
                                  settings.copyWith(
                                    maxReconnectAttempts: value.round(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              settings.maxReconnectAttempts.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Reconnect Base Delay
                      Text(
                        t.reconnectBaseDelay,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.reconnectBaseDelayDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: settings.reconnectBaseDelaySeconds
                                  .toDouble()
                                  .clamp(1.0, 10.0),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: AppLocalizations.of(context).secondsSuffix(
                                settings.reconnectBaseDelaySeconds.toString(),
                              ),
                              onChanged: (value) {
                                onChangedSettings(
                                  settings.copyWith(
                                    reconnectBaseDelaySeconds: value.round(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              AppLocalizations.of(context).secondsSuffix(
                                settings.reconnectBaseDelaySeconds.toString(),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
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
                          const Icon(Icons.timer),
                          const SizedBox(width: 8),
                          Text(
                            t.configTimeout,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.configTimeoutDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: settings.configTimeoutSeconds
                                  .toDouble()
                                  .clamp(5.0, 600.0),
                              min: 5,
                              max: 600,
                              divisions:
                                  119, // (600-5)/5 = 119 steps of 5 seconds
                              label: AppLocalizations.of(context).secondsSuffix(
                                settings.configTimeoutSeconds.toString(),
                              ),
                              onChanged: (value) {
                                onChangedSettings(
                                  settings.copyWith(
                                    configTimeoutSeconds: value.round(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              AppLocalizations.of(context).secondsSuffix(
                                settings.configTimeoutSeconds.toString(),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSetPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.setPassword),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(labelText: t.password),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.save),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      onChangedSettings(settings.copyWith(adminPassword: controller.text));
    }
  }

  Future<void> _showRemovePasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.enterPassword),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(labelText: t.currentPassword),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (controller.text == settings.adminPassword) {
        onChangedSettings(settings.copyWith(adminPassword: ''));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.incorrectPassword)));
        }
      }
    }
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
