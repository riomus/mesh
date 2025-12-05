import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mesh BLE Scanner'**
  String get appTitle;

  /// No description provided for @nearbyDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Bluetooth Devices'**
  String get nearbyDevicesTitle;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleThemeTooltip;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageTooltip;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @identifier.
  ///
  /// In en, this message translates to:
  /// **'Identifier'**
  String get identifier;

  /// No description provided for @platformName.
  ///
  /// In en, this message translates to:
  /// **'Platform name'**
  String get platformName;

  /// No description provided for @signalRssi.
  ///
  /// In en, this message translates to:
  /// **'Signal (RSSI)'**
  String get signalRssi;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;

  /// No description provided for @advertisedName.
  ///
  /// In en, this message translates to:
  /// **'Advertised name'**
  String get advertisedName;

  /// No description provided for @connectable.
  ///
  /// In en, this message translates to:
  /// **'Connectable'**
  String get connectable;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @serviceUuids.
  ///
  /// In en, this message translates to:
  /// **'Service UUIDs'**
  String get serviceUuids;

  /// No description provided for @serviceUuidsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Service UUIDs ({count})'**
  String serviceUuidsWithCount(Object count);

  /// No description provided for @manufacturerData.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Data'**
  String get manufacturerData;

  /// No description provided for @manufacturerDataWithCount.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Data ({count})'**
  String manufacturerDataWithCount(Object count);

  /// No description provided for @serviceData.
  ///
  /// In en, this message translates to:
  /// **'Service Data'**
  String get serviceData;

  /// No description provided for @serviceDataWithCount.
  ///
  /// In en, this message translates to:
  /// **'Service Data ({count})'**
  String serviceDataWithCount(Object count);

  /// No description provided for @noneAdvertised.
  ///
  /// In en, this message translates to:
  /// **'None advertised'**
  String get noneAdvertised;

  /// No description provided for @bluetoothOn.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is ON'**
  String get bluetoothOn;

  /// No description provided for @bluetoothOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is OFF'**
  String get bluetoothOff;

  /// No description provided for @bluetoothState.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth state: {state}'**
  String bluetoothState(Object state);

  /// No description provided for @webNote.
  ///
  /// In en, this message translates to:
  /// **'On Web, scanning shows a chooser after tapping Scan (HTTPS required).'**
  String get webNote;

  /// No description provided for @tapScanToDiscover.
  ///
  /// In en, this message translates to:
  /// **'Tap Scan to discover nearby Bluetooth devices'**
  String get tapScanToDiscover;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknown;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search devices by name or ID'**
  String get searchHint;

  /// No description provided for @loraOnlyFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'LoRa only'**
  String get loraOnlyFilterLabel;

  /// No description provided for @meshtasticLabel.
  ///
  /// In en, this message translates to:
  /// **'Meshtastic'**
  String get meshtasticLabel;

  /// No description provided for @settingsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButtonLabel;

  /// No description provided for @nodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nodes'**
  String get nodesTitle;

  /// No description provided for @tabList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get tabList;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @liveEvents.
  ///
  /// In en, this message translates to:
  /// **'Live events'**
  String get liveEvents;

  /// No description provided for @serviceAvailable.
  ///
  /// In en, this message translates to:
  /// **'Service available'**
  String get serviceAvailable;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get statusConnecting;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnected;

  /// No description provided for @mapRefPrefix.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get mapRefPrefix;

  /// No description provided for @clearRef.
  ///
  /// In en, this message translates to:
  /// **'Clear ref'**
  String get clearRef;

  /// No description provided for @fitBounds.
  ///
  /// In en, this message translates to:
  /// **'Fit bounds'**
  String get fitBounds;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @useAsRef.
  ///
  /// In en, this message translates to:
  /// **'Use as ref'**
  String get useAsRef;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @copyCoords.
  ///
  /// In en, this message translates to:
  /// **'Copy coords'**
  String get copyCoords;

  /// No description provided for @coordsCopied.
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied'**
  String get coordsCopied;

  /// No description provided for @noNodesWithLocation.
  ///
  /// In en, this message translates to:
  /// **'No nodes with location yet.\nLong‑press on the map to set a custom distance reference.'**
  String get noNodesWithLocation;

  /// No description provided for @customRefSet.
  ///
  /// In en, this message translates to:
  /// **'Custom distance reference set to {lat}, {lon}'**
  String customRefSet(Object lat, Object lon);

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @searchNodes.
  ///
  /// In en, this message translates to:
  /// **'Search nodes'**
  String get searchNodes;

  /// No description provided for @findByNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Find by name or id ...'**
  String get findByNameOrId;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @addFilter.
  ///
  /// In en, this message translates to:
  /// **'Add filter'**
  String get addFilter;

  /// No description provided for @sorting.
  ///
  /// In en, this message translates to:
  /// **'Sorting'**
  String get sorting;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @favoritesFirst.
  ///
  /// In en, this message translates to:
  /// **'Favorites first'**
  String get favoritesFirst;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @snr.
  ///
  /// In en, this message translates to:
  /// **'SNR'**
  String get snr;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @hops.
  ///
  /// In en, this message translates to:
  /// **'hops'**
  String get hops;

  /// No description provided for @via.
  ///
  /// In en, this message translates to:
  /// **'via'**
  String get via;

  /// No description provided for @addFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Add filter'**
  String get addFilterTitle;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get key;

  /// No description provided for @exact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get exact;

  /// No description provided for @regex.
  ///
  /// In en, this message translates to:
  /// **'Regex'**
  String get regex;

  /// No description provided for @hasValueFor.
  ///
  /// In en, this message translates to:
  /// **'has {key}'**
  String hasValueFor(Object key);

  /// No description provided for @customValueOptional.
  ///
  /// In en, this message translates to:
  /// **'Custom value (optional)'**
  String get customValueOptional;

  /// No description provided for @regexCaseInsensitive.
  ///
  /// In en, this message translates to:
  /// **'Regex (case-insensitive)'**
  String get regexCaseInsensitive;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @useSourceAsRef.
  ///
  /// In en, this message translates to:
  /// **'Use source device as distance ref'**
  String get useSourceAsRef;

  /// No description provided for @tipSetCustomRef.
  ///
  /// In en, this message translates to:
  /// **'Tip: set a custom reference by long‑pressing on the Map tab'**
  String get tipSetCustomRef;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Search events'**
  String get searchEvents;

  /// No description provided for @searchInSummaryOrTags.
  ///
  /// In en, this message translates to:
  /// **'Search in summary or tags'**
  String get searchInSummaryOrTags;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @charging.
  ///
  /// In en, this message translates to:
  /// **'charging'**
  String get charging;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location is not available for this node'**
  String get locationUnavailable;

  /// No description provided for @sourceDevice.
  ///
  /// In en, this message translates to:
  /// **'Source device'**
  String get sourceDevice;

  /// No description provided for @viaMqtt.
  ///
  /// In en, this message translates to:
  /// **'via MQTT'**
  String get viaMqtt;

  /// No description provided for @connectFailed.
  ///
  /// In en, this message translates to:
  /// **'Connect failed'**
  String get connectFailed;

  /// No description provided for @meshtasticConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Meshtastic connect failed'**
  String get meshtasticConnectFailed;

  /// No description provided for @deviceError.
  ///
  /// In en, this message translates to:
  /// **'Device error'**
  String get deviceError;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTitle;

  /// No description provided for @failedToShareEvents.
  ///
  /// In en, this message translates to:
  /// **'Failed to share events: {error}'**
  String failedToShareEvents(Object error);

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @eventDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Event details'**
  String get eventDetailsTitle;

  /// No description provided for @timestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get timestamp;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @payload.
  ///
  /// In en, this message translates to:
  /// **'Payload'**
  String get payload;

  /// No description provided for @waypoint.
  ///
  /// In en, this message translates to:
  /// **'Waypoint'**
  String get waypoint;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @routing.
  ///
  /// In en, this message translates to:
  /// **'Routing'**
  String get routing;

  /// No description provided for @routingPayload.
  ///
  /// In en, this message translates to:
  /// **'Routing payload'**
  String get routingPayload;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @remoteHardware.
  ///
  /// In en, this message translates to:
  /// **'Remote hardware'**
  String get remoteHardware;

  /// No description provided for @neighborInfo.
  ///
  /// In en, this message translates to:
  /// **'Neighbor info'**
  String get neighborInfo;

  /// No description provided for @neighbors.
  ///
  /// In en, this message translates to:
  /// **'Neighbors'**
  String get neighbors;

  /// No description provided for @storeForward.
  ///
  /// In en, this message translates to:
  /// **'Store & Forward'**
  String get storeForward;

  /// No description provided for @telemetry.
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get telemetry;

  /// No description provided for @paxcounter.
  ///
  /// In en, this message translates to:
  /// **'Paxcounter'**
  String get paxcounter;

  /// No description provided for @traceroute.
  ///
  /// In en, this message translates to:
  /// **'Traceroute'**
  String get traceroute;

  /// No description provided for @keyVerification.
  ///
  /// In en, this message translates to:
  /// **'Key verification'**
  String get keyVerification;

  /// No description provided for @rawPayload.
  ///
  /// In en, this message translates to:
  /// **'Raw payload'**
  String get rawPayload;

  /// No description provided for @fullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @shareEvents.
  ///
  /// In en, this message translates to:
  /// **'Share events (JSON)'**
  String get shareEvents;

  /// No description provided for @eventsExport.
  ///
  /// In en, this message translates to:
  /// **'Events export'**
  String get eventsExport;

  /// No description provided for @shareLogs.
  ///
  /// In en, this message translates to:
  /// **'Share logs (JSON)'**
  String get shareLogs;

  /// No description provided for @logsExport.
  ///
  /// In en, this message translates to:
  /// **'Logs export'**
  String get logsExport;

  /// No description provided for @addFilters.
  ///
  /// In en, this message translates to:
  /// **'Add filters'**
  String get addFilters;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAll;

  /// No description provided for @failedToShareLogs.
  ///
  /// In en, this message translates to:
  /// **'Failed to share logs: {error}'**
  String failedToShareLogs(Object error);

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @nodeIdHex.
  ///
  /// In en, this message translates to:
  /// **'ID: 0x{hex}'**
  String nodeIdHex(Object hex);

  /// No description provided for @nodeTitleHex.
  ///
  /// In en, this message translates to:
  /// **'Node 0x{hex}'**
  String nodeTitleHex(Object hex);

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @hopsAway.
  ///
  /// In en, this message translates to:
  /// **'Hops away'**
  String get hopsAway;

  /// No description provided for @snrLabel.
  ///
  /// In en, this message translates to:
  /// **'SNR'**
  String get snrLabel;

  /// No description provided for @lastSeenLabel.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeenLabel;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @messageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Message too long'**
  String get messageTooLong;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String sendFailed(Object error);

  /// No description provided for @buildPrefix.
  ///
  /// In en, this message translates to:
  /// **'Build: '**
  String get buildPrefix;

  /// No description provided for @builtPrefix.
  ///
  /// In en, this message translates to:
  /// **'Built: '**
  String get builtPrefix;

  /// No description provided for @agoSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s ago'**
  String agoSeconds(Object seconds);

  /// No description provided for @agoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String agoMinutes(Object minutes);

  /// No description provided for @agoHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String agoHours(Object hours);

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String agoDays(Object days);

  /// No description provided for @sortAsc.
  ///
  /// In en, this message translates to:
  /// **'ASC'**
  String get sortAsc;

  /// No description provided for @sortDesc.
  ///
  /// In en, this message translates to:
  /// **'DESC'**
  String get sortDesc;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownState;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// No description provided for @languageFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system language'**
  String get languageFollowSystem;

  /// No description provided for @languageAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language: {language}'**
  String languageAppLanguage(Object language);

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event details'**
  String get eventDetails;

  /// No description provided for @myInfo.
  ///
  /// In en, this message translates to:
  /// **'MyInfo'**
  String get myInfo;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get config;

  /// No description provided for @configComplete.
  ///
  /// In en, this message translates to:
  /// **'Config complete'**
  String get configComplete;

  /// No description provided for @rebooted.
  ///
  /// In en, this message translates to:
  /// **'Rebooted'**
  String get rebooted;

  /// No description provided for @moduleConfig.
  ///
  /// In en, this message translates to:
  /// **'Module config'**
  String get moduleConfig;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @queueStatus.
  ///
  /// In en, this message translates to:
  /// **'Queue status'**
  String get queueStatus;

  /// No description provided for @deviceMetadata.
  ///
  /// In en, this message translates to:
  /// **'Device metadata'**
  String get deviceMetadata;

  /// No description provided for @mqttProxy.
  ///
  /// In en, this message translates to:
  /// **'MQTT proxy'**
  String get mqttProxy;

  /// No description provided for @fileInfo.
  ///
  /// In en, this message translates to:
  /// **'File info'**
  String get fileInfo;

  /// No description provided for @clientNotification.
  ///
  /// In en, this message translates to:
  /// **'Client notification'**
  String get clientNotification;

  /// No description provided for @deviceUiConfig.
  ///
  /// In en, this message translates to:
  /// **'Device UI config'**
  String get deviceUiConfig;

  /// No description provided for @logRecord.
  ///
  /// In en, this message translates to:
  /// **'Log record'**
  String get logRecord;

  /// No description provided for @packet.
  ///
  /// In en, this message translates to:
  /// **'Packet'**
  String get packet;

  /// No description provided for @textPayload.
  ///
  /// In en, this message translates to:
  /// **'Text payload'**
  String get textPayload;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @rawPayloadDetails.
  ///
  /// In en, this message translates to:
  /// **'Raw payload ({name}:{id}, {bytes} bytes)'**
  String rawPayloadDetails(Object bytes, Object id, Object name);

  /// No description provided for @encryptedUnknownPayload.
  ///
  /// In en, this message translates to:
  /// **'Encrypted/unknown payload'**
  String get encryptedUnknownPayload;

  /// No description provided for @configUpdate.
  ///
  /// In en, this message translates to:
  /// **'Config update'**
  String get configUpdate;

  /// No description provided for @configStreamComplete.
  ///
  /// In en, this message translates to:
  /// **'Config stream complete'**
  String get configStreamComplete;

  /// No description provided for @deviceReportedReboot.
  ///
  /// In en, this message translates to:
  /// **'Device reported reboot'**
  String get deviceReportedReboot;

  /// No description provided for @noReboot.
  ///
  /// In en, this message translates to:
  /// **'No reboot'**
  String get noReboot;

  /// No description provided for @channelUpdate.
  ///
  /// In en, this message translates to:
  /// **'Channel update'**
  String get channelUpdate;

  /// No description provided for @routingMessage.
  ///
  /// In en, this message translates to:
  /// **'Routing message'**
  String get routingMessage;

  /// No description provided for @adminMessage.
  ///
  /// In en, this message translates to:
  /// **'Admin message'**
  String get adminMessage;

  /// No description provided for @positionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Position update'**
  String get positionUpdate;

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User info'**
  String get userInfo;

  /// No description provided for @remoteHw.
  ///
  /// In en, this message translates to:
  /// **'Remote HW: {type} mask={mask} value={value}'**
  String remoteHw(Object mask, Object type, Object value);

  /// No description provided for @storeForwardVariant.
  ///
  /// In en, this message translates to:
  /// **'Store & Forward ({variant})'**
  String storeForwardVariant(Object variant);

  /// No description provided for @telemetryVariant.
  ///
  /// In en, this message translates to:
  /// **'Telemetry ({variant})'**
  String telemetryVariant(Object variant);

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @serial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serial;

  /// No description provided for @rangeTest.
  ///
  /// In en, this message translates to:
  /// **'Range test'**
  String get rangeTest;

  /// No description provided for @externalNotification.
  ///
  /// In en, this message translates to:
  /// **'External notification'**
  String get externalNotification;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @cannedMessage.
  ///
  /// In en, this message translates to:
  /// **'Canned message'**
  String get cannedMessage;

  /// No description provided for @ambientLighting.
  ///
  /// In en, this message translates to:
  /// **'Ambient lighting'**
  String get ambientLighting;

  /// No description provided for @detectionSensor.
  ///
  /// In en, this message translates to:
  /// **'Detection sensor'**
  String get detectionSensor;

  /// No description provided for @dtnOverlay.
  ///
  /// In en, this message translates to:
  /// **'DTN overlay'**
  String get dtnOverlay;

  /// No description provided for @broadcastAssist.
  ///
  /// In en, this message translates to:
  /// **'Broadcast assist'**
  String get broadcastAssist;

  /// No description provided for @nodeFilter.
  ///
  /// In en, this message translates to:
  /// **'Node filter'**
  String get nodeFilter;

  /// No description provided for @nodeHighlight.
  ///
  /// In en, this message translates to:
  /// **'Node highlight'**
  String get nodeHighlight;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @snrDb.
  ///
  /// In en, this message translates to:
  /// **'SNR {value} dB'**
  String snrDb(Object value);

  /// No description provided for @nodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Node {name}'**
  String nodeTitle(Object name);

  /// No description provided for @nodeTitleId.
  ///
  /// In en, this message translates to:
  /// **'Node ({id})'**
  String nodeTitleId(Object id);

  /// No description provided for @nodeInfo.
  ///
  /// In en, this message translates to:
  /// **'NodeInfo'**
  String get nodeInfo;

  /// No description provided for @batteryLevel.
  ///
  /// In en, this message translates to:
  /// **'🔋{percentage}%'**
  String batteryLevel(Object percentage);

  /// No description provided for @viaNameId.
  ///
  /// In en, this message translates to:
  /// **'via {name} (0x{id})'**
  String viaNameId(Object id, Object name);

  /// No description provided for @viaName.
  ///
  /// In en, this message translates to:
  /// **'via {name}'**
  String viaName(Object name);

  /// No description provided for @viaId.
  ///
  /// In en, this message translates to:
  /// **'via 0x{id}'**
  String viaId(Object id);

  /// No description provided for @devicesTab.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTab;

  /// No description provided for @searchLogs.
  ///
  /// In en, this message translates to:
  /// **'Search logs'**
  String get searchLogs;

  /// No description provided for @searchLogsHint.
  ///
  /// In en, this message translates to:
  /// **'Search in time, level, tags or message'**
  String get searchLogsHint;

  /// No description provided for @logsTitle.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logsTitle;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @valueEmptyPresence.
  ///
  /// In en, this message translates to:
  /// **'Value (empty = presence only for exact)'**
  String get valueEmptyPresence;

  /// No description provided for @regexTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: regex uses Dart syntax and is case-insensitive by default'**
  String get regexTip;

  /// No description provided for @selectLevels.
  ///
  /// In en, this message translates to:
  /// **'Select levels'**
  String get selectLevels;

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'(unspecified)'**
  String get unspecified;

  /// No description provided for @connectFailedError.
  ///
  /// In en, this message translates to:
  /// **'Connect failed: {error}'**
  String connectFailedError(Object error);

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @lora.
  ///
  /// In en, this message translates to:
  /// **'LoRa'**
  String get lora;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @sessionKey.
  ///
  /// In en, this message translates to:
  /// **'Session key'**
  String get sessionKey;

  /// No description provided for @nodeMod.
  ///
  /// In en, this message translates to:
  /// **'Node mod'**
  String get nodeMod;

  /// No description provided for @nodeModAdmin.
  ///
  /// In en, this message translates to:
  /// **'Node mod admin'**
  String get nodeModAdmin;

  /// No description provided for @idleGame.
  ///
  /// In en, this message translates to:
  /// **'Idle game'**
  String get idleGame;

  /// No description provided for @deviceState.
  ///
  /// In en, this message translates to:
  /// **'Device State'**
  String get deviceState;

  /// No description provided for @noDeviceState.
  ///
  /// In en, this message translates to:
  /// **'No device state'**
  String get noDeviceState;

  /// No description provided for @connectToViewState.
  ///
  /// In en, this message translates to:
  /// **'Connect to the device to view its state'**
  String get connectToViewState;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @roleWithRole.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleWithRole(Object role);

  /// No description provided for @knownNodes.
  ///
  /// In en, this message translates to:
  /// **'Known nodes'**
  String get knownNodes;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get notConfigured;

  /// No description provided for @noConfigurationData.
  ///
  /// In en, this message translates to:
  /// **'No configuration data received'**
  String get noConfigurationData;

  /// No description provided for @nodesWithCount.
  ///
  /// In en, this message translates to:
  /// **'Nodes ({count})'**
  String nodesWithCount(Object count);

  /// No description provided for @messageDetails.
  ///
  /// In en, this message translates to:
  /// **'Message Details'**
  String get messageDetails;

  /// No description provided for @statusWithStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusWithStatus(Object status);

  /// No description provided for @packetIdWithId.
  ///
  /// In en, this message translates to:
  /// **'Packet ID: {id}'**
  String packetIdWithId(Object id);

  /// No description provided for @messageInfo.
  ///
  /// In en, this message translates to:
  /// **'Message Info'**
  String get messageInfo;

  /// No description provided for @sessionKeyRequested.
  ///
  /// In en, this message translates to:
  /// **'Session key requested'**
  String get sessionKeyRequested;

  /// No description provided for @stateMissing.
  ///
  /// In en, this message translates to:
  /// **'State Missing'**
  String get stateMissing;

  /// No description provided for @idWithId.
  ///
  /// In en, this message translates to:
  /// **'id={id}'**
  String idWithId(Object id);

  /// No description provided for @xmodem.
  ///
  /// In en, this message translates to:
  /// **'XModem'**
  String get xmodem;

  /// No description provided for @xmodemStatus.
  ///
  /// In en, this message translates to:
  /// **'seq={seq} control={control}'**
  String xmodemStatus(Object control, Object seq);

  /// No description provided for @idTitle.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idTitle;

  /// No description provided for @protectApp.
  ///
  /// In en, this message translates to:
  /// **'Protect App'**
  String get protectApp;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @hostInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Host (IP address or hostname)'**
  String get hostInputLabel;

  /// No description provided for @portInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get portInputLabel;

  /// No description provided for @invalidHostPort.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid host and port'**
  String get invalidHostPort;

  /// No description provided for @connectedToIpDevice.
  ///
  /// In en, this message translates to:
  /// **'Connected to IP device'**
  String get connectedToIpDevice;

  /// No description provided for @connectedToUsbDevice.
  ///
  /// In en, this message translates to:
  /// **'Connected to USB device'**
  String get connectedToUsbDevice;

  /// No description provided for @refreshPorts.
  ///
  /// In en, this message translates to:
  /// **'Refresh Ports'**
  String get refreshPorts;

  /// No description provided for @noSerialPortsFound.
  ///
  /// In en, this message translates to:
  /// **'No serial ports found'**
  String get noSerialPortsFound;

  /// No description provided for @selectSerialPort.
  ///
  /// In en, this message translates to:
  /// **'Select Serial Port'**
  String get selectSerialPort;

  /// No description provided for @xmodemTitle.
  ///
  /// In en, this message translates to:
  /// **'XModem'**
  String get xmodemTitle;

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emptyState;

  /// No description provided for @filterKey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get filterKey;

  /// No description provided for @satelliteEmoji.
  ///
  /// In en, this message translates to:
  /// **'📡'**
  String get satelliteEmoji;

  /// No description provided for @puzzleEmoji.
  ///
  /// In en, this message translates to:
  /// **'🧩'**
  String get puzzleEmoji;

  /// No description provided for @appProtected.
  ///
  /// In en, this message translates to:
  /// **'App is protected. Advanced features are hidden.'**
  String get appProtected;

  /// No description provided for @disableProtection.
  ///
  /// In en, this message translates to:
  /// **'Disable Protection'**
  String get disableProtection;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @connectToIpDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect to Meshtastic Device via IP'**
  String get connectToIpDevice;

  /// No description provided for @connectViaUsb.
  ///
  /// In en, this message translates to:
  /// **'Connect via USB'**
  String get connectViaUsb;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @defaultChannel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultChannel;

  /// No description provided for @rssiDbm.
  ///
  /// In en, this message translates to:
  /// **'{value} dBm'**
  String rssiDbm(Object value);

  /// No description provided for @sendingToRadio.
  ///
  /// In en, this message translates to:
  /// **'Sending to radio...'**
  String get sendingToRadio;

  /// No description provided for @sentToRadio.
  ///
  /// In en, this message translates to:
  /// **'Sent to radio'**
  String get sentToRadio;

  /// No description provided for @acknowledgedByReceiver.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged by receiver'**
  String get acknowledgedByReceiver;

  /// No description provided for @acknowledgedByRelay.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged by relay node'**
  String get acknowledgedByRelay;

  /// No description provided for @notAcknowledgedTimeout.
  ///
  /// In en, this message translates to:
  /// **'Not acknowledged (Timeout)'**
  String get notAcknowledgedTimeout;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @packetInfo.
  ///
  /// In en, this message translates to:
  /// **'Packet Info:'**
  String get packetInfo;

  /// No description provided for @nodeName.
  ///
  /// In en, this message translates to:
  /// **'Node {name}'**
  String nodeName(Object name);

  /// No description provided for @unknownNode.
  ///
  /// In en, this message translates to:
  /// **'Node {id} (Unknown)'**
  String unknownNode(Object id);

  /// No description provided for @deviceConfig.
  ///
  /// In en, this message translates to:
  /// **'Device Config'**
  String get deviceConfig;

  /// No description provided for @positionConfig.
  ///
  /// In en, this message translates to:
  /// **'Position Config'**
  String get positionConfig;

  /// No description provided for @powerConfig.
  ///
  /// In en, this message translates to:
  /// **'Power Config'**
  String get powerConfig;

  /// No description provided for @networkConfig.
  ///
  /// In en, this message translates to:
  /// **'Network Config'**
  String get networkConfig;

  /// No description provided for @displayConfig.
  ///
  /// In en, this message translates to:
  /// **'Display Config'**
  String get displayConfig;

  /// No description provided for @loraConfig.
  ///
  /// In en, this message translates to:
  /// **'LoRa Config'**
  String get loraConfig;

  /// No description provided for @bluetoothConfig.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Config'**
  String get bluetoothConfig;

  /// No description provided for @securityConfig.
  ///
  /// In en, this message translates to:
  /// **'Security Config'**
  String get securityConfig;

  /// No description provided for @mqttConfig.
  ///
  /// In en, this message translates to:
  /// **'MQTT Config'**
  String get mqttConfig;

  /// No description provided for @telemetryConfig.
  ///
  /// In en, this message translates to:
  /// **'Telemetry Config'**
  String get telemetryConfig;

  /// No description provided for @serialConfig.
  ///
  /// In en, this message translates to:
  /// **'Serial Config'**
  String get serialConfig;

  /// No description provided for @storeForwardConfig.
  ///
  /// In en, this message translates to:
  /// **'Store & Forward Config'**
  String get storeForwardConfig;

  /// No description provided for @rangeTestConfig.
  ///
  /// In en, this message translates to:
  /// **'Range Test Config'**
  String get rangeTestConfig;

  /// No description provided for @externalNotificationConfig.
  ///
  /// In en, this message translates to:
  /// **'External Notification Config'**
  String get externalNotificationConfig;

  /// No description provided for @audioConfig.
  ///
  /// In en, this message translates to:
  /// **'Audio Config'**
  String get audioConfig;

  /// No description provided for @neighborInfoConfig.
  ///
  /// In en, this message translates to:
  /// **'Neighbor Info Config'**
  String get neighborInfoConfig;

  /// No description provided for @remoteHardwareConfig.
  ///
  /// In en, this message translates to:
  /// **'Remote Hardware Config'**
  String get remoteHardwareConfig;

  /// No description provided for @paxcounterConfig.
  ///
  /// In en, this message translates to:
  /// **'Paxcounter Config'**
  String get paxcounterConfig;

  /// No description provided for @cannedMessageConfig.
  ///
  /// In en, this message translates to:
  /// **'Canned Message Config'**
  String get cannedMessageConfig;

  /// No description provided for @ambientLightingConfig.
  ///
  /// In en, this message translates to:
  /// **'Ambient Lighting Config'**
  String get ambientLightingConfig;

  /// No description provided for @detectionSensorConfig.
  ///
  /// In en, this message translates to:
  /// **'Detection Sensor Config'**
  String get detectionSensorConfig;

  /// No description provided for @dtnOverlayConfig.
  ///
  /// In en, this message translates to:
  /// **'DTN Overlay Config'**
  String get dtnOverlayConfig;

  /// No description provided for @broadcastAssistConfig.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Assist Config'**
  String get broadcastAssistConfig;

  /// No description provided for @nodeModConfig.
  ///
  /// In en, this message translates to:
  /// **'Node Mod Config'**
  String get nodeModConfig;

  /// No description provided for @nodeModAdminConfig.
  ///
  /// In en, this message translates to:
  /// **'Node Mod Admin Config'**
  String get nodeModAdminConfig;

  /// No description provided for @idleGameConfig.
  ///
  /// In en, this message translates to:
  /// **'Idle Game Config'**
  String get idleGameConfig;

  /// No description provided for @serialEnabled.
  ///
  /// In en, this message translates to:
  /// **'Serial Enabled'**
  String get serialEnabled;

  /// No description provided for @buttonGpio.
  ///
  /// In en, this message translates to:
  /// **'Button GPIO'**
  String get buttonGpio;

  /// No description provided for @buzzerGpio.
  ///
  /// In en, this message translates to:
  /// **'Buzzer GPIO'**
  String get buzzerGpio;

  /// No description provided for @rebroadcastMode.
  ///
  /// In en, this message translates to:
  /// **'Rebroadcast Mode'**
  String get rebroadcastMode;

  /// No description provided for @nodeInfoBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'Node Info Broadcast Secs'**
  String get nodeInfoBroadcastSecs;

  /// No description provided for @doubleTapAsButtonPress.
  ///
  /// In en, this message translates to:
  /// **'Double Tap As Button Press'**
  String get doubleTapAsButtonPress;

  /// No description provided for @isManaged.
  ///
  /// In en, this message translates to:
  /// **'Is Managed'**
  String get isManaged;

  /// No description provided for @disableTripleClick.
  ///
  /// In en, this message translates to:
  /// **'Disable Triple Click'**
  String get disableTripleClick;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @ledHeartbeatDisabled.
  ///
  /// In en, this message translates to:
  /// **'LED Heartbeat Disabled'**
  String get ledHeartbeatDisabled;

  /// No description provided for @buzzerMode.
  ///
  /// In en, this message translates to:
  /// **'Buzzer Mode'**
  String get buzzerMode;

  /// No description provided for @positionBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'Position Broadcast Secs'**
  String get positionBroadcastSecs;

  /// No description provided for @positionBroadcastSmartEnabled.
  ///
  /// In en, this message translates to:
  /// **'Position Broadcast Smart Enabled'**
  String get positionBroadcastSmartEnabled;

  /// No description provided for @fixedPosition.
  ///
  /// In en, this message translates to:
  /// **'Fixed Position'**
  String get fixedPosition;

  /// No description provided for @gpsEnabled.
  ///
  /// In en, this message translates to:
  /// **'GPS Enabled'**
  String get gpsEnabled;

  /// No description provided for @gpsUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'GPS Update Interval'**
  String get gpsUpdateInterval;

  /// No description provided for @gpsAttemptTime.
  ///
  /// In en, this message translates to:
  /// **'GPS Attempt Time'**
  String get gpsAttemptTime;

  /// No description provided for @positionFlags.
  ///
  /// In en, this message translates to:
  /// **'Position Flags'**
  String get positionFlags;

  /// No description provided for @rxGpio.
  ///
  /// In en, this message translates to:
  /// **'RX GPIO'**
  String get rxGpio;

  /// No description provided for @txGpio.
  ///
  /// In en, this message translates to:
  /// **'TX GPIO'**
  String get txGpio;

  /// No description provided for @broadcastSmartMinimumDistance.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Smart Minimum Distance'**
  String get broadcastSmartMinimumDistance;

  /// No description provided for @broadcastSmartMinimumIntervalSecs.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Smart Minimum Interval Secs'**
  String get broadcastSmartMinimumIntervalSecs;

  /// No description provided for @gpsEnableGpio.
  ///
  /// In en, this message translates to:
  /// **'GPS Enable GPIO'**
  String get gpsEnableGpio;

  /// No description provided for @gpsMode.
  ///
  /// In en, this message translates to:
  /// **'GPS Mode'**
  String get gpsMode;

  /// No description provided for @isPowerSaving.
  ///
  /// In en, this message translates to:
  /// **'Is Power Saving'**
  String get isPowerSaving;

  /// No description provided for @onBatteryShutdownAfterSecs.
  ///
  /// In en, this message translates to:
  /// **'On Battery Shutdown After Secs'**
  String get onBatteryShutdownAfterSecs;

  /// No description provided for @adcMultiplierOverride.
  ///
  /// In en, this message translates to:
  /// **'ADC Multiplier Override'**
  String get adcMultiplierOverride;

  /// No description provided for @waitBluetoothSecs.
  ///
  /// In en, this message translates to:
  /// **'Wait Bluetooth Secs'**
  String get waitBluetoothSecs;

  /// No description provided for @sdsSecs.
  ///
  /// In en, this message translates to:
  /// **'SDS Secs'**
  String get sdsSecs;

  /// No description provided for @lsSecs.
  ///
  /// In en, this message translates to:
  /// **'LS Secs'**
  String get lsSecs;

  /// No description provided for @minWakeSecs.
  ///
  /// In en, this message translates to:
  /// **'Min Wake Secs'**
  String get minWakeSecs;

  /// No description provided for @deviceBatteryInaAddress.
  ///
  /// In en, this message translates to:
  /// **'Device Battery INA Address'**
  String get deviceBatteryInaAddress;

  /// No description provided for @powermonEnables.
  ///
  /// In en, this message translates to:
  /// **'Powermon Enables'**
  String get powermonEnables;

  /// No description provided for @wifiEnabled.
  ///
  /// In en, this message translates to:
  /// **'WiFi Enabled'**
  String get wifiEnabled;

  /// No description provided for @wifiSsid.
  ///
  /// In en, this message translates to:
  /// **'WiFi SSID'**
  String get wifiSsid;

  /// No description provided for @screenOnSecs.
  ///
  /// In en, this message translates to:
  /// **'Screen On Secs'**
  String get screenOnSecs;

  /// No description provided for @autoScreenCarouselSecs.
  ///
  /// In en, this message translates to:
  /// **'Auto Screen Carousel Secs'**
  String get autoScreenCarouselSecs;

  /// No description provided for @compassNorthTop.
  ///
  /// In en, this message translates to:
  /// **'Compass North Top'**
  String get compassNorthTop;

  /// No description provided for @flipScreen.
  ///
  /// In en, this message translates to:
  /// **'Flip Screen'**
  String get flipScreen;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @oled.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get oled;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// No description provided for @headingBold.
  ///
  /// In en, this message translates to:
  /// **'Heading Bold'**
  String get headingBold;

  /// No description provided for @wakeOnTapOrMotion.
  ///
  /// In en, this message translates to:
  /// **'Wake On Tap Or Motion'**
  String get wakeOnTapOrMotion;

  /// No description provided for @compassOrientation.
  ///
  /// In en, this message translates to:
  /// **'Compass Orientation'**
  String get compassOrientation;

  /// No description provided for @use12hClock.
  ///
  /// In en, this message translates to:
  /// **'Use 12h Clock'**
  String get use12hClock;

  /// No description provided for @useLongNodeName.
  ///
  /// In en, this message translates to:
  /// **'Use Long Node Name'**
  String get useLongNodeName;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @modemPreset.
  ///
  /// In en, this message translates to:
  /// **'Modem Preset'**
  String get modemPreset;

  /// No description provided for @hopLimit.
  ///
  /// In en, this message translates to:
  /// **'Hop Limit'**
  String get hopLimit;

  /// No description provided for @txEnabled.
  ///
  /// In en, this message translates to:
  /// **'TX Enabled'**
  String get txEnabled;

  /// No description provided for @txPower.
  ///
  /// In en, this message translates to:
  /// **'TX Power'**
  String get txPower;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @fixedPin.
  ///
  /// In en, this message translates to:
  /// **'Fixed PIN'**
  String get fixedPin;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get publicKey;

  /// No description provided for @privateKey.
  ///
  /// In en, this message translates to:
  /// **'Private Key'**
  String get privateKey;

  /// No description provided for @adminKeys.
  ///
  /// In en, this message translates to:
  /// **'Admin Keys'**
  String get adminKeys;

  /// No description provided for @debugLogApiEnabled.
  ///
  /// In en, this message translates to:
  /// **'Debug Log API Enabled'**
  String get debugLogApiEnabled;

  /// No description provided for @adminChannelEnabled.
  ///
  /// In en, this message translates to:
  /// **'Admin Channel Enabled'**
  String get adminChannelEnabled;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryption;

  /// No description provided for @json.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get json;

  /// No description provided for @tls.
  ///
  /// In en, this message translates to:
  /// **'TLS'**
  String get tls;

  /// No description provided for @rootTopic.
  ///
  /// In en, this message translates to:
  /// **'Root Topic'**
  String get rootTopic;

  /// No description provided for @proxyToClient.
  ///
  /// In en, this message translates to:
  /// **'Proxy to Client'**
  String get proxyToClient;

  /// No description provided for @mapReporting.
  ///
  /// In en, this message translates to:
  /// **'Map Reporting'**
  String get mapReporting;

  /// No description provided for @deviceUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Device Update Interval'**
  String get deviceUpdateInterval;

  /// No description provided for @environmentUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Environment Update Interval'**
  String get environmentUpdateInterval;

  /// No description provided for @environmentMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Environment Measurement'**
  String get environmentMeasurement;

  /// No description provided for @environmentScreen.
  ///
  /// In en, this message translates to:
  /// **'Environment Screen'**
  String get environmentScreen;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get airQuality;

  /// No description provided for @airQualityInterval.
  ///
  /// In en, this message translates to:
  /// **'Air Quality Interval'**
  String get airQualityInterval;

  /// No description provided for @powerMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Power Measurement'**
  String get powerMeasurement;

  /// No description provided for @powerUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Power Update Interval'**
  String get powerUpdateInterval;

  /// No description provided for @powerScreen.
  ///
  /// In en, this message translates to:
  /// **'Power Screen'**
  String get powerScreen;

  /// No description provided for @healthMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Health Measurement'**
  String get healthMeasurement;

  /// No description provided for @healthUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Health Update Interval'**
  String get healthUpdateInterval;

  /// No description provided for @healthScreen.
  ///
  /// In en, this message translates to:
  /// **'Health Screen'**
  String get healthScreen;

  /// No description provided for @deviceTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Device Telemetry'**
  String get deviceTelemetry;

  /// No description provided for @echo.
  ///
  /// In en, this message translates to:
  /// **'Echo'**
  String get echo;

  /// No description provided for @rxd.
  ///
  /// In en, this message translates to:
  /// **'RXD'**
  String get rxd;

  /// No description provided for @txd.
  ///
  /// In en, this message translates to:
  /// **'TXD'**
  String get txd;

  /// No description provided for @baud.
  ///
  /// In en, this message translates to:
  /// **'Baud'**
  String get baud;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// No description provided for @overrideConsole.
  ///
  /// In en, this message translates to:
  /// **'Override Console'**
  String get overrideConsole;

  /// No description provided for @heartbeat.
  ///
  /// In en, this message translates to:
  /// **'Heartbeat'**
  String get heartbeat;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @historyReturnMax.
  ///
  /// In en, this message translates to:
  /// **'History Return Max'**
  String get historyReturnMax;

  /// No description provided for @historyReturnWindow.
  ///
  /// In en, this message translates to:
  /// **'History Return Window'**
  String get historyReturnWindow;

  /// No description provided for @isServer.
  ///
  /// In en, this message translates to:
  /// **'Is Server'**
  String get isServer;

  /// No description provided for @emitControlSignals.
  ///
  /// In en, this message translates to:
  /// **'Emit Control Signals'**
  String get emitControlSignals;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @clearOnReboot.
  ///
  /// In en, this message translates to:
  /// **'Clear on Reboot'**
  String get clearOnReboot;

  /// No description provided for @outputMs.
  ///
  /// In en, this message translates to:
  /// **'Output MS'**
  String get outputMs;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @alertMessage.
  ///
  /// In en, this message translates to:
  /// **'Alert Message'**
  String get alertMessage;

  /// No description provided for @alertBell.
  ///
  /// In en, this message translates to:
  /// **'Alert Bell'**
  String get alertBell;

  /// No description provided for @usePwm.
  ///
  /// In en, this message translates to:
  /// **'Use PWM'**
  String get usePwm;

  /// No description provided for @outputVibra.
  ///
  /// In en, this message translates to:
  /// **'Output Vibra'**
  String get outputVibra;

  /// No description provided for @outputBuzzer.
  ///
  /// In en, this message translates to:
  /// **'Output Buzzer'**
  String get outputBuzzer;

  /// No description provided for @nagTimeout.
  ///
  /// In en, this message translates to:
  /// **'Nag Timeout'**
  String get nagTimeout;

  /// No description provided for @useI2sAsBuzzer.
  ///
  /// In en, this message translates to:
  /// **'Use I2S as Buzzer'**
  String get useI2sAsBuzzer;

  /// No description provided for @codec2Enabled.
  ///
  /// In en, this message translates to:
  /// **'Codec2 Enabled'**
  String get codec2Enabled;

  /// No description provided for @pttPin.
  ///
  /// In en, this message translates to:
  /// **'PTT Pin'**
  String get pttPin;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @i2sWs.
  ///
  /// In en, this message translates to:
  /// **'I2S WS'**
  String get i2sWs;

  /// No description provided for @i2sSd.
  ///
  /// In en, this message translates to:
  /// **'I2S SD'**
  String get i2sSd;

  /// No description provided for @i2sDin.
  ///
  /// In en, this message translates to:
  /// **'I2S DIN'**
  String get i2sDin;

  /// No description provided for @i2sSck.
  ///
  /// In en, this message translates to:
  /// **'I2S SCK'**
  String get i2sSck;

  /// No description provided for @updateInterval.
  ///
  /// In en, this message translates to:
  /// **'Update Interval'**
  String get updateInterval;

  /// No description provided for @transmitOverLora.
  ///
  /// In en, this message translates to:
  /// **'Transmit Over LoRa'**
  String get transmitOverLora;

  /// No description provided for @allowUndefinedPinAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Undefined Pin Access'**
  String get allowUndefinedPinAccess;

  /// No description provided for @paxcounterUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Paxcounter Update Interval'**
  String get paxcounterUpdateInterval;

  /// No description provided for @wifiThreshold.
  ///
  /// In en, this message translates to:
  /// **'WiFi Threshold'**
  String get wifiThreshold;

  /// No description provided for @bleThreshold.
  ///
  /// In en, this message translates to:
  /// **'BLE Threshold'**
  String get bleThreshold;

  /// No description provided for @rotary1Enabled.
  ///
  /// In en, this message translates to:
  /// **'Rotary1 Enabled'**
  String get rotary1Enabled;

  /// No description provided for @inputBrokerPinA.
  ///
  /// In en, this message translates to:
  /// **'Input Broker Pin A'**
  String get inputBrokerPinA;

  /// No description provided for @inputBrokerPinB.
  ///
  /// In en, this message translates to:
  /// **'Input Broker Pin B'**
  String get inputBrokerPinB;

  /// No description provided for @inputBrokerPinPress.
  ///
  /// In en, this message translates to:
  /// **'Input Broker Pin Press'**
  String get inputBrokerPinPress;

  /// No description provided for @upDown1Enabled.
  ///
  /// In en, this message translates to:
  /// **'Up/Down 1 Enabled'**
  String get upDown1Enabled;

  /// No description provided for @allowInputSource.
  ///
  /// In en, this message translates to:
  /// **'Allow Input Source'**
  String get allowInputSource;

  /// No description provided for @sendBell.
  ///
  /// In en, this message translates to:
  /// **'Send Bell'**
  String get sendBell;

  /// No description provided for @ledState.
  ///
  /// In en, this message translates to:
  /// **'LED State'**
  String get ledState;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @minBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'Min Broadcast Secs'**
  String get minBroadcastSecs;

  /// No description provided for @stateBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'State Broadcast Secs'**
  String get stateBroadcastSecs;

  /// No description provided for @monitorPin.
  ///
  /// In en, this message translates to:
  /// **'Monitor Pin'**
  String get monitorPin;

  /// No description provided for @triggerType.
  ///
  /// In en, this message translates to:
  /// **'Trigger Type'**
  String get triggerType;

  /// No description provided for @usePullup.
  ///
  /// In en, this message translates to:
  /// **'Use Pullup'**
  String get usePullup;

  /// No description provided for @ttlMinutes.
  ///
  /// In en, this message translates to:
  /// **'TTL Minutes'**
  String get ttlMinutes;

  /// No description provided for @initialDelayBaseMs.
  ///
  /// In en, this message translates to:
  /// **'Initial Delay Base MS'**
  String get initialDelayBaseMs;

  /// No description provided for @retryBackoffMs.
  ///
  /// In en, this message translates to:
  /// **'Retry Backoff MS'**
  String get retryBackoffMs;

  /// No description provided for @maxTries.
  ///
  /// In en, this message translates to:
  /// **'Max Tries'**
  String get maxTries;

  /// No description provided for @degreeThreshold.
  ///
  /// In en, this message translates to:
  /// **'Degree Threshold'**
  String get degreeThreshold;

  /// No description provided for @dupThreshold.
  ///
  /// In en, this message translates to:
  /// **'Dup Threshold'**
  String get dupThreshold;

  /// No description provided for @windowMs.
  ///
  /// In en, this message translates to:
  /// **'Window MS'**
  String get windowMs;

  /// No description provided for @maxExtraHops.
  ///
  /// In en, this message translates to:
  /// **'Max Extra Hops'**
  String get maxExtraHops;

  /// No description provided for @jitterMs.
  ///
  /// In en, this message translates to:
  /// **'Jitter MS'**
  String get jitterMs;

  /// No description provided for @airtimeGuard.
  ///
  /// In en, this message translates to:
  /// **'Airtime Guard'**
  String get airtimeGuard;

  /// No description provided for @textStatus.
  ///
  /// In en, this message translates to:
  /// **'Text Status'**
  String get textStatus;

  /// No description provided for @emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// No description provided for @snifferEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sniffer Enabled'**
  String get snifferEnabled;

  /// No description provided for @doNotSendPrvOverMqtt.
  ///
  /// In en, this message translates to:
  /// **'Do Not Send PRV Over MQTT'**
  String get doNotSendPrvOverMqtt;

  /// No description provided for @localStatsOverMesh.
  ///
  /// In en, this message translates to:
  /// **'Local Stats Over Mesh'**
  String get localStatsOverMesh;

  /// No description provided for @idlegameEnabled.
  ///
  /// In en, this message translates to:
  /// **'Idle Game Enabled'**
  String get idlegameEnabled;

  /// No description provided for @autoResponderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Auto Responder Enabled'**
  String get autoResponderEnabled;

  /// No description provided for @autoResponderText.
  ///
  /// In en, this message translates to:
  /// **'Auto Responder Text'**
  String get autoResponderText;

  /// No description provided for @autoRedirectMessages.
  ///
  /// In en, this message translates to:
  /// **'Auto Redirect Messages'**
  String get autoRedirectMessages;

  /// No description provided for @autoRedirectTarget.
  ///
  /// In en, this message translates to:
  /// **'Auto Redirect Target'**
  String get autoRedirectTarget;

  /// No description provided for @telemetryLimiter.
  ///
  /// In en, this message translates to:
  /// **'Telemetry Limiter'**
  String get telemetryLimiter;

  /// No description provided for @positionLimiter.
  ///
  /// In en, this message translates to:
  /// **'Position Limiter'**
  String get positionLimiter;

  /// No description provided for @opportunisticFlooding.
  ///
  /// In en, this message translates to:
  /// **'Opportunistic Flooding'**
  String get opportunisticFlooding;

  /// No description provided for @idleGameVariant.
  ///
  /// In en, this message translates to:
  /// **'Idle Game Variant'**
  String get idleGameVariant;

  /// No description provided for @telemetryTitle.
  ///
  /// In en, this message translates to:
  /// **'Telemetry'**
  String get telemetryTitle;

  /// No description provided for @noTelemetryData.
  ///
  /// In en, this message translates to:
  /// **'No telemetry data available'**
  String get noTelemetryData;

  /// No description provided for @telemetryBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get telemetryBattery;

  /// No description provided for @telemetryVoltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get telemetryVoltage;

  /// No description provided for @telemetryChannelUtil.
  ///
  /// In en, this message translates to:
  /// **'Channel Util'**
  String get telemetryChannelUtil;

  /// No description provided for @telemetryAirUtilTx.
  ///
  /// In en, this message translates to:
  /// **'Air Util Tx'**
  String get telemetryAirUtilTx;

  /// No description provided for @telemetryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get telemetryTemperature;

  /// No description provided for @telemetryHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get telemetryHumidity;

  /// No description provided for @telemetryPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get telemetryPressure;

  /// No description provided for @telemetryPm25.
  ///
  /// In en, this message translates to:
  /// **'PM2.5'**
  String get telemetryPm25;

  /// No description provided for @telemetryCo2.
  ///
  /// In en, this message translates to:
  /// **'CO2'**
  String get telemetryCo2;

  /// No description provided for @telemetryChVoltage.
  ///
  /// In en, this message translates to:
  /// **'Ch{channel} Voltage'**
  String telemetryChVoltage(Object channel);

  /// No description provided for @telemetryHistory.
  ///
  /// In en, this message translates to:
  /// **'History: {count} points'**
  String telemetryHistory(Object count);

  /// No description provided for @traces.
  ///
  /// In en, this message translates to:
  /// **'Traceroutes'**
  String get traces;

  /// No description provided for @traceRoute.
  ///
  /// In en, this message translates to:
  /// **'Trace Route'**
  String get traceRoute;

  /// No description provided for @startTrace.
  ///
  /// In en, this message translates to:
  /// **'Start Trace'**
  String get startTrace;

  /// No description provided for @traceTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get traceTarget;

  /// No description provided for @tracePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tracePending;

  /// No description provided for @traceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get traceCompleted;

  /// No description provided for @traceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get traceFailed;

  /// No description provided for @traceTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get traceTimeout;

  /// No description provided for @traceNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No traces yet'**
  String get traceNoHistory;

  /// No description provided for @traceEvents.
  ///
  /// In en, this message translates to:
  /// **'Trace Events'**
  String get traceEvents;

  /// No description provided for @traceForwardRoute.
  ///
  /// In en, this message translates to:
  /// **'Forward Route'**
  String get traceForwardRoute;

  /// No description provided for @traceReturnRoute.
  ///
  /// In en, this message translates to:
  /// **'Return Route'**
  String get traceReturnRoute;

  /// No description provided for @traceHopCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 hops} =1{1 hop} other{{count} hops}}'**
  String traceHopCount(num count);

  /// No description provided for @traceShowOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on Map'**
  String get traceShowOnMap;

  /// No description provided for @traceSelectNode.
  ///
  /// In en, this message translates to:
  /// **'Select node to trace'**
  String get traceSelectNode;

  /// No description provided for @traceSent.
  ///
  /// In en, this message translates to:
  /// **'Trace request sent'**
  String get traceSent;

  /// No description provided for @traceToggleVisualization.
  ///
  /// In en, this message translates to:
  /// **'Toggle Trace Visualization'**
  String get traceToggleVisualization;

  /// No description provided for @noNodesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No nodes available'**
  String get noNodesAvailable;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
