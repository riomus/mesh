import 'package:flutter/material.dart';

class RssiBar extends StatelessWidget {
  final int rssi; // typically [-100..-20]
  const RssiBar({super.key, required this.rssi});

  // Visualization constants
  static const int _totalBars = 5; // N total bars
  static const int _minRssi = -100; // worst
  static const int _maxRssi = -50; // excellent

  // Map RSSI [-100..-50] -> [0..1]
  double get _strengthFraction {
    final clamped = rssi.clamp(_minRssi, _maxRssi);
    return (clamped - _minRssi) / (_maxRssi - _minRssi);
  }

  int get _filledBars {
    // Round to nearest, ensure within [0.._totalBars]
    final k = (_strengthFraction * _totalBars).round();
    return k.clamp(0, _totalBars);
  }

  Color _colorFor(BuildContext context) {
    // Thresholds chosen to align with common BLE expectations
    if (rssi <= -80) return Colors.red; // weak
    if (rssi <= -65) return Colors.amber; // medium
    return Colors.green; // strong
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _colorFor(context);
    final inactiveColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.15);

    // Heights for bars from left (shortest) to right (tallest)
    const heights = [8.0, 12.0, 16.0, 20.0, 24.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _totalBars; i++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Container(
              width: 4,
              height: heights[i],
              decoration: BoxDecoration(
                color: (i < _filledBars) ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text('$rssi dBm', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
