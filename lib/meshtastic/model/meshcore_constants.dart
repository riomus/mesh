/// MeshCore Bluetooth protocol constants
/// Based on MeshCore SerialBLEInterface implementation
class MeshCoreConstants {
  MeshCoreConstants._();

  // BLE Service UUIDs (Nordic UART Service)
  static const String serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String rxCharacteristicUuid =
      '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String txCharacteristicUuid =
      '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  // Protocol limits
  static const int maxFrameSize = 512; // matches MAX_FRAME_SIZE
  static const int maxPathSize = 64;
  static const int maxPacketPayload = 184;
  static const int frameQueueSize = 4;

  // Timing
  static const int bleWriteMinIntervalMs = 60;
  static const int advertRestartDelayMs = 1000;

  // Header bit masks
  static const int routeTypeMask = 0x03; // bits 0-1
  static const int payloadTypeMask = 0x3C; // bits 2-5
  static const int payloadVersionMask = 0xC0; // bits 6-7

  // Route types
  static const int routeTypeTransportFlood = 0x00;
  static const int routeTypeFlood = 0x01;
  static const int routeTypeDirect = 0x02;
  static const int routeTypeTransportDirect = 0x03;

  // Payload types
  static const int payloadTypeReq = 0x00;
  static const int payloadTypeResponse = 0x01;
  static const int payloadTypeTxtMsg = 0x02;
  static const int payloadTypeAck = 0x03;
  static const int payloadTypeAdvert = 0x04;
  static const int payloadTypeGrpTxt = 0x05;
  static const int payloadTypeGrpData = 0x06;
  static const int payloadTypeAnonReq = 0x07;
  static const int payloadTypePath = 0x08;
  static const int payloadTypeTrace = 0x09;
  static const int payloadTypeMultipart = 0x0A;
  static const int payloadTypeControl = 0x0B;
  static const int payloadTypeRawCustom = 0x0F;

  // Payload versions
  static const int payloadVersion1 = 0x00; // 1-byte hashes, 2-byte MAC
  static const int payloadVersion2 = 0x01; // Future: 2-byte hashes, 4-byte MAC
  static const int payloadVersion3 = 0x02; // Future
  static const int payloadVersion4 = 0x03; // Future

  // Text message types (upper 6 bits of txt_type field)
  static const int txtTypePlain = 0x00;
  static const int txtTypeCli = 0x01;
  static const int txtTypeSigned = 0x02;

  // Control packet sub-types (upper 4 bits of flags)
  static const int controlSubtypeDiscoverReq = 0x08;
  static const int controlSubtypeDiscoverResp = 0x09;

  // Companion Radio Protocol Commands
  static const int cmdAppStart = 0x01;
  static const int cmdSetRadioParams = 0x0B; // 11
  static const int cmdSetRadioTxPower = 0x0C; // 12
  static const int cmdSetAdvertName = 0x08;
  static const int cmdDeviceQuery = 0x16; // 22
  static const int cmdGetChannel = 0x1F; // 31
  static const int cmdSetChannel = 0x20; // 32

  // Channel limits
  static const int maxChannels = 8; // Default max channels
  static const int channelNameLength = 32;
  static const int channelPskLength = 16; // 128-bit PSK

  // Companion Radio Protocol Responses
  static const int respCodeOk = 0x00;
  static const int respCodeErr = 0x01;
  static const int respCodeContactsStart = 0x02;
  static const int respCodeContact = 0x03;
  static const int respCodeEndOfContacts = 0x04;
  static const int respSelfInfo = 0x05;
  static const int respCodeSent = 0x06;
  static const int respCodeContactMsgRecv = 0x07;
  static const int respCodeChannelMsgRecv = 0x08;
  static const int respCodeCurrTime = 0x09;
  static const int respCodeNoMoreMessages = 0x0A;
  static const int respCodeExportContact = 0x0B;
  static const int respCodeBattAndStorage = 0x0C;
  static const int respDeviceInfo = 0x0D; // 13
  static const int respCodePrivateKey = 0x0E;
  static const int respCodeDisabled = 0x0F;
  static const int respCodeContactMsgRecvV3 = 0x10;
  static const int respCodeChannelMsgRecvV3 = 0x11;
  static const int respCodeChannelInfo = 0x12;
  static const int respCodeSignStart = 0x13;
  static const int respCodeSignature = 0x14;
  static const int respCodeCustomVars = 0x15;
  static const int respCodeAdvertPath = 0x16;
  static const int respCodeTuningParams = 0x17;
  static const int respCodeStats = 0x18;

  /// Get a human-readable description for a response code
  static String getResponseCodeDescription(int code) {
    switch (code) {
      case respCodeOk:
        return 'OK';
      case respCodeErr:
        return 'Error';
      case respCodeContactsStart:
        return 'Contacts Start';
      case respCodeContact:
        return 'Contact';
      case respCodeEndOfContacts:
        return 'End of Contacts';
      case respSelfInfo:
        return 'Self Info';
      case respCodeSent:
        return 'Sent';
      case respCodeContactMsgRecv:
        return 'Contact Message Received';
      case respCodeChannelMsgRecv:
        return 'Channel Message Received';
      case respCodeCurrTime:
        return 'Current Time';
      case respCodeNoMoreMessages:
        return 'No More Messages';
      case respCodeExportContact:
        return 'Export Contact';
      case respCodeBattAndStorage:
        return 'Battery and Storage';
      case respDeviceInfo:
        return 'Device Info';
      case respCodePrivateKey:
        return 'Private Key';
      case respCodeDisabled:
        return 'Disabled';
      case respCodeContactMsgRecvV3:
        return 'Contact Message Received V3';
      case respCodeChannelMsgRecvV3:
        return 'Channel Message Received V3';
      case respCodeChannelInfo:
        return 'Channel Info';
      case respCodeSignStart:
        return 'Sign Start';
      case respCodeSignature:
        return 'Signature';
      case respCodeCustomVars:
        return 'Custom Variables';
      case respCodeAdvertPath:
        return 'Advert Path';
      case respCodeTuningParams:
        return 'Tuning Parameters';
      case respCodeStats:
        return 'Statistics';
      default:
        return 'Unknown Response (0x${code.toRadixString(16)})';
    }
  }
}
