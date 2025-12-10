import 'dart:async';
import 'package:flutter/foundation.dart';

import 'dart:math';

import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../generated/meshtastic/meshtastic/admin.pb.dart' as admin;
import '../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../meshtastic/model/meshtastic_mappers.dart';
import '../meshtastic/model/device_type.dart';
import 'logging_service.dart';

/// Abstract base class for a Meshtastic client (BLE, IP, Serial, etc.).
abstract class MeshtasticClient {
  /// The protocol type of this client
  DeviceType get deviceType;

  /// Stream of high-level Meshtastic events.
  Stream<MeshtasticEvent> get events;

  /// Stream of RSSI updates (if applicable).
  Stream<int> get rssi;

  /// Connect to the device.
  Future<void> connect({Duration timeout});

  /// Disconnect from the device.
  Future<void> disconnect();

  /// Send a ToRadio protobuf message.
  Future<void> sendToRadio(mesh.ToRadio message);

  /// Send a MeshPacket (convenience wrapper around sendToRadio).
  Future<void> sendMeshPacket(mesh.MeshPacket packet);

  /// Request configuration from the device.
  Future<void> requestConfig();

  /// Request a session key (required for admin operations).
  Future<void> requestSessionKey(int? nodeId) async {
    debugPrint('[MeshtasticClient] Requesting session key for node $nodeId');
    final adminMsg = admin.AdminMessage(
      getConfigRequest: admin.AdminMessage_ConfigType.SESSIONKEY_CONFIG,
    );
    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );
    await sendToRadio(mesh.ToRadio(packet: packet));
    debugPrint('[MeshtasticClient] Session key request sent');
  }

  /// Begin a settings transaction (required before sending config updates).
  Future<void> beginEditSettings({
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    debugPrint(
      '[MeshtasticClient] Beginning edit settings transaction for node $nodeId',
    );
    final adminMsg = admin.AdminMessage(beginEditSettings: true);
    if (sessionPasskey != null) {
      adminMsg.sessionPasskey = sessionPasskey;
    }
    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Commit a settings transaction (required after sending config updates).
  Future<void> commitEditSettings({
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    debugPrint(
      '[MeshtasticClient] Committing edit settings transaction for node $nodeId',
    );
    final adminMsg = admin.AdminMessage(commitEditSettings: true);
    if (sessionPasskey != null) {
      adminMsg.sessionPasskey = sessionPasskey;
    }
    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Send a full device configuration update.
  Future<void> sendConfig(
    ConfigDto config, {
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    debugPrint(
      '[MeshtasticClient] Sending config to node $nodeId with passkey: ${sessionPasskey?.length ?? 0} bytes',
    );
    final cfg = MeshtasticMappers.toConfig(config);
    final adminMsg = admin.AdminMessage(setConfig: cfg);
    if (sessionPasskey != null) {
      adminMsg.sessionPasskey = sessionPasskey;
    }
    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Send a full module configuration update.
  Future<void> sendModuleConfig(
    ModuleConfigDto config, {
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    debugPrint(
      '[MeshtasticClient] Sending module config to node $nodeId with passkey: ${sessionPasskey?.length ?? 0} bytes',
    );
    final cfg = MeshtasticMappers.toModuleConfig(config);
    final adminMsg = admin.AdminMessage(setModuleConfig: cfg);
    if (sessionPasskey != null) {
      adminMsg.sessionPasskey = sessionPasskey;
    }
    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Send a channel configuration update.
  Future<void> sendChannelConfig(
    ChannelDto config, {
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    debugPrint(
      '[MeshtasticClient] Sending channel config to node $nodeId with passkey: ${sessionPasskey?.length ?? 0} bytes',
    );
    final cfg = MeshtasticMappers.toChannel(config);
    final adminMsg = admin.AdminMessage(setChannel: cfg);
    if (sessionPasskey != null) {
      adminMsg.sessionPasskey = sessionPasskey;
    }
    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Set device owner name (long name and/or short name).
  ///
  /// Arguments:
  ///   longName: Full name for the device user (e.g., "Kevin Hester")
  ///   shortName: Very short name, ideally 2 characters, max 4 (e.g., "KH")
  ///   isLicensed: Whether the user is a licensed ham radio operator
  ///   isUnmessagable: Whether the node can be messaged
  ///   sessionPasskey: Session key for authentication (required for remote nodes)
  ///   nodeId: Target node ID (null for local node)
  ///
  /// Throws ArgumentError if names are empty or whitespace-only.
  Future<void> setOwner({
    String? longName,
    String? shortName,
    bool? isLicensed,
    bool? isUnmessagable,
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    debugPrint('[MeshtasticClient] Setting owner for node $nodeId');

    final user = mesh.User();

    // Handle long name
    if (longName != null) {
      final trimmedLongName = longName.trim();
      if (trimmedLongName.isEmpty) {
        throw ArgumentError(
          'Long name cannot be empty or contain only whitespace characters',
        );
      }
      user.longName = trimmedLongName;
    }

    // Handle short name
    if (shortName != null) {
      var trimmedShortName = shortName.trim();
      if (trimmedShortName.isEmpty) {
        throw ArgumentError(
          'Short name cannot be empty or contain only whitespace characters',
        );
      }
      // Truncate to 4 characters maximum
      const int maxShortNameLength = 4;
      if (trimmedShortName.length > maxShortNameLength) {
        trimmedShortName = trimmedShortName.substring(0, maxShortNameLength);
        LoggingService.instance.push(
          level: 'info',
          message:
              'Short name truncated to $maxShortNameLength characters: $trimmedShortName',
        );
      }
      user.shortName = trimmedShortName;
    }

    // Handle optional flags
    if (isLicensed != null) {
      user.isLicensed = isLicensed;
    }
    if (isUnmessagable != null) {
      user.isUnmessagable = isUnmessagable;
    }

    // Create admin message with setOwner
    final adminMsg = admin.AdminMessage(setOwner: user);
    if (sessionPasskey != null) {
      adminMsg.sessionPasskey = sessionPasskey;
    }

    final payload = adminMsg.writeToBuffer();
    final data = mesh.Data(
      portnum: port.PortNum.ADMIN_APP,
      payload: payload,
      wantResponse: true,
    );
    final packet = mesh.MeshPacket(
      to: nodeId,
      decoded: data,
      pkiEncrypted: true,
      wantAck: true,
      id: _generatePacketId(),
      hopLimit: 3,
      channel: 0,
    );

    await sendToRadio(mesh.ToRadio(packet: packet));
    debugPrint('[MeshtasticClient] Owner update sent to node $nodeId');
  }

  /// Send a device UI configuration update.
  // Future<void> sendDeviceUiConfig(DeviceUiConfigDto config) async {
  //   final cfg = MeshtasticMappers.toDeviceUiConfig(config);
  //   final adminMsg = admin.AdminMessage(setDeviceUiConfig: cfg);
  //   final payload = adminMsg.writeToBuffer();
  //   final data = mesh.Data(portnum: port.PortNum.ADMIN_APP, payload: payload);
  //   final packet = mesh.MeshPacket(decoded: data);
  //   await sendToRadio(mesh.ToRadio(packet: packet));
  // }

  /// Dispose resources.
  Future<void> dispose();

  int _generatePacketId() {
    return Random().nextInt(0xFFFFFFFF);
  }
}
