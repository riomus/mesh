/// Device protocol types supported by the application
enum DeviceType {
  /// Meshtastic protocol device
  meshtastic,

  /// MeshCore protocol device
  meshcore,
}

extension DeviceTypeExtension on DeviceType {
  /// Display name for the device type
  String get displayName {
    switch (this) {
      case DeviceType.meshtastic:
        return 'Meshtastic';
      case DeviceType.meshcore:
        return 'MeshCore';
    }
  }

  /// Description of the protocol
  String get description {
    switch (this) {
      case DeviceType.meshtastic:
        return 'Meshtastic mesh protocol with protobuf messages';
      case DeviceType.meshcore:
        return 'MeshCore mesh protocol with binary packets';
    }
  }
}
