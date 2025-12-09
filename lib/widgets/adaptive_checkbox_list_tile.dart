import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AdaptiveCheckboxListTile extends StatelessWidget {
  final Widget title;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Widget? secondary;
  final Color? activeColor;
  final Color? checkColor;

  const AdaptiveCheckboxListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.secondary,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (_, __) => CheckboxListTile(
        title: title,
        value: value,
        onChanged: onChanged,
        secondary: secondary,
        activeColor: activeColor,
        checkColor: checkColor,
      ),
      cupertino: (_, __) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoListTile(
          title: title,
          leading: secondary,
          trailing: CupertinoSwitch(
            value: value ?? false,
            onChanged: onChanged != null ? (v) => onChanged!(v) : null,
            activeColor: activeColor ?? CupertinoTheme.of(context).primaryColor,
          ),
          onTap: onChanged != null ? () => onChanged!(!(value ?? false)) : null,
        ),
      ),
    );
  }
}
