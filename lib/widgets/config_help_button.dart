import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../meshtastic/config_resources.dart';
import '../l10n/app_localizations.dart';

class ConfigHelpButton extends StatelessWidget {
  final ConfigDescription description;

  const ConfigHelpButton({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 20),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).configHelpTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description.description),
                const SizedBox(height: 16),
                InkWell(
                  child: Text(
                    AppLocalizations.of(context).readMoreDocumentation,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () async {
                    final uri = Uri.parse(description.link);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).close),
              ),
            ],
          ),
        );
      },
    );
  }
}
