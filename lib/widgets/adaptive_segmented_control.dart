import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  final T groupValue;
  final Map<T, Widget> children;
  final ValueChanged<T> onValueChanged;

  const AdaptiveSegmentedControl({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) => SegmentedButton<T>(
        segments: children.entries
            .map((e) => ButtonSegment<T>(value: e.key, label: e.value))
            .toList(),
        selected: {groupValue},
        onSelectionChanged: (s) => onValueChanged(s.first),
      ),
      cupertino: (context, platform) => CupertinoSlidingSegmentedControl<T>(
        groupValue: groupValue,
        children: children,
        onValueChanged: (v) {
          if (v != null) onValueChanged(v);
        },
      ),
    );
  }
}
