import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../meshtastic/model/device_type.dart';

/// Helper class for device type UI elements
class DeviceTypeHelper {
  DeviceTypeHelper._();

  /// Get icon for device type
  static IconData getIcon(DeviceType type) {
    switch (type) {
      case DeviceType.meshtastic:
        return Icons.router; // Radio/mesh icon for Meshtastic
      case DeviceType.meshcore:
        return Icons.hub; // Hub/network icon for MeshCore
    }
  }

  /// Get Cupertino icon for device type
  static IconData getCupertinoIcon(DeviceType type) {
    switch (type) {
      case DeviceType.meshtastic:
        return CupertinoIcons.antenna_radiowaves_left_right;
      case DeviceType.meshcore:
        return CupertinoIcons.circle_grid_hex;
    }
  }

  /// Get color for device type
  static Color getColor(DeviceType type) {
    switch (type) {
      case DeviceType.meshtastic:
        return const Color(0xFF67C23A); // Green for Meshtastic
      case DeviceType.meshcore:
        return const Color(0xFF409EFF); // Blue for MeshCore
    }
  }

  /// Build a device type badge widget
  static Widget buildBadge(
    DeviceType type, {
    double size = 20,
    bool showLabel = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(getIcon(type), size: size, color: getColor(type)),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: TextStyle(
              fontSize: size * 0.7,
              color: getColor(type),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
