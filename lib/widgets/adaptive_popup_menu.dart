import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../l10n/app_localizations.dart';

class AdaptivePopupMenu<T> extends StatelessWidget {
  final Widget icon;
  final List<PopupMenuEntry<T>> itemBuilder;
  final ValueChanged<T> onSelected;
  final String? tooltip;

  const AdaptivePopupMenu({
    super.key,
    required this.icon,
    required this.itemBuilder,
    required this.onSelected,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (_, __) => PopupMenuButton<T>(
        icon: icon,
        tooltip: tooltip,
        itemBuilder: (context) => itemBuilder,
        onSelected: onSelected,
      ),
      cupertino: (_, __) => _buildCupertinoActionSheet(context),
    );
  }

  Widget _buildCupertinoActionSheet(BuildContext context) {
    return PlatformIconButton(
      icon: icon,
      onPressed: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: itemBuilder
                .whereType<PopupMenuItem<T>>()
                .map(
                  (item) => CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      if (item.value != null) {
                        onSelected(item.value!);
                      }
                    },
                    child: item.child ?? const SizedBox.shrink(),
                  ),
                )
                .toList(),
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ),
        );
      },
    );
  }
}
