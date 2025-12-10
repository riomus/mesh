class ConfigDescription {
  final String description;
  final String link;

  const ConfigDescription({required this.description, required this.link});
}

class ConfigResources {
  static const Map<String, ConfigDescription> descriptions = {
    // Device Config
    'device.role': ConfigDescription(
      description:
          'Sets the role of the node. Different roles have different power management and packet forwarding behaviors.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#roles',
    ),
    'security.adminChannelEnabled': ConfigDescription(
      description:
          'Allows incoming device control over the insecure legacy admin channel.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/security/#admin-channel-enabled',
    ),

    // MQTT Config
    'mqtt.enabled': ConfigDescription(
      description: 'Enables the MQTT module.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#enabled',
    ),
    'mqtt.address': ConfigDescription(
      description: 'MQTT Server address.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#server-address',
    ),
    'mqtt.username': ConfigDescription(
      description: 'MQTT Server username.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#username',
    ),
    'mqtt.password': ConfigDescription(
      description: 'MQTT Server password.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#password',
    ),
    'mqtt.encryptionEnabled': ConfigDescription(
      description: 'Send encrypted packets to MQTT server.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#encryption-enabled',
    ),
    'mqtt.jsonEnabled': ConfigDescription(
      description: 'Enable sending/consumption of JSON packets (not on nRF52).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#json-enabled',
    ),
    'mqtt.tlsEnabled': ConfigDescription(
      description: 'Use TLS for secure connection.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#tls-enabled',
    ),
    'mqtt.root': ConfigDescription(
      description: 'Root topic for MQTT messages.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#root-topic',
    ),
    'mqtt.proxyToClientEnabled': ConfigDescription(
      description: 'Use client\'s (phone) network connection.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#client-proxy-enabled',
    ),
    'mqtt.mapReportingEnabled': ConfigDescription(
      description: 'Periodically send unencrypted map report.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#map-reporting-enabled',
    ),
    'mqtt.mapReportPositionPrecision': ConfigDescription(
      description: 'Precision of position in map report.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#map-report-position-precision',
    ),
    'mqtt.mapReportPublishIntervalSecs': ConfigDescription(
      description: 'Interval for publishing map report.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/mqtt/#map-report-publish-interval',
    ),

    // Telemetry Config
    'telemetry.deviceUpdateInterval': ConfigDescription(
      description: 'How often to send Device Metrics over the mesh.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#device-metrics-update-interval',
    ),
    'telemetry.environmentUpdateInterval': ConfigDescription(
      description: 'How often to send Environment Metrics over the mesh.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#environment-metrics-update-interval',
    ),
    'telemetry.environmentMeasurementEnabled': ConfigDescription(
      description: 'Enable Environment Telemetry (Sensors).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#environment-telemetry-enabled',
    ),
    'telemetry.environmentScreenEnabled': ConfigDescription(
      description: 'Show environment telemetry data on the device display.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#environment-screen-enabled',
    ),
    'telemetry.environmentDisplayFahrenheit': ConfigDescription(
      description: 'Display temperature in Fahrenheit.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#display-fahrenheit',
    ),
    'telemetry.airQualityEnabled': ConfigDescription(
      description: 'Enable sending of air quality metrics.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#air-quality-enabled',
    ),
    'telemetry.airQualityInterval': ConfigDescription(
      description: 'Interval for sending air quality metrics.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#air-quality-interval',
    ),
    'telemetry.powerMeasurementEnabled': ConfigDescription(
      description: 'Enable sending of power telemetry.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#power-metrics-enabled',
    ),
    'telemetry.powerUpdateInterval': ConfigDescription(
      description: 'Interval for sending power metrics.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#power-metrics-interval',
    ),
    'telemetry.powerScreenEnabled': ConfigDescription(
      description: 'Show power telemetry data on the device display.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/',
    ),
    'telemetry.healthMeasurementEnabled': ConfigDescription(
      description: 'Enable sending of health data.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#health-telemetry-enabled',
    ),
    'telemetry.healthUpdateInterval': ConfigDescription(
      description: 'Interval for sending health data.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/#health-telemetry-interval',
    ),
    'telemetry.healthScreenEnabled': ConfigDescription(
      description: 'Show health telemetry data on the device display.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/',
    ),
    'telemetry.deviceTelemetryEnabled': ConfigDescription(
      description: 'Enable sending of device telemetry.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/module/telemetry/',
    ),

    // Serial Config
    'serial.enabled': ConfigDescription(
      description: 'Enables the serial module.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#enabled',
    ),
    'serial.echo': ConfigDescription(
      description: 'Echo packets back to the device.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#echo',
    ),
    'serial.rxd': ConfigDescription(
      description: 'RXD GPIO Pin.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#receive-gpio-pin',
    ),
    'serial.txd': ConfigDescription(
      description: 'TXD GPIO Pin.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#transmit-gpio-pin',
    ),
    'serial.baud': ConfigDescription(
      description: 'Serial baud rate.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#baud-rate',
    ),
    'serial.timeout': ConfigDescription(
      description: 'Packet timeout.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#timeout',
    ),
    'serial.mode': ConfigDescription(
      description: 'Serial module operation mode.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#mode',
    ),
    'serial.overrideConsoleSerialPort': ConfigDescription(
      description: 'Use primary USB serial bus for output.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/module/serial/#override-console-serial-port',
    ),
    'device.serialEnabled': ConfigDescription(
      description: 'Deprecated upstream. Use Serial Module instead.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/device/',
    ),
    'device.buttonGpio': ConfigDescription(
      description: 'GPIO pin number for the user button.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#gpio-for-user-button',
    ),
    'device.buzzerGpio': ConfigDescription(
      description: 'GPIO pin number for the PWM buzzer.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#gpio-for-pwm-buzzer',
    ),
    'device.rebroadcastMode': ConfigDescription(
      description:
          'Defines the device behavior for how messages are rebroadcasted.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#rebroadcast-mode',
    ),
    'device.nodeInfoBroadcastSecs': ConfigDescription(
      description: 'Seconds between NodeInfo message broadcasts.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#node-info-broadcast-seconds',
    ),
    'device.doubleTapAsButtonPress': ConfigDescription(
      description:
          'Enable double tap on supported accelerometer to be treated as a button press.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#double-tap-as-button-press',
    ),
    'device.isManaged': ConfigDescription(
      description:
          'If true, this device is managed by a central administrator.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/device/',
    ),
    'device.disableTripleClick': ConfigDescription(
      description:
          'Disables the triple-press of user button to enable or disable GPS.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#disable-triple-click',
    ),
    'device.tzdef': ConfigDescription(
      description: 'Timezone definition using POSIX TZ Database string.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#tzdef-timezone-definition',
    ),
    'device.ledHeartbeatDisabled': ConfigDescription(
      description: 'If true, disable the default blinking LED behavior.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/device/#led-heartbeat-disabled',
    ),
    'device.buzzerMode': ConfigDescription(
      description: 'Controls the buzzer behavior.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/device/',
    ),

    // Position Config
    'position.gpsMode': ConfigDescription(
      description:
          'Configures whether the GPS functionality is enabled, disabled, or not present.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#gps-mode',
    ),
    'position.gpsUpdateInterval': ConfigDescription(
      description: 'How often to try to get GPS position (in seconds).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#gps-update-interval',
    ),
    'position.fixedPosition': ConfigDescription(
      description: 'If set, this node is at a fixed position.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#fixed-position',
    ),
    'position.positionBroadcastSmartEnabled': ConfigDescription(
      description:
          'Send position at increased frequency only if location has changed.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#smart-broadcast',
    ),
    'position.broadcastSmartMinimumDistance': ConfigDescription(
      description:
          'Minimum distance in meters traveled before sending a position update.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#smart-broadcast-minimum-distance',
    ),
    'position.broadcastSmartMinimumIntervalSecs': ConfigDescription(
      description:
          'Minimum seconds before sending a position update if smart broadcast is enabled.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#smart-broadcast-minimum-interval',
    ),
    'position.positionBroadcastSecs': ConfigDescription(
      description: 'How often to send position if smart broadcast is off.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#broadcast-interval',
    ),
    'position.positionFlags': ConfigDescription(
      description: 'Defines which options are sent in POSITION messages.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#position-flags',
    ),
    'position.rxGpio': ConfigDescription(
      description: 'GPIO RX pin for GPS module.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#gpio-rxtxen-for-gps-module',
    ),
    'position.txGpio': ConfigDescription(
      description: 'GPIO TX pin for GPS module.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#gpio-rxtxen-for-gps-module',
    ),
    'position.gpsEnGpio': ConfigDescription(
      description: 'GPIO Enable pin for GPS module.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/position/#gpio-rxtxen-for-gps-module',
    ),

    // Power Config
    'power.isPowerSaving': ConfigDescription(
      description:
          'If enabled, disables Bluetooth, Serial, WiFi, and screen to conserve power.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#power-saving',
    ),
    'power.onBatteryShutdownAfterSecs': ConfigDescription(
      description:
          'Automatically shut down device after defined seconds if power is lost.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#shutdown-after-losing-power',
    ),
    'power.adcMultiplierOverride': ConfigDescription(
      description:
          'Ratio of voltage divider for battery pin. Overrides firmware default.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#adc-multiplier-override',
    ),
    'power.waitBluetoothSecs': ConfigDescription(
      description:
          'How long to wait before turning off BLE in no Bluetooth states.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#wait-bluetooth-interval',
    ),
    'power.sdsSecs': ConfigDescription(
      description: 'Deep sleep interval in seconds.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/power/',
    ),
    'power.lsSecs': ConfigDescription(
      description: 'Light sleep interval in seconds (ESP32 only).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#light-sleep-interval',
    ),
    'power.minWakeSecs': ConfigDescription(
      description:
          'Minimum wake interval when receiving packets in light sleep.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#minimum-wake-interval',
    ),
    'power.deviceBatteryInaAddress': ConfigDescription(
      description: 'I2C address for INA2xx battery monitor.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/power/#device-battery-ina2xx-address',
    ),
    'power.powermonEnables': ConfigDescription(
      description: 'Power monitor enable flags.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/power/',
    ),

    // Network Config
    'network.wifiEnabled': ConfigDescription(
      description: 'Enables or Disables WiFi.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#wifi-enabled',
    ),
    'network.wifiSsid': ConfigDescription(
      description: 'WiFi Network SSID.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#wifi-ssid',
    ),
    'network.wifiPsk': ConfigDescription(
      description: 'WiFi Network Password.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#wifi-psk',
    ),
    'network.ntpServer': ConfigDescription(
      description: 'NTP server used if IP networking is available.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#ntp-server',
    ),
    'network.ethEnabled': ConfigDescription(
      description: 'Enables or Disables Ethernet.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#ethernet-enabled',
    ),
    'network.addressMode': ConfigDescription(
      description: 'IPv4 Networking Mode (DHCP or STATIC).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#ipv4-networking-mode',
    ),
    'network.rsyslogServer': ConfigDescription(
      description: 'Rsyslog Server address.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/network/#rsyslog-server',
    ),
    'network.ipv6Enabled': ConfigDescription(
      description: 'Enables or Disables IPv6.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/network/',
    ),

    // Display Config
    'display.screenOnSecs': ConfigDescription(
      description:
          'How long the screen remains on after user interaction or message reception.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#screen-on-duration',
    ),
    'display.autoScreenCarouselSecs': ConfigDescription(
      description: 'Interval for automatically toggling to the next page.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#auto-carousel-interval',
    ),
    'display.compassNorthTop': ConfigDescription(
      description:
          'If set, the compass heading on the screen will always point north.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#always-point-north',
    ),
    'display.flipScreen': ConfigDescription(
      description: 'If enabled, the screen will be rotated 180 degrees.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#flip-screen',
    ),
    'display.units': ConfigDescription(
      description: 'Preferred display units (METRIC or IMPERIAL).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#preferred-display-units',
    ),
    'display.oled': ConfigDescription(
      description: 'OLED Controller type.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#oled-definition',
    ),
    'display.displaymode': ConfigDescription(
      description: 'Display mode (DEFAULT, TWOCOLOR, INVERTED, COLOR).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#display-mode',
    ),
    'display.headingBold': ConfigDescription(
      description: 'Makes the heading bold for better readability.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#heading-bold',
    ),
    'display.wakeOnTapOrMotion': ConfigDescription(
      description: 'Wake the screen on tap or motion.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#wake-on-tap-or-motion',
    ),
    'display.compassOrientation': ConfigDescription(
      description: 'Rotate or invert the compass orientation.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#compass-orientation',
    ),
    'display.use12hClock': ConfigDescription(
      description: 'Display time in 12-hour format.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/display/#use-12-hour-clock',
    ),
    'display.useLongNodeName': ConfigDescription(
      description: 'Use long node name on the display.',
      link: 'https://meshtastic.org/pl-PL/docs/configuration/radio/display/',
    ),

    // LoRa Config
    'lora.usePreset': ConfigDescription(
      description: 'If enabled, Modem Preset fields will be adhered to.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#use-preset',
    ),
    'lora.modemPreset': ConfigDescription(
      description: 'Pre-defined modem settings for speed and range.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#modem-preset',
    ),
    'lora.bandwidth': ConfigDescription(
      description: 'LoRa bandwidth.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#bandwidth',
    ),
    'lora.spreadFactor': ConfigDescription(
      description: 'LoRa spread factor.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#spread-factor',
    ),
    'lora.codingRate': ConfigDescription(
      description: 'LoRa coding rate denominator.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#coding-rate',
    ),
    'lora.frequencyOffset': ConfigDescription(
      description: 'Frequency offset for crystal calibration errors.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#frequency-offset',
    ),
    'lora.region': ConfigDescription(
      description: 'Sets the region for your node.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#region',
    ),
    'lora.hopLimit': ConfigDescription(
      description: 'Maximum number of hops.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#max-hops',
    ),
    'lora.txEnabled': ConfigDescription(
      description: 'Enable or disable transmit (TX) from the LoRa radio.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#transmit-enabled',
    ),
    'lora.txPower': ConfigDescription(
      description: 'Transmit power in dBm (0 for default max legal power).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#transmit-power',
    ),
    'lora.channelNum': ConfigDescription(
      description: 'Frequency slot for transmission.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#frequency-slot',
    ),
    'lora.overrideDutyCycle': ConfigDescription(
      description: 'Ignore hourly duty cycle limit (may violate regulations).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#override-duty-cycle-limit',
    ),
    'lora.sx126xRxBoostedGain': ConfigDescription(
      description:
          'Increase RX sensitivity for SX126x chips (consumes more power).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#sx126x-rx-boosted-gain',
    ),
    'lora.overrideFrequency': ConfigDescription(
      description:
          'Override channel calculation with set frequency (advanced/HAM only).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#override-frequency',
    ),
    'lora.paFanDisabled': ConfigDescription(
      description: 'Disable built-in PA FAN.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#pa-fan-disabled',
    ),
    'lora.ignoreMqtt': ConfigDescription(
      description: 'Ignore messages received via LoRa that came via MQTT.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#ignore-mqtt',
    ),
    'lora.configOkToMqtt': ConfigDescription(
      description: 'Approve packets to be uplinked to MQTT brokers.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/lora/#ok-to-mqtt',
    ),

    // Bluetooth Config
    'bluetooth.enabled': ConfigDescription(
      description: 'Enables Bluetooth.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/bluetooth/#enabled',
    ),
    'bluetooth.mode': ConfigDescription(
      description: 'Pairing mode (RANDOM_PIN, FIXED_PIN, NO_PIN).',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/bluetooth/#pairing-mode',
    ),
    'bluetooth.fixedPin': ConfigDescription(
      description: '6-digit PIN for FIXED_PIN pairing mode.',
      link:
          'https://meshtastic.org/pl-PL/docs/configuration/radio/bluetooth/#fixed-pin',
    ),
  };

  static ConfigDescription? getDescription(String key) {
    return descriptions[key];
  }
}
