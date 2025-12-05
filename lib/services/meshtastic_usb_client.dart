// Conditional export based on platform
// On web, use stub implementation; on native platforms, use real implementation
export 'meshtastic_usb_client_stub.dart'
    if (dart.library.io) 'meshtastic_usb_client_io.dart';
