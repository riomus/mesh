import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AdaptiveChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;

  const AdaptiveChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
    this.onSelected,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) {
        Widget chip;
        if (onSelected != null) {
          chip = FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: onSelected,
          );
        } else if (onPressed != null) {
          chip = ActionChip(
            label: Text(label),
            avatar: avatar,
            onPressed: onPressed,
          );
        } else if (onDeleted != null) {
          chip = InputChip(
            label: Text(label),
            avatar: avatar,
            onDeleted: onDeleted,
          );
        } else {
          chip = Chip(label: Text(label), avatar: avatar);
        }
        return Material(type: MaterialType.transparency, child: chip);
      },
      cupertino: (context, platform) => _buildCupertinoChip(context),
    );
  }

  Widget _buildCupertinoChip(BuildContext context) {
    final isSelected = selected;
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final backgroundColor = isSelected
        ? primaryColor
        : CupertinoColors.systemFill.resolveFrom(context);
    final textColor = isSelected
        ? CupertinoColors.white
        : CupertinoColors.label.resolveFrom(context);

    return GestureDetector(
      onTap: () {
        if (onSelected != null) {
          onSelected!(!selected);
        } else if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[avatar!, const SizedBox(width: 4)],
            Text(label, style: TextStyle(color: textColor, fontSize: 14)),
            if (onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 16,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
