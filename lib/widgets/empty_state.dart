import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 48,
            color: Colors.indigo.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).tapScanToDiscover),
        ],
      ),
    );
  }
}
