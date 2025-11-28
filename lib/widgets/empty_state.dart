import 'package:flutter/material.dart';

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
            color: Colors.indigo.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          const Text('Tap Scan to discover nearby Bluetooth devices'),
        ],
      ),
    );
  }
}
