import 'package:flutter_libserialport/flutter_libserialport.dart';

/// Helper for serial port operations on native platforms
class SerialPortHelper {
  static List<String> get availablePorts => SerialPort.availablePorts;
}
