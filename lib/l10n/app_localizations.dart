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
