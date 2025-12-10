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

  /// No description provided for @statusReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting (attempt {attempt}/{max})...'**
  String statusReconnecting(Object attempt, Object max);

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

  /// No description provided for @scanRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'Device not found. Please scan for devices first.'**
  String get scanRequiredFirst;

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

  /// No description provided for @loadingConfig.
  ///
  /// In en, this message translates to:
  /// **'Loading Config'**
  String get loadingConfig;

  /// No description provided for @pleaseWaitFetchingConfig.
  ///
  /// In en, this message translates to:
  /// **'Please wait while fetching device configuration...'**
  String get pleaseWaitFetchingConfig;

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
  /// **'sessionKeyRequested'**
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
  /// **'save'**
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
  /// **'password'**
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
  /// **'serialEnabled'**
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
  /// **'isManaged'**
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
  /// **'screenOnSecs'**
  String get screenOnSecs;

  /// No description provided for @autoScreenCarouselSecs.
  ///
  /// In en, this message translates to:
  /// **'autoScreenCarouselSecs'**
  String get autoScreenCarouselSecs;

  /// No description provided for @compassNorthTop.
  ///
  /// In en, this message translates to:
  /// **'compassNorthTop'**
  String get compassNorthTop;

  /// No description provided for @flipScreen.
  ///
  /// In en, this message translates to:
  /// **'flipScreen'**
  String get flipScreen;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @oled.
  ///
  /// In en, this message translates to:
  /// **'oled'**
  String get oled;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// No description provided for @headingBold.
  ///
  /// In en, this message translates to:
  /// **'headingBold'**
  String get headingBold;

  /// No description provided for @wakeOnTapOrMotion.
  ///
  /// In en, this message translates to:
  /// **'wakeOnTapOrMotion'**
  String get wakeOnTapOrMotion;

  /// No description provided for @compassOrientation.
  ///
  /// In en, this message translates to:
  /// **'compassOrientation'**
  String get compassOrientation;

  /// No description provided for @use12hClock.
  ///
  /// In en, this message translates to:
  /// **'use12hClock'**
  String get use12hClock;

  /// No description provided for @useLongNodeName.
  ///
  /// In en, this message translates to:
  /// **'useLongNodeName'**
  String get useLongNodeName;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'region'**
  String get region;

  /// No description provided for @modemPreset.
  ///
  /// In en, this message translates to:
  /// **'modemPreset'**
  String get modemPreset;

  /// No description provided for @hopLimit.
  ///
  /// In en, this message translates to:
  /// **'hopLimit'**
  String get hopLimit;

  /// No description provided for @txEnabled.
  ///
  /// In en, this message translates to:
  /// **'txEnabled'**
  String get txEnabled;

  /// No description provided for @txPower.
  ///
  /// In en, this message translates to:
  /// **'txPower'**
  String get txPower;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'enabled'**
  String get enabled;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'mode'**
  String get mode;

  /// No description provided for @fixedPin.
  ///
  /// In en, this message translates to:
  /// **'fixedPin'**
  String get fixedPin;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'publicKey'**
  String get publicKey;

  /// No description provided for @privateKey.
  ///
  /// In en, this message translates to:
  /// **'privateKey'**
  String get privateKey;

  /// No description provided for @adminKeys.
  ///
  /// In en, this message translates to:
  /// **'Admin Keys'**
  String get adminKeys;

  /// No description provided for @debugLogApiEnabled.
  ///
  /// In en, this message translates to:
  /// **'debugLogApiEnabled'**
  String get debugLogApiEnabled;

  /// No description provided for @adminChannelEnabled.
  ///
  /// In en, this message translates to:
  /// **'adminChannelEnabled'**
  String get adminChannelEnabled;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'address'**
  String get address;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'username'**
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
  /// **'deviceUpdateInterval'**
  String get deviceUpdateInterval;

  /// No description provided for @environmentUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'environmentUpdateInterval'**
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
  /// **'airQualityInterval'**
  String get airQualityInterval;

  /// No description provided for @powerMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Power Measurement'**
  String get powerMeasurement;

  /// No description provided for @powerUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'powerUpdateInterval'**
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
  /// **'healthUpdateInterval'**
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
  /// **'echo'**
  String get echo;

  /// No description provided for @rxd.
  ///
  /// In en, this message translates to:
  /// **'rxd'**
  String get rxd;

  /// No description provided for @txd.
  ///
  /// In en, this message translates to:
  /// **'txd'**
  String get txd;

  /// No description provided for @baud.
  ///
  /// In en, this message translates to:
  /// **'baud'**
  String get baud;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'timeout'**
  String get timeout;

  /// No description provided for @overrideConsole.
  ///
  /// In en, this message translates to:
  /// **'Override Console'**
  String get overrideConsole;

  /// No description provided for @heartbeat.
  ///
  /// In en, this message translates to:
  /// **'heartbeat'**
  String get heartbeat;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @historyReturnMax.
  ///
  /// In en, this message translates to:
  /// **'historyReturnMax'**
  String get historyReturnMax;

  /// No description provided for @historyReturnWindow.
  ///
  /// In en, this message translates to:
  /// **'historyReturnWindow'**
  String get historyReturnWindow;

  /// No description provided for @isServer.
  ///
  /// In en, this message translates to:
  /// **'isServer'**
  String get isServer;

  /// No description provided for @emitControlSignals.
  ///
  /// In en, this message translates to:
  /// **'emitControlSignals'**
  String get emitControlSignals;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'sender'**
  String get sender;

  /// No description provided for @clearOnReboot.
  ///
  /// In en, this message translates to:
  /// **'clearOnReboot'**
  String get clearOnReboot;

  /// No description provided for @outputMs.
  ///
  /// In en, this message translates to:
  /// **'outputMs'**
  String get outputMs;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'output'**
  String get output;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get active;

  /// No description provided for @alertMessage.
  ///
  /// In en, this message translates to:
  /// **'alertMessage'**
  String get alertMessage;

  /// No description provided for @alertBell.
  ///
  /// In en, this message translates to:
  /// **'alertBell'**
  String get alertBell;

  /// No description provided for @usePwm.
  ///
  /// In en, this message translates to:
  /// **'usePwm'**
  String get usePwm;

  /// No description provided for @outputVibra.
  ///
  /// In en, this message translates to:
  /// **'outputVibra'**
  String get outputVibra;

  /// No description provided for @outputBuzzer.
  ///
  /// In en, this message translates to:
  /// **'outputBuzzer'**
  String get outputBuzzer;

  /// No description provided for @nagTimeout.
  ///
  /// In en, this message translates to:
  /// **'nagTimeout'**
  String get nagTimeout;

  /// No description provided for @useI2sAsBuzzer.
  ///
  /// In en, this message translates to:
  /// **'useI2sAsBuzzer'**
  String get useI2sAsBuzzer;

  /// No description provided for @codec2Enabled.
  ///
  /// In en, this message translates to:
  /// **'codec2Enabled'**
  String get codec2Enabled;

  /// No description provided for @pttPin.
  ///
  /// In en, this message translates to:
  /// **'pttPin'**
  String get pttPin;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'bitrate'**
  String get bitrate;

  /// No description provided for @i2sWs.
  ///
  /// In en, this message translates to:
  /// **'i2sWs'**
  String get i2sWs;

  /// No description provided for @i2sSd.
  ///
  /// In en, this message translates to:
  /// **'i2sSd'**
  String get i2sSd;

  /// No description provided for @i2sDin.
  ///
  /// In en, this message translates to:
  /// **'i2sDin'**
  String get i2sDin;

  /// No description provided for @i2sSck.
  ///
  /// In en, this message translates to:
  /// **'i2sSck'**
  String get i2sSck;

  /// No description provided for @updateInterval.
  ///
  /// In en, this message translates to:
  /// **'updateInterval'**
  String get updateInterval;

  /// No description provided for @transmitOverLora.
  ///
  /// In en, this message translates to:
  /// **'transmitOverLora'**
  String get transmitOverLora;

  /// No description provided for @allowUndefinedPinAccess.
  ///
  /// In en, this message translates to:
  /// **'allowUndefinedPinAccess'**
  String get allowUndefinedPinAccess;

  /// No description provided for @paxcounterUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'paxcounterUpdateInterval'**
  String get paxcounterUpdateInterval;

  /// No description provided for @wifiThreshold.
  ///
  /// In en, this message translates to:
  /// **'wifiThreshold'**
  String get wifiThreshold;

  /// No description provided for @bleThreshold.
  ///
  /// In en, this message translates to:
  /// **'bleThreshold'**
  String get bleThreshold;

  /// No description provided for @rotary1Enabled.
  ///
  /// In en, this message translates to:
  /// **'rotary1Enabled'**
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
  /// **'allowInputSource'**
  String get allowInputSource;

  /// No description provided for @sendBell.
  ///
  /// In en, this message translates to:
  /// **'sendBell'**
  String get sendBell;

  /// No description provided for @ledState.
  ///
  /// In en, this message translates to:
  /// **'ledState'**
  String get ledState;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get current;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'red'**
  String get red;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get blue;

  /// No description provided for @minBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'Min Broadcast Secs'**
  String get minBroadcastSecs;

  /// No description provided for @stateBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'stateBroadcastSecs'**
  String get stateBroadcastSecs;

  /// No description provided for @monitorPin.
  ///
  /// In en, this message translates to:
  /// **'monitorPin'**
  String get monitorPin;

  /// No description provided for @triggerType.
  ///
  /// In en, this message translates to:
  /// **'Trigger Type'**
  String get triggerType;

  /// No description provided for @usePullup.
  ///
  /// In en, this message translates to:
  /// **'usePullup'**
  String get usePullup;

  /// No description provided for @ttlMinutes.
  ///
  /// In en, this message translates to:
  /// **'ttlMinutes'**
  String get ttlMinutes;

  /// No description provided for @initialDelayBaseMs.
  ///
  /// In en, this message translates to:
  /// **'initialDelayBaseMs'**
  String get initialDelayBaseMs;

  /// No description provided for @retryBackoffMs.
  ///
  /// In en, this message translates to:
  /// **'retryBackoffMs'**
  String get retryBackoffMs;

  /// No description provided for @maxTries.
  ///
  /// In en, this message translates to:
  /// **'maxTries'**
  String get maxTries;

  /// No description provided for @degreeThreshold.
  ///
  /// In en, this message translates to:
  /// **'degreeThreshold'**
  String get degreeThreshold;

  /// No description provided for @dupThreshold.
  ///
  /// In en, this message translates to:
  /// **'dupThreshold'**
  String get dupThreshold;

  /// No description provided for @windowMs.
  ///
  /// In en, this message translates to:
  /// **'windowMs'**
  String get windowMs;

  /// No description provided for @maxExtraHops.
  ///
  /// In en, this message translates to:
  /// **'maxExtraHops'**
  String get maxExtraHops;

  /// No description provided for @jitterMs.
  ///
  /// In en, this message translates to:
  /// **'jitterMs'**
  String get jitterMs;

  /// No description provided for @airtimeGuard.
  ///
  /// In en, this message translates to:
  /// **'airtimeGuard'**
  String get airtimeGuard;

  /// No description provided for @textStatus.
  ///
  /// In en, this message translates to:
  /// **'textStatus'**
  String get textStatus;

  /// No description provided for @emoji.
  ///
  /// In en, this message translates to:
  /// **'emoji'**
  String get emoji;

  /// No description provided for @snifferEnabled.
  ///
  /// In en, this message translates to:
  /// **'snifferEnabled'**
  String get snifferEnabled;

  /// No description provided for @doNotSendPrvOverMqtt.
  ///
  /// In en, this message translates to:
  /// **'doNotSendPrvOverMqtt'**
  String get doNotSendPrvOverMqtt;

  /// No description provided for @localStatsOverMesh.
  ///
  /// In en, this message translates to:
  /// **'Local Stats Over Mesh'**
  String get localStatsOverMesh;

  /// No description provided for @idlegameEnabled.
  ///
  /// In en, this message translates to:
  /// **'idlegameEnabled'**
  String get idlegameEnabled;

  /// No description provided for @autoResponderEnabled.
  ///
  /// In en, this message translates to:
  /// **'autoResponderEnabled'**
  String get autoResponderEnabled;

  /// No description provided for @autoResponderText.
  ///
  /// In en, this message translates to:
  /// **'autoResponderText'**
  String get autoResponderText;

  /// No description provided for @autoRedirectMessages.
  ///
  /// In en, this message translates to:
  /// **'autoRedirectMessages'**
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

  /// No description provided for @noDeviceConnected.
  ///
  /// In en, this message translates to:
  /// **'No device connected'**
  String get noDeviceConnected;

  /// No description provided for @selectDevice.
  ///
  /// In en, this message translates to:
  /// **'Select Device'**
  String get selectDevice;

  /// No description provided for @bleHeartbeatInterval.
  ///
  /// In en, this message translates to:
  /// **'BLE Heartbeat Interval'**
  String get bleHeartbeatInterval;

  /// No description provided for @bleHeartbeatIntervalDescription.
  ///
  /// In en, this message translates to:
  /// **'Time between heartbeat messages sent to BLE devices (in seconds)'**
  String get bleHeartbeatIntervalDescription;

  /// No description provided for @tracerouteMinInterval.
  ///
  /// In en, this message translates to:
  /// **'Traceroute Rate Limit'**
  String get tracerouteMinInterval;

  /// No description provided for @tracerouteMinIntervalDescription.
  ///
  /// In en, this message translates to:
  /// **'Minimum seconds between traceroute requests to the same node. The firmware also enforces rate limits to prevent network congestion.'**
  String get tracerouteMinIntervalDescription;

  /// No description provided for @configTimeout.
  ///
  /// In en, this message translates to:
  /// **'Config Download Timeout'**
  String get configTimeout;

  /// No description provided for @configTimeoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Maximum time without activity when downloading device configuration (in seconds)'**
  String get configTimeoutDescription;

  /// No description provided for @nodesWithoutLocation.
  ///
  /// In en, this message translates to:
  /// **'Nodes without location'**
  String get nodesWithoutLocation;

  /// No description provided for @targetNodeNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Target node {id} has no location data. Trace line cannot be drawn.'**
  String targetNodeNoLocation(Object id);

  /// No description provided for @startLocal.
  ///
  /// In en, this message translates to:
  /// **'Start (Local)'**
  String get startLocal;

  /// No description provided for @traceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Trace'**
  String get traceTooltip;

  /// No description provided for @ackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Ack'**
  String get ackTooltip;

  /// No description provided for @localDevice.
  ///
  /// In en, this message translates to:
  /// **'Local Device'**
  String get localDevice;

  /// No description provided for @deviceMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Metrics'**
  String get deviceMetricsTitle;

  /// No description provided for @environmentMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Environment Metrics'**
  String get environmentMetricsTitle;

  /// No description provided for @airQualityMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Air Quality Metrics'**
  String get airQualityMetricsTitle;

  /// No description provided for @powerMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Power Metrics'**
  String get powerMetricsTitle;

  /// No description provided for @localStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Local Stats'**
  String get localStatsTitle;

  /// No description provided for @healthMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetricsTitle;

  /// No description provided for @hostMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Host Metrics'**
  String get hostMetricsTitle;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(Object error);

  /// No description provided for @tabBle.
  ///
  /// In en, this message translates to:
  /// **'BLE'**
  String get tabBle;

  /// No description provided for @tabIp.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get tabIp;

  /// No description provided for @tabUsb.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get tabUsb;

  /// No description provided for @tabSim.
  ///
  /// In en, this message translates to:
  /// **'Sim'**
  String get tabSim;

  /// No description provided for @simulationEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Simulation Environment'**
  String get simulationEnvironment;

  /// No description provided for @simulationDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect to a simulated device to test UI components with fake data (nodes, chat, traces, etc).'**
  String get simulationDescription;

  /// No description provided for @startSimulation.
  ///
  /// In en, this message translates to:
  /// **'Start Simulation'**
  String get startSimulation;

  /// No description provided for @connectedToSimulation.
  ///
  /// In en, this message translates to:
  /// **'Connected to Simulation Device'**
  String get connectedToSimulation;

  /// No description provided for @simulationFailed.
  ///
  /// In en, this message translates to:
  /// **'Simulation failed: {error}'**
  String simulationFailed(Object error);

  /// No description provided for @statusHistory.
  ///
  /// In en, this message translates to:
  /// **'Status History'**
  String get statusHistory;

  /// No description provided for @sourceNodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Source: {name}'**
  String sourceNodePrefix(Object name);

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'ME'**
  String get me;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'[Target]'**
  String get targetLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'[Source]'**
  String get sourceLabel;

  /// No description provided for @ackLabel.
  ///
  /// In en, this message translates to:
  /// **'[Ack]'**
  String get ackLabel;

  /// No description provided for @traceStreamError.
  ///
  /// In en, this message translates to:
  /// **'Error in trace stream: {error}'**
  String traceStreamError(Object error);

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String errorLoadingMessages(Object error);

  /// No description provided for @configSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving config: {error}'**
  String configSaveError(Object error);

  /// No description provided for @myNodeNumLabel.
  ///
  /// In en, this message translates to:
  /// **'myNodeNum={num}'**
  String myNodeNumLabel(Object num);

  /// No description provided for @nodeNumLabel.
  ///
  /// In en, this message translates to:
  /// **'num={num}'**
  String nodeNumLabel(Object num);

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'id={id}'**
  String idLabel(Object id);

  /// No description provided for @channelIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'index={index}'**
  String channelIndexLabel(Object index);

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'free={value}'**
  String freeLabel(Object value);

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'max={value}'**
  String maxLabel(Object value);

  /// No description provided for @fwLabel.
  ///
  /// In en, this message translates to:
  /// **'fw={value}'**
  String fwLabel(Object value);

  /// No description provided for @hwLabel.
  ///
  /// In en, this message translates to:
  /// **'hw={value}'**
  String hwLabel(Object value);

  /// No description provided for @roleKey.
  ///
  /// In en, this message translates to:
  /// **'role={value}'**
  String roleKey(Object value);

  /// No description provided for @wifiLabel.
  ///
  /// In en, this message translates to:
  /// **'wifi'**
  String get wifiLabel;

  /// No description provided for @btLabel.
  ///
  /// In en, this message translates to:
  /// **'bt'**
  String get btLabel;

  /// No description provided for @ethLabel.
  ///
  /// In en, this message translates to:
  /// **'eth'**
  String get ethLabel;

  /// No description provided for @bytesLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} bytes'**
  String bytesLabel(Object value);

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'from={value}'**
  String fromLabel(Object value);

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'to={value}'**
  String toLabel(Object value);

  /// No description provided for @chLabel.
  ///
  /// In en, this message translates to:
  /// **'ch={value}'**
  String chLabel(Object value);

  /// No description provided for @nonceLabel.
  ///
  /// In en, this message translates to:
  /// **'nonce={value}'**
  String nonceLabel(Object value);

  /// No description provided for @nA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get nA;

  /// No description provided for @secondsSuffix.
  ///
  /// In en, this message translates to:
  /// **'{value}s'**
  String secondsSuffix(Object value);

  /// No description provided for @myNodeNum.
  ///
  /// In en, this message translates to:
  /// **'myNodeNum'**
  String get myNodeNum;

  /// No description provided for @rebootCount.
  ///
  /// In en, this message translates to:
  /// **'rebootCount'**
  String get rebootCount;

  /// No description provided for @minAppVersion.
  ///
  /// In en, this message translates to:
  /// **'minAppVersion'**
  String get minAppVersion;

  /// No description provided for @firmwareEdition.
  ///
  /// In en, this message translates to:
  /// **'firmwareEdition'**
  String get firmwareEdition;

  /// No description provided for @nodedbCount.
  ///
  /// In en, this message translates to:
  /// **'nodedbCount'**
  String get nodedbCount;

  /// No description provided for @pioEnv.
  ///
  /// In en, this message translates to:
  /// **'pioEnv'**
  String get pioEnv;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'deviceId'**
  String get deviceId;

  /// No description provided for @nodeNum.
  ///
  /// In en, this message translates to:
  /// **'num'**
  String get nodeNum;

  /// No description provided for @userLongName.
  ///
  /// In en, this message translates to:
  /// **'user.longName'**
  String get userLongName;

  /// No description provided for @userShortName.
  ///
  /// In en, this message translates to:
  /// **'user.shortName'**
  String get userShortName;

  /// No description provided for @positionLat.
  ///
  /// In en, this message translates to:
  /// **'position.lat'**
  String get positionLat;

  /// No description provided for @positionLon.
  ///
  /// In en, this message translates to:
  /// **'position.lon'**
  String get positionLon;

  /// No description provided for @lastHeard.
  ///
  /// In en, this message translates to:
  /// **'lastHeard'**
  String get lastHeard;

  /// No description provided for @isFavorite.
  ///
  /// In en, this message translates to:
  /// **'isFavorite'**
  String get isFavorite;

  /// No description provided for @isIgnored.
  ///
  /// In en, this message translates to:
  /// **'isIgnored'**
  String get isIgnored;

  /// No description provided for @isKeyManuallyVerified.
  ///
  /// In en, this message translates to:
  /// **'isKeyManuallyVerified'**
  String get isKeyManuallyVerified;

  /// No description provided for @volt.
  ///
  /// In en, this message translates to:
  /// **'volt'**
  String get volt;

  /// No description provided for @chUtil.
  ///
  /// In en, this message translates to:
  /// **'chUtil'**
  String get chUtil;

  /// No description provided for @airUtil.
  ///
  /// In en, this message translates to:
  /// **'airUtil'**
  String get airUtil;

  /// No description provided for @uptime.
  ///
  /// In en, this message translates to:
  /// **'uptime'**
  String get uptime;

  /// No description provided for @res.
  ///
  /// In en, this message translates to:
  /// **'res'**
  String get res;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'size'**
  String get size;

  /// No description provided for @maxlen.
  ///
  /// In en, this message translates to:
  /// **'maxlen'**
  String get maxlen;

  /// No description provided for @meshPacketId.
  ///
  /// In en, this message translates to:
  /// **'meshPacketId'**
  String get meshPacketId;

  /// No description provided for @firmware.
  ///
  /// In en, this message translates to:
  /// **'fw'**
  String get firmware;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'hw'**
  String get hardware;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'wifi'**
  String get wifi;

  /// No description provided for @ethernet.
  ///
  /// In en, this message translates to:
  /// **'eth'**
  String get ethernet;

  /// No description provided for @stateVersion.
  ///
  /// In en, this message translates to:
  /// **'stateVer'**
  String get stateVersion;

  /// No description provided for @canShutdown.
  ///
  /// In en, this message translates to:
  /// **'canShutdown'**
  String get canShutdown;

  /// No description provided for @hasRemoteHw.
  ///
  /// In en, this message translates to:
  /// **'hasRemoteHw'**
  String get hasRemoteHw;

  /// No description provided for @hasPKC.
  ///
  /// In en, this message translates to:
  /// **'hasPKC'**
  String get hasPKC;

  /// No description provided for @excluded.
  ///
  /// In en, this message translates to:
  /// **'excluded'**
  String get excluded;

  /// No description provided for @hasFwPlus.
  ///
  /// In en, this message translates to:
  /// **'hasFwPlus'**
  String get hasFwPlus;

  /// No description provided for @hasNodemod.
  ///
  /// In en, this message translates to:
  /// **'hasNodemod'**
  String get hasNodemod;

  /// No description provided for @topic.
  ///
  /// In en, this message translates to:
  /// **'topic'**
  String get topic;

  /// No description provided for @retained.
  ///
  /// In en, this message translates to:
  /// **'retained'**
  String get retained;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'text'**
  String get text;

  /// No description provided for @dataLength.
  ///
  /// In en, this message translates to:
  /// **'dataLen'**
  String get dataLength;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get fileName;

  /// No description provided for @sizeBytes.
  ///
  /// In en, this message translates to:
  /// **'sizeBytes'**
  String get sizeBytes;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'message'**
  String get message;

  /// No description provided for @replyId.
  ///
  /// In en, this message translates to:
  /// **'replyId'**
  String get replyId;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get time;

  /// No description provided for @payloadVariant.
  ///
  /// In en, this message translates to:
  /// **'payloadVariant'**
  String get payloadVariant;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'source'**
  String get source;

  /// No description provided for @control.
  ///
  /// In en, this message translates to:
  /// **'control'**
  String get control;

  /// No description provided for @seq.
  ///
  /// In en, this message translates to:
  /// **'seq'**
  String get seq;

  /// No description provided for @crc16.
  ///
  /// In en, this message translates to:
  /// **'crc16'**
  String get crc16;

  /// No description provided for @buffer.
  ///
  /// In en, this message translates to:
  /// **'buffer'**
  String get buffer;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @rxTime.
  ///
  /// In en, this message translates to:
  /// **'rxTime'**
  String get rxTime;

  /// No description provided for @rxRssi.
  ///
  /// In en, this message translates to:
  /// **'rxRssi'**
  String get rxRssi;

  /// No description provided for @rxSnr.
  ///
  /// In en, this message translates to:
  /// **'rxSnr'**
  String get rxSnr;

  /// No description provided for @wantAck.
  ///
  /// In en, this message translates to:
  /// **'wantAck'**
  String get wantAck;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'priority'**
  String get priority;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'transport'**
  String get transport;

  /// No description provided for @hopStart.
  ///
  /// In en, this message translates to:
  /// **'hopStart'**
  String get hopStart;

  /// No description provided for @encrypted.
  ///
  /// In en, this message translates to:
  /// **'encrypted'**
  String get encrypted;

  /// No description provided for @pkiEncrypted.
  ///
  /// In en, this message translates to:
  /// **'pkiEncrypted'**
  String get pkiEncrypted;

  /// No description provided for @nextHop.
  ///
  /// In en, this message translates to:
  /// **'nextHop'**
  String get nextHop;

  /// No description provided for @relayNode.
  ///
  /// In en, this message translates to:
  /// **'relayNode'**
  String get relayNode;

  /// No description provided for @txAfter.
  ///
  /// In en, this message translates to:
  /// **'txAfter'**
  String get txAfter;

  /// No description provided for @latI.
  ///
  /// In en, this message translates to:
  /// **'latI'**
  String get latI;

  /// No description provided for @lonI.
  ///
  /// In en, this message translates to:
  /// **'lonI'**
  String get lonI;

  /// No description provided for @altitude.
  ///
  /// In en, this message translates to:
  /// **'alt'**
  String get altitude;

  /// No description provided for @gpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'gpsAcc'**
  String get gpsAccuracy;

  /// No description provided for @sats.
  ///
  /// In en, this message translates to:
  /// **'sats'**
  String get sats;

  /// No description provided for @locationSource.
  ///
  /// In en, this message translates to:
  /// **'locSource'**
  String get locationSource;

  /// No description provided for @altitudeSource.
  ///
  /// In en, this message translates to:
  /// **'altSource'**
  String get altitudeSource;

  /// No description provided for @tsMillisAdj.
  ///
  /// In en, this message translates to:
  /// **'tsMillisAdj'**
  String get tsMillisAdj;

  /// No description provided for @altHae.
  ///
  /// In en, this message translates to:
  /// **'altHae'**
  String get altHae;

  /// No description provided for @altGeoSep.
  ///
  /// In en, this message translates to:
  /// **'altGeoSep'**
  String get altGeoSep;

  /// No description provided for @pDOP.
  ///
  /// In en, this message translates to:
  /// **'pDOP'**
  String get pDOP;

  /// No description provided for @hDOP.
  ///
  /// In en, this message translates to:
  /// **'hDOP'**
  String get hDOP;

  /// No description provided for @vDOP.
  ///
  /// In en, this message translates to:
  /// **'vDOP'**
  String get vDOP;

  /// No description provided for @groundSpeed.
  ///
  /// In en, this message translates to:
  /// **'groundSpeed'**
  String get groundSpeed;

  /// No description provided for @groundTrack.
  ///
  /// In en, this message translates to:
  /// **'groundTrack'**
  String get groundTrack;

  /// No description provided for @fixQuality.
  ///
  /// In en, this message translates to:
  /// **'fixQuality'**
  String get fixQuality;

  /// No description provided for @fixType.
  ///
  /// In en, this message translates to:
  /// **'fixType'**
  String get fixType;

  /// No description provided for @sensorId.
  ///
  /// In en, this message translates to:
  /// **'sensorId'**
  String get sensorId;

  /// No description provided for @nextUpdate.
  ///
  /// In en, this message translates to:
  /// **'nextUpdate'**
  String get nextUpdate;

  /// No description provided for @seqNumber.
  ///
  /// In en, this message translates to:
  /// **'seqNumber'**
  String get seqNumber;

  /// No description provided for @precisionBits.
  ///
  /// In en, this message translates to:
  /// **'precisionBits'**
  String get precisionBits;

  /// No description provided for @expire.
  ///
  /// In en, this message translates to:
  /// **'expire'**
  String get expire;

  /// No description provided for @lockedTo.
  ///
  /// In en, this message translates to:
  /// **'lockedTo'**
  String get lockedTo;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'desc'**
  String get description;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'icon'**
  String get icon;

  /// No description provided for @mac.
  ///
  /// In en, this message translates to:
  /// **'mac'**
  String get mac;

  /// No description provided for @isLicensed.
  ///
  /// In en, this message translates to:
  /// **'isLicensed'**
  String get isLicensed;

  /// No description provided for @isUnmessagable.
  ///
  /// In en, this message translates to:
  /// **'isUnmessagable'**
  String get isUnmessagable;

  /// No description provided for @variant.
  ///
  /// In en, this message translates to:
  /// **'variant'**
  String get variant;

  /// No description provided for @errorReason.
  ///
  /// In en, this message translates to:
  /// **'errorReason'**
  String get errorReason;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'requestId'**
  String get requestId;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'type'**
  String get type;

  /// No description provided for @gpioMask.
  ///
  /// In en, this message translates to:
  /// **'gpioMask'**
  String get gpioMask;

  /// No description provided for @gpioValue.
  ///
  /// In en, this message translates to:
  /// **'gpioValue'**
  String get gpioValue;

  /// No description provided for @nodeId.
  ///
  /// In en, this message translates to:
  /// **'nodeId'**
  String get nodeId;

  /// No description provided for @lastSentById.
  ///
  /// In en, this message translates to:
  /// **'lastSentById'**
  String get lastSentById;

  /// No description provided for @nodeBroadcastIntervalSecs.
  ///
  /// In en, this message translates to:
  /// **'nodeBroadcastIntervalSecs'**
  String get nodeBroadcastIntervalSecs;

  /// No description provided for @lastRxTime.
  ///
  /// In en, this message translates to:
  /// **'lastRxTime'**
  String get lastRxTime;

  /// No description provided for @broadcastIntSecs.
  ///
  /// In en, this message translates to:
  /// **'broadcastIntSecs'**
  String get broadcastIntSecs;

  /// No description provided for @routeLen.
  ///
  /// In en, this message translates to:
  /// **'routeLen'**
  String get routeLen;

  /// No description provided for @snrTowards.
  ///
  /// In en, this message translates to:
  /// **'snrTowards'**
  String get snrTowards;

  /// No description provided for @routeBackLen.
  ///
  /// In en, this message translates to:
  /// **'routeBackLen'**
  String get routeBackLen;

  /// No description provided for @snrBack.
  ///
  /// In en, this message translates to:
  /// **'snrBack'**
  String get snrBack;

  /// No description provided for @nonce.
  ///
  /// In en, this message translates to:
  /// **'nonce'**
  String get nonce;

  /// No description provided for @hash1.
  ///
  /// In en, this message translates to:
  /// **'hash1'**
  String get hash1;

  /// No description provided for @hash2.
  ///
  /// In en, this message translates to:
  /// **'hash2'**
  String get hash2;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'port'**
  String get port;

  /// No description provided for @bytes.
  ///
  /// In en, this message translates to:
  /// **'bytes'**
  String get bytes;

  /// No description provided for @relativeHumidity.
  ///
  /// In en, this message translates to:
  /// **'relativeHumidity'**
  String get relativeHumidity;

  /// No description provided for @barometricPressure.
  ///
  /// In en, this message translates to:
  /// **'barometricPressure'**
  String get barometricPressure;

  /// No description provided for @gasResistance.
  ///
  /// In en, this message translates to:
  /// **'gasResistance'**
  String get gasResistance;

  /// No description provided for @iaq.
  ///
  /// In en, this message translates to:
  /// **'iaq'**
  String get iaq;

  /// No description provided for @lux.
  ///
  /// In en, this message translates to:
  /// **'lux'**
  String get lux;

  /// No description provided for @whiteLux.
  ///
  /// In en, this message translates to:
  /// **'whiteLux'**
  String get whiteLux;

  /// No description provided for @irLux.
  ///
  /// In en, this message translates to:
  /// **'irLux'**
  String get irLux;

  /// No description provided for @uvLux.
  ///
  /// In en, this message translates to:
  /// **'uvLux'**
  String get uvLux;

  /// No description provided for @windDirection.
  ///
  /// In en, this message translates to:
  /// **'windDirection'**
  String get windDirection;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'windSpeed'**
  String get windSpeed;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'weight'**
  String get weight;

  /// No description provided for @windGust.
  ///
  /// In en, this message translates to:
  /// **'windGust'**
  String get windGust;

  /// No description provided for @windLull.
  ///
  /// In en, this message translates to:
  /// **'windLull'**
  String get windLull;

  /// No description provided for @pm10Standard.
  ///
  /// In en, this message translates to:
  /// **'pm10Standard'**
  String get pm10Standard;

  /// No description provided for @pm25Standard.
  ///
  /// In en, this message translates to:
  /// **'pm25Standard'**
  String get pm25Standard;

  /// No description provided for @pm100Standard.
  ///
  /// In en, this message translates to:
  /// **'pm100Standard'**
  String get pm100Standard;

  /// No description provided for @pm10Environmental.
  ///
  /// In en, this message translates to:
  /// **'pm10Environmental'**
  String get pm10Environmental;

  /// No description provided for @pm25Environmental.
  ///
  /// In en, this message translates to:
  /// **'pm25Environmental'**
  String get pm25Environmental;

  /// No description provided for @pm100Environmental.
  ///
  /// In en, this message translates to:
  /// **'pm100Environmental'**
  String get pm100Environmental;

  /// No description provided for @particles03um.
  ///
  /// In en, this message translates to:
  /// **'particles03um'**
  String get particles03um;

  /// No description provided for @particles05um.
  ///
  /// In en, this message translates to:
  /// **'particles05um'**
  String get particles05um;

  /// No description provided for @particles10um.
  ///
  /// In en, this message translates to:
  /// **'particles10um'**
  String get particles10um;

  /// No description provided for @particles25um.
  ///
  /// In en, this message translates to:
  /// **'particles25um'**
  String get particles25um;

  /// No description provided for @particles50um.
  ///
  /// In en, this message translates to:
  /// **'particles50um'**
  String get particles50um;

  /// No description provided for @particles100um.
  ///
  /// In en, this message translates to:
  /// **'particles100um'**
  String get particles100um;

  /// No description provided for @co2Temperature.
  ///
  /// In en, this message translates to:
  /// **'co2Temperature'**
  String get co2Temperature;

  /// No description provided for @co2Humidity.
  ///
  /// In en, this message translates to:
  /// **'co2Humidity'**
  String get co2Humidity;

  /// No description provided for @formaldehyde.
  ///
  /// In en, this message translates to:
  /// **'formFormaldehyde'**
  String get formaldehyde;

  /// No description provided for @formaldehydeHumidity.
  ///
  /// In en, this message translates to:
  /// **'formHumidity'**
  String get formaldehydeHumidity;

  /// No description provided for @formaldehydeTemperature.
  ///
  /// In en, this message translates to:
  /// **'formTemperature'**
  String get formaldehydeTemperature;

  /// No description provided for @pm40Standard.
  ///
  /// In en, this message translates to:
  /// **'pm40Standard'**
  String get pm40Standard;

  /// No description provided for @ch1Voltage.
  ///
  /// In en, this message translates to:
  /// **'ch1Voltage'**
  String get ch1Voltage;

  /// No description provided for @ch1Current.
  ///
  /// In en, this message translates to:
  /// **'ch1Current'**
  String get ch1Current;

  /// No description provided for @ch2Voltage.
  ///
  /// In en, this message translates to:
  /// **'ch2Voltage'**
  String get ch2Voltage;

  /// No description provided for @ch2Current.
  ///
  /// In en, this message translates to:
  /// **'ch2Current'**
  String get ch2Current;

  /// No description provided for @ch3Voltage.
  ///
  /// In en, this message translates to:
  /// **'ch3Voltage'**
  String get ch3Voltage;

  /// No description provided for @ch3Current.
  ///
  /// In en, this message translates to:
  /// **'ch3Current'**
  String get ch3Current;

  /// No description provided for @numPacketsTx.
  ///
  /// In en, this message translates to:
  /// **'numPacketsTx'**
  String get numPacketsTx;

  /// No description provided for @numPacketsRx.
  ///
  /// In en, this message translates to:
  /// **'numPacketsRx'**
  String get numPacketsRx;

  /// No description provided for @numPacketsRxBad.
  ///
  /// In en, this message translates to:
  /// **'numPacketsRxBad'**
  String get numPacketsRxBad;

  /// No description provided for @numOnlineNodes.
  ///
  /// In en, this message translates to:
  /// **'numOnlineNodes'**
  String get numOnlineNodes;

  /// No description provided for @heartBpm.
  ///
  /// In en, this message translates to:
  /// **'heartBpm'**
  String get heartBpm;

  /// No description provided for @spO2.
  ///
  /// In en, this message translates to:
  /// **'spO2'**
  String get spO2;

  /// No description provided for @freememBytes.
  ///
  /// In en, this message translates to:
  /// **'freememBytes'**
  String get freememBytes;

  /// No description provided for @diskfree1Bytes.
  ///
  /// In en, this message translates to:
  /// **'diskfree1Bytes'**
  String get diskfree1Bytes;

  /// No description provided for @diskfree2Bytes.
  ///
  /// In en, this message translates to:
  /// **'diskfree2Bytes'**
  String get diskfree2Bytes;

  /// No description provided for @diskfree3Bytes.
  ///
  /// In en, this message translates to:
  /// **'diskfree3Bytes'**
  String get diskfree3Bytes;

  /// No description provided for @load1.
  ///
  /// In en, this message translates to:
  /// **'load1'**
  String get load1;

  /// No description provided for @load5.
  ///
  /// In en, this message translates to:
  /// **'load5'**
  String get load5;

  /// No description provided for @load15.
  ///
  /// In en, this message translates to:
  /// **'load15'**
  String get load15;

  /// No description provided for @userString.
  ///
  /// In en, this message translates to:
  /// **'userString'**
  String get userString;

  /// No description provided for @wifiPsk.
  ///
  /// In en, this message translates to:
  /// **'wifiPsk'**
  String get wifiPsk;

  /// No description provided for @ntpServer.
  ///
  /// In en, this message translates to:
  /// **'ntpServer'**
  String get ntpServer;

  /// No description provided for @ethEnabled.
  ///
  /// In en, this message translates to:
  /// **'ethEnabled'**
  String get ethEnabled;

  /// No description provided for @addressMode.
  ///
  /// In en, this message translates to:
  /// **'addressMode'**
  String get addressMode;

  /// No description provided for @rsyslogServer.
  ///
  /// In en, this message translates to:
  /// **'rsyslogServer'**
  String get rsyslogServer;

  /// No description provided for @enabledProtocols.
  ///
  /// In en, this message translates to:
  /// **'enabledProtocols'**
  String get enabledProtocols;

  /// No description provided for @ipv6Enabled.
  ///
  /// In en, this message translates to:
  /// **'ipv6Enabled'**
  String get ipv6Enabled;

  /// No description provided for @ip.
  ///
  /// In en, this message translates to:
  /// **'ip'**
  String get ip;

  /// No description provided for @gateway.
  ///
  /// In en, this message translates to:
  /// **'gateway'**
  String get gateway;

  /// No description provided for @subnet.
  ///
  /// In en, this message translates to:
  /// **'subnet'**
  String get subnet;

  /// No description provided for @dns.
  ///
  /// In en, this message translates to:
  /// **'dns'**
  String get dns;

  /// No description provided for @displaymode.
  ///
  /// In en, this message translates to:
  /// **'displaymode'**
  String get displaymode;

  /// No description provided for @usePreset.
  ///
  /// In en, this message translates to:
  /// **'usePreset'**
  String get usePreset;

  /// No description provided for @bandwidth.
  ///
  /// In en, this message translates to:
  /// **'bandwidth'**
  String get bandwidth;

  /// No description provided for @spreadFactor.
  ///
  /// In en, this message translates to:
  /// **'spreadFactor'**
  String get spreadFactor;

  /// No description provided for @codingRate.
  ///
  /// In en, this message translates to:
  /// **'codingRate'**
  String get codingRate;

  /// No description provided for @frequencyOffset.
  ///
  /// In en, this message translates to:
  /// **'frequencyOffset'**
  String get frequencyOffset;

  /// No description provided for @channelNum.
  ///
  /// In en, this message translates to:
  /// **'channelNum'**
  String get channelNum;

  /// No description provided for @overrideDutyCycle.
  ///
  /// In en, this message translates to:
  /// **'overrideDutyCycle'**
  String get overrideDutyCycle;

  /// No description provided for @sx126xRxBoostedGain.
  ///
  /// In en, this message translates to:
  /// **'sx126xRxBoostedGain'**
  String get sx126xRxBoostedGain;

  /// No description provided for @overrideFrequency.
  ///
  /// In en, this message translates to:
  /// **'overrideFrequency'**
  String get overrideFrequency;

  /// No description provided for @paFanDisabled.
  ///
  /// In en, this message translates to:
  /// **'paFanDisabled'**
  String get paFanDisabled;

  /// No description provided for @ignoreIncoming.
  ///
  /// In en, this message translates to:
  /// **'ignoreIncoming'**
  String get ignoreIncoming;

  /// No description provided for @ignoreMqtt.
  ///
  /// In en, this message translates to:
  /// **'ignoreMqtt'**
  String get ignoreMqtt;

  /// No description provided for @configOkToMqtt.
  ///
  /// In en, this message translates to:
  /// **'configOkToMqtt'**
  String get configOkToMqtt;

  /// No description provided for @adminKeyCount.
  ///
  /// In en, this message translates to:
  /// **'adminKeyCount'**
  String get adminKeyCount;

  /// No description provided for @encryptionEnabled.
  ///
  /// In en, this message translates to:
  /// **'encryptionEnabled'**
  String get encryptionEnabled;

  /// No description provided for @jsonEnabled.
  ///
  /// In en, this message translates to:
  /// **'jsonEnabled'**
  String get jsonEnabled;

  /// No description provided for @tlsEnabled.
  ///
  /// In en, this message translates to:
  /// **'tlsEnabled'**
  String get tlsEnabled;

  /// No description provided for @root.
  ///
  /// In en, this message translates to:
  /// **'root'**
  String get root;

  /// No description provided for @proxyToClientEnabled.
  ///
  /// In en, this message translates to:
  /// **'proxyToClientEnabled'**
  String get proxyToClientEnabled;

  /// No description provided for @mapReportingEnabled.
  ///
  /// In en, this message translates to:
  /// **'mapReportingEnabled'**
  String get mapReportingEnabled;

  /// No description provided for @publishIntervalSecs.
  ///
  /// In en, this message translates to:
  /// **'publishIntervalSecs'**
  String get publishIntervalSecs;

  /// No description provided for @positionPrecision.
  ///
  /// In en, this message translates to:
  /// **'positionPrecision'**
  String get positionPrecision;

  /// No description provided for @shouldReportLocation.
  ///
  /// In en, this message translates to:
  /// **'shouldReportLocation'**
  String get shouldReportLocation;

  /// No description provided for @environmentMeasurementEnabled.
  ///
  /// In en, this message translates to:
  /// **'environmentMeasurementEnabled'**
  String get environmentMeasurementEnabled;

  /// No description provided for @environmentScreenEnabled.
  ///
  /// In en, this message translates to:
  /// **'environmentScreenEnabled'**
  String get environmentScreenEnabled;

  /// No description provided for @environmentDisplayFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'environmentDisplayFahrenheit'**
  String get environmentDisplayFahrenheit;

  /// No description provided for @airQualityEnabled.
  ///
  /// In en, this message translates to:
  /// **'airQualityEnabled'**
  String get airQualityEnabled;

  /// No description provided for @powerMeasurementEnabled.
  ///
  /// In en, this message translates to:
  /// **'powerMeasurementEnabled'**
  String get powerMeasurementEnabled;

  /// No description provided for @powerScreenEnabled.
  ///
  /// In en, this message translates to:
  /// **'powerScreenEnabled'**
  String get powerScreenEnabled;

  /// No description provided for @healthMeasurementEnabled.
  ///
  /// In en, this message translates to:
  /// **'healthMeasurementEnabled'**
  String get healthMeasurementEnabled;

  /// No description provided for @healthScreenEnabled.
  ///
  /// In en, this message translates to:
  /// **'healthScreenEnabled'**
  String get healthScreenEnabled;

  /// No description provided for @deviceTelemetryEnabled.
  ///
  /// In en, this message translates to:
  /// **'deviceTelemetryEnabled'**
  String get deviceTelemetryEnabled;

  /// No description provided for @overrideConsoleSerialPort.
  ///
  /// In en, this message translates to:
  /// **'overrideConsoleSerialPort'**
  String get overrideConsoleSerialPort;

  /// No description provided for @alertMessageVibra.
  ///
  /// In en, this message translates to:
  /// **'alertMessageVibra'**
  String get alertMessageVibra;

  /// No description provided for @alertMessageBuzzer.
  ///
  /// In en, this message translates to:
  /// **'alertMessageBuzzer'**
  String get alertMessageBuzzer;

  /// No description provided for @alertBellVibra.
  ///
  /// In en, this message translates to:
  /// **'alertBellVibra'**
  String get alertBellVibra;

  /// No description provided for @alertBellBuzzer.
  ///
  /// In en, this message translates to:
  /// **'alertBellBuzzer'**
  String get alertBellBuzzer;

  /// No description provided for @availablePinsCount.
  ///
  /// In en, this message translates to:
  /// **'availablePinsCount'**
  String get availablePinsCount;

  /// No description provided for @gpioPin.
  ///
  /// In en, this message translates to:
  /// **'gpioPin'**
  String get gpioPin;

  /// No description provided for @inputbrokerPinA.
  ///
  /// In en, this message translates to:
  /// **'inputbrokerPinA'**
  String get inputbrokerPinA;

  /// No description provided for @inputbrokerPinB.
  ///
  /// In en, this message translates to:
  /// **'inputbrokerPinB'**
  String get inputbrokerPinB;

  /// No description provided for @inputbrokerPinPress.
  ///
  /// In en, this message translates to:
  /// **'inputbrokerPinPress'**
  String get inputbrokerPinPress;

  /// No description provided for @inputbrokerEventCw.
  ///
  /// In en, this message translates to:
  /// **'inputbrokerEventCw'**
  String get inputbrokerEventCw;

  /// No description provided for @inputbrokerEventCcw.
  ///
  /// In en, this message translates to:
  /// **'inputbrokerEventCcw'**
  String get inputbrokerEventCcw;

  /// No description provided for @inputbrokerEventPress.
  ///
  /// In en, this message translates to:
  /// **'inputbrokerEventPress'**
  String get inputbrokerEventPress;

  /// No description provided for @updown1Enabled.
  ///
  /// In en, this message translates to:
  /// **'updown1Enabled'**
  String get updown1Enabled;

  /// No description provided for @enabledDeprecated.
  ///
  /// In en, this message translates to:
  /// **'enabled(deprecated)'**
  String get enabledDeprecated;

  /// No description provided for @minimumBroadcastSecs.
  ///
  /// In en, this message translates to:
  /// **'minimumBroadcastSecs'**
  String get minimumBroadcastSecs;

  /// No description provided for @detectionTriggerType.
  ///
  /// In en, this message translates to:
  /// **'detectionTriggerType'**
  String get detectionTriggerType;

  /// No description provided for @lateFallbackEnabled.
  ///
  /// In en, this message translates to:
  /// **'lateFallbackEnabled'**
  String get lateFallbackEnabled;

  /// No description provided for @fallbackTailPercent.
  ///
  /// In en, this message translates to:
  /// **'fallbackTailPercent'**
  String get fallbackTailPercent;

  /// No description provided for @milestonesEnabled.
  ///
  /// In en, this message translates to:
  /// **'milestonesEnabled'**
  String get milestonesEnabled;

  /// No description provided for @perDestMinSpacingMs.
  ///
  /// In en, this message translates to:
  /// **'perDestMinSpacingMs'**
  String get perDestMinSpacingMs;

  /// No description provided for @maxActiveDm.
  ///
  /// In en, this message translates to:
  /// **'maxActiveDm'**
  String get maxActiveDm;

  /// No description provided for @probeFwplusNearDeadline.
  ///
  /// In en, this message translates to:
  /// **'probeFwplusNearDeadline'**
  String get probeFwplusNearDeadline;

  /// No description provided for @allowedPorts.
  ///
  /// In en, this message translates to:
  /// **'allowedPorts'**
  String get allowedPorts;

  /// No description provided for @localStatsOverMeshEnabled.
  ///
  /// In en, this message translates to:
  /// **'localStatsOverMeshEnabled'**
  String get localStatsOverMeshEnabled;

  /// No description provided for @localStatsExtendedOverMeshEnabled.
  ///
  /// In en, this message translates to:
  /// **'localStatsExtendedOverMeshEnabled'**
  String get localStatsExtendedOverMeshEnabled;

  /// No description provided for @additionalChutil.
  ///
  /// In en, this message translates to:
  /// **'additionalChutil'**
  String get additionalChutil;

  /// No description provided for @additionalTxutil.
  ///
  /// In en, this message translates to:
  /// **'additionalTxutil'**
  String get additionalTxutil;

  /// No description provided for @additionalPoliteChannelPercent.
  ///
  /// In en, this message translates to:
  /// **'additionalPoliteChannelPercent'**
  String get additionalPoliteChannelPercent;

  /// No description provided for @additionalPoliteDutyCyclePercent.
  ///
  /// In en, this message translates to:
  /// **'additionalPoliteDutyCyclePercent'**
  String get additionalPoliteDutyCyclePercent;

  /// No description provided for @currentTxUtilLimit.
  ///
  /// In en, this message translates to:
  /// **'currentTxUtilLimit'**
  String get currentTxUtilLimit;

  /// No description provided for @currentMaxChannelUtilPercent.
  ///
  /// In en, this message translates to:
  /// **'currentMaxChannelUtilPercent'**
  String get currentMaxChannelUtilPercent;

  /// No description provided for @currentPoliteChannelUtilPercent.
  ///
  /// In en, this message translates to:
  /// **'currentPoliteChannelUtilPercent'**
  String get currentPoliteChannelUtilPercent;

  /// No description provided for @currentPoliteDutyCyclePercent.
  ///
  /// In en, this message translates to:
  /// **'currentPoliteDutyCyclePercent'**
  String get currentPoliteDutyCyclePercent;

  /// No description provided for @autoRedirectTargetNodeId.
  ///
  /// In en, this message translates to:
  /// **'autoRedirectTargetNodeId'**
  String get autoRedirectTargetNodeId;

  /// No description provided for @telemetryLimiterEnabled.
  ///
  /// In en, this message translates to:
  /// **'telemetryLimiterEnabled'**
  String get telemetryLimiterEnabled;

  /// No description provided for @telemetryLimiterPacketsPerMinute.
  ///
  /// In en, this message translates to:
  /// **'telemetryLimiterPacketsPerMinute'**
  String get telemetryLimiterPacketsPerMinute;

  /// No description provided for @telemetryLimiterAutoChanutilEnabled.
  ///
  /// In en, this message translates to:
  /// **'telemetryLimiterAutoChanutilEnabled'**
  String get telemetryLimiterAutoChanutilEnabled;

  /// No description provided for @telemetryLimiterAutoChanutilThreshold.
  ///
  /// In en, this message translates to:
  /// **'telemetryLimiterAutoChanutilThreshold'**
  String get telemetryLimiterAutoChanutilThreshold;

  /// No description provided for @positionLimiterEnabled.
  ///
  /// In en, this message translates to:
  /// **'positionLimiterEnabled'**
  String get positionLimiterEnabled;

  /// No description provided for @positionLimiterTimeMinutesThreshold.
  ///
  /// In en, this message translates to:
  /// **'positionLimiterTimeMinutesThreshold'**
  String get positionLimiterTimeMinutesThreshold;

  /// No description provided for @opportunisticFloodingEnabled.
  ///
  /// In en, this message translates to:
  /// **'opportunisticFloodingEnabled'**
  String get opportunisticFloodingEnabled;

  /// No description provided for @opportunisticBaseDelayMs.
  ///
  /// In en, this message translates to:
  /// **'opportunisticBaseDelayMs'**
  String get opportunisticBaseDelayMs;

  /// No description provided for @opportunisticHopDelayMs.
  ///
  /// In en, this message translates to:
  /// **'opportunisticHopDelayMs'**
  String get opportunisticHopDelayMs;

  /// No description provided for @opportunisticSnrGainMs.
  ///
  /// In en, this message translates to:
  /// **'opportunisticSnrGainMs'**
  String get opportunisticSnrGainMs;

  /// No description provided for @opportunisticJitterMs.
  ///
  /// In en, this message translates to:
  /// **'opportunisticJitterMs'**
  String get opportunisticJitterMs;

  /// No description provided for @opportunisticCancelOnFirstHear.
  ///
  /// In en, this message translates to:
  /// **'opportunisticCancelOnFirstHear'**
  String get opportunisticCancelOnFirstHear;

  /// No description provided for @opportunisticAuto.
  ///
  /// In en, this message translates to:
  /// **'opportunisticAuto'**
  String get opportunisticAuto;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'version'**
  String get version;

  /// No description provided for @screenBrightness.
  ///
  /// In en, this message translates to:
  /// **'screenBrightness'**
  String get screenBrightness;

  /// No description provided for @screenTimeout.
  ///
  /// In en, this message translates to:
  /// **'screenTimeout'**
  String get screenTimeout;

  /// No description provided for @screenLock.
  ///
  /// In en, this message translates to:
  /// **'screenLock'**
  String get screenLock;

  /// No description provided for @settingsLock.
  ///
  /// In en, this message translates to:
  /// **'settingsLock'**
  String get settingsLock;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'pinCode'**
  String get pinCode;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get theme;

  /// No description provided for @alertEnabled.
  ///
  /// In en, this message translates to:
  /// **'alertEnabled'**
  String get alertEnabled;

  /// No description provided for @bannerEnabled.
  ///
  /// In en, this message translates to:
  /// **'bannerEnabled'**
  String get bannerEnabled;

  /// No description provided for @ringToneId.
  ///
  /// In en, this message translates to:
  /// **'ringToneId'**
  String get ringToneId;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'language'**
  String get language;

  /// No description provided for @compassMode.
  ///
  /// In en, this message translates to:
  /// **'compassMode'**
  String get compassMode;

  /// No description provided for @screenRgbColor.
  ///
  /// In en, this message translates to:
  /// **'screenRgbColor'**
  String get screenRgbColor;

  /// No description provided for @isClockfaceAnalog.
  ///
  /// In en, this message translates to:
  /// **'isClockfaceAnalog'**
  String get isClockfaceAnalog;

  /// No description provided for @gpsFormat.
  ///
  /// In en, this message translates to:
  /// **'gpsFormat'**
  String get gpsFormat;

  /// No description provided for @calibrationDataLen.
  ///
  /// In en, this message translates to:
  /// **'calibrationDataLen'**
  String get calibrationDataLen;

  /// No description provided for @filterEnabled.
  ///
  /// In en, this message translates to:
  /// **'filterEnabled'**
  String get filterEnabled;

  /// No description provided for @minSnr.
  ///
  /// In en, this message translates to:
  /// **'minSnr'**
  String get minSnr;

  /// No description provided for @hideIgnoredNodes.
  ///
  /// In en, this message translates to:
  /// **'hideIgnoredNodes'**
  String get hideIgnoredNodes;

  /// No description provided for @highlightEnabled.
  ///
  /// In en, this message translates to:
  /// **'highlightEnabled'**
  String get highlightEnabled;

  /// No description provided for @zoom.
  ///
  /// In en, this message translates to:
  /// **'zoom'**
  String get zoom;

  /// No description provided for @centerLatI.
  ///
  /// In en, this message translates to:
  /// **'centerLatI'**
  String get centerLatI;

  /// No description provided for @centerLonI.
  ///
  /// In en, this message translates to:
  /// **'centerLonI'**
  String get centerLonI;

  /// No description provided for @followMe.
  ///
  /// In en, this message translates to:
  /// **'followMe'**
  String get followMe;

  /// No description provided for @psk.
  ///
  /// In en, this message translates to:
  /// **'psk'**
  String get psk;

  /// No description provided for @uplinkEnabled.
  ///
  /// In en, this message translates to:
  /// **'uplinkEnabled'**
  String get uplinkEnabled;

  /// No description provided for @downlinkEnabled.
  ///
  /// In en, this message translates to:
  /// **'downlinkEnabled'**
  String get downlinkEnabled;

  /// No description provided for @ownerEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Owner'**
  String get ownerEditTitle;

  /// No description provided for @ownerLongName.
  ///
  /// In en, this message translates to:
  /// **'Long Name'**
  String get ownerLongName;

  /// No description provided for @ownerShortName.
  ///
  /// In en, this message translates to:
  /// **'Short Name'**
  String get ownerShortName;

  /// No description provided for @ownerLongNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kevin Hester'**
  String get ownerLongNameHint;

  /// No description provided for @ownerShortNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. KH'**
  String get ownerShortNameHint;

  /// No description provided for @ownerLongNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Full name for this device'**
  String get ownerLongNameHelper;

  /// No description provided for @ownerShortNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Short name (max 4 characters)'**
  String get ownerShortNameHelper;

  /// No description provided for @ownerEditAtLeastOneName.
  ///
  /// In en, this message translates to:
  /// **'Please provide at least one name (long or short)'**
  String get ownerEditAtLeastOneName;

  /// No description provided for @ownerUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Owner info updated successfully'**
  String get ownerUpdateSuccess;

  /// No description provided for @ownerUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update owner info: {error}'**
  String ownerUpdateFailed(Object error);

  /// No description provided for @configHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration Help'**
  String get configHelpTitle;

  /// No description provided for @readMoreDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Read more in documentation'**
  String get readMoreDocumentation;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @deviceRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get deviceRoleLabel;

  /// No description provided for @serialEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Serial Enabled'**
  String get serialEnabledLabel;

  /// No description provided for @serialEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deprecated upstream'**
  String get serialEnabledSubtitle;

  /// No description provided for @buttonGpioLabel.
  ///
  /// In en, this message translates to:
  /// **'Button GPIO'**
  String get buttonGpioLabel;

  /// No description provided for @buzzerGpioLabel.
  ///
  /// In en, this message translates to:
  /// **'Buzzer GPIO'**
  String get buzzerGpioLabel;

  /// No description provided for @rebroadcastModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Rebroadcast Mode'**
  String get rebroadcastModeLabel;

  /// No description provided for @nodeInfoBroadcastIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Node Info Broadcast Interval (seconds)'**
  String get nodeInfoBroadcastIntervalLabel;

  /// No description provided for @nodeInfoBroadcastIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'How often to broadcast node info'**
  String get nodeInfoBroadcastIntervalHint;

  /// No description provided for @doubleTapAsButtonPressLabel.
  ///
  /// In en, this message translates to:
  /// **'Double Tap as Button Press'**
  String get doubleTapAsButtonPressLabel;

  /// No description provided for @isManagedLabel.
  ///
  /// In en, this message translates to:
  /// **'Is Managed'**
  String get isManagedLabel;

  /// No description provided for @disableTripleClickLabel.
  ///
  /// In en, this message translates to:
  /// **'Disable Triple Click'**
  String get disableTripleClickLabel;

  /// No description provided for @timezoneDefinitionLabel.
  ///
  /// In en, this message translates to:
  /// **'Timezone Definition'**
  String get timezoneDefinitionLabel;

  /// No description provided for @timezoneDefinitionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., PST8PDT,M3.2.0,M11.1.0'**
  String get timezoneDefinitionHint;

  /// No description provided for @ledHeartbeatDisabledLabel.
  ///
  /// In en, this message translates to:
  /// **'LED Heartbeat Disabled'**
  String get ledHeartbeatDisabledLabel;

  /// No description provided for @buzzerModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Buzzer Mode'**
  String get buzzerModeLabel;

  /// No description provided for @positionBroadcastIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Position Broadcast Interval (seconds)'**
  String get positionBroadcastIntervalLabel;

  /// No description provided for @smartPositionBroadcastLabel.
  ///
  /// In en, this message translates to:
  /// **'Smart Position Broadcast'**
  String get smartPositionBroadcastLabel;

  /// No description provided for @fixedPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed Position'**
  String get fixedPositionLabel;

  /// No description provided for @gpsEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Enabled'**
  String get gpsEnabledLabel;

  /// No description provided for @gpsUpdateIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Update Interval (seconds)'**
  String get gpsUpdateIntervalLabel;

  /// No description provided for @gpsAttemptTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Attempt Time (seconds)'**
  String get gpsAttemptTimeLabel;

  /// No description provided for @positionFlagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Position Flags'**
  String get positionFlagsLabel;

  /// No description provided for @rxGpioLabel.
  ///
  /// In en, this message translates to:
  /// **'RX GPIO'**
  String get rxGpioLabel;

  /// No description provided for @txGpioLabel.
  ///
  /// In en, this message translates to:
  /// **'TX GPIO'**
  String get txGpioLabel;

  /// No description provided for @smartBroadcastMinDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Smart Broadcast Min Distance'**
  String get smartBroadcastMinDistanceLabel;

  /// No description provided for @smartBroadcastMinIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Smart Broadcast Min Interval (seconds)'**
  String get smartBroadcastMinIntervalLabel;

  /// No description provided for @gpsEnableGpioLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Enable GPIO'**
  String get gpsEnableGpioLabel;

  /// No description provided for @gpsModeLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Mode'**
  String get gpsModeLabel;
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
