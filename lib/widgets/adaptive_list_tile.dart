import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AdaptiveListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;
  final Color? tileColor;

  const AdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        dense: dense,
        tileColor: tileColor,
      ),
      cupertino: (context, platform) => Material(
        // CupertinoListTile doesn't support tileColor directly in the same way,
        // so we wrap in Material to allow some flexibility or use Container.
        // However, standard CupertinoListTile is preferred for look.
        color: tileColor ?? Colors.transparent,
        child: CupertinoListTile(
          leading: leading,
          title: title ?? const SizedBox.shrink(),
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}
