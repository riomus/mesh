// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Mesh BLE Skaner';

  @override
  String get nearbyDevicesTitle => 'Najbliższe urządzenia Bluetooth';

  @override
  String get scan => 'Skanuj';

  @override
  String get stop => 'Zatrzymaj';

  @override
  String get toggleThemeTooltip => 'Przełącz motyw';

  @override
  String get languageTooltip => 'Zmień język';

  @override
  String get general => 'Ogólne';

  @override
  String get identifier => 'Identyfikator';

  @override
  String get platformName => 'Nazwa platformy';

  @override
  String get signalRssi => 'Sygnał (RSSI)';

  @override
  String get advertisement => 'Reklama';

  @override
  String get advertisedName => 'Nazwa z reklamy';

  @override
  String get connectable => 'Możliwość połączenia';

  @override
  String get connect => 'Połącz';

  @override
  String get disconnect => 'Rozłącz';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get service => 'Usługa';

  @override
  String get serviceUuids => 'UUID usług';

  @override
  String serviceUuidsWithCount(Object count) {
    return 'UUID usług ($count)';
  }

  @override
  String get manufacturerData => 'Dane producenta';

  @override
  String manufacturerDataWithCount(Object count) {
    return 'Dane producenta ($count)';
  }

  @override
  String get serviceData => 'Dane usług';

  @override
  String serviceDataWithCount(Object count) {
    return 'Dane usług ($count)';
  }

  @override
  String get noneAdvertised => 'Brak danych';

  @override
  String get bluetoothOn => 'Bluetooth jest WŁĄCZONY';

  @override
  String get bluetoothOff => 'Bluetooth jest WYŁĄCZONY';

  @override
  String bluetoothState(Object state) {
    return 'Stan Bluetooth: $state';
  }

  @override
  String get webNote =>
      'W wersji Web po kliknięciu Skanuj pojawia się okno wyboru urządzenia (wymagany HTTPS).';

  @override
  String get tapScanToDiscover =>
      'Kliknij Skanuj, aby wykryć pobliskie urządzenia Bluetooth';

  @override
  String get unknown => 'nieznane';

  @override
  String get searchHint => 'Szukaj urządzeń po nazwie lub ID';

  @override
  String get loraOnlyFilterLabel => 'Tylko LoRa';

  @override
  String get meshtasticLabel => 'Meshtastic';

  @override
  String get settingsButtonLabel => 'Ustawienia';

  @override
  String get nodesTitle => 'Węzły';

  @override
  String get tabList => 'Lista';

  @override
  String get tabMap => 'Mapa';

  @override
  String get logs => 'Logi';

  @override
  String get liveEvents => 'Zdarzenia na żywo';

  @override
  String get serviceAvailable => 'Usługa dostępna';

  @override
  String get statusConnected => 'Połączono';

  @override
  String get statusConnecting => 'Łączenie...';

  @override
  String get statusDisconnected => 'Rozłączono';

  @override
  String get mapRefPrefix => 'Ref';

  @override
  String get clearRef => 'Wyczyść ref';

  @override
  String get fitBounds => 'Dopasuj widok';

  @override
  String get center => 'Wyśrodkuj';

  @override
  String get useAsRef => 'Użyj jako ref';

  @override
  String get details => 'Szczegóły';

  @override
  String get copyCoords => 'Kopiuj współrz.';

  @override
  String get coordsCopied => 'Skopiowano współrzędne';

  @override
  String get noNodesWithLocation =>
      'Brak węzłów z lokalizacją.\nPrzytrzymaj na mapie aby ustawić własny punkt odniesienia.';

  @override
  String customRefSet(Object lat, Object lon) {
    return 'Ustawiono punkt odniesienia: $lat, $lon';
  }

  @override
  String get coordinates => 'Współrzędne';

  @override
  String get searchNodes => 'Szukaj węzłów';

  @override
  String get findByNameOrId => 'Szukaj po nazwie lub ID ...';

  @override
  String get clear => 'Wyczyść';

  @override
  String get addFilter => 'Dodaj filtr';

  @override
  String get sorting => 'Sortowanie';

  @override
  String get clearFilters => 'Wyczyść filtry';

  @override
  String get favoritesFirst => 'Ulubione na początku';

  @override
  String get distance => 'Dystans';

  @override
  String get snr => 'SNR';

  @override
  String get lastSeen => 'Ostatnio widziany';

  @override
  String get role => 'Rola';

  @override
  String get name => 'Nazwa';

  @override
  String get hops => 'skoki';

  @override
  String get via => 'przez';

  @override
  String get addFilterTitle => 'Dodaj filtr';

  @override
  String get key => 'Klucz';

  @override
  String get exact => 'Dokładnie';

  @override
  String get regex => 'Regex';

  @override
  String hasValueFor(Object key) {
    return 'ma $key';
  }

  @override
  String get customValueOptional => 'Własna wartość (opcjonalnie)';

  @override
  String get regexCaseInsensitive => 'Regex (bez rozróżniania wielkości liter)';

  @override
  String get resetToDefault => 'Przywróć domyślne';

  @override
  String get useSourceAsRef => 'Użyj urządzenia źródłowego jako ref';

  @override
  String get tipSetCustomRef =>
      'Wskazówka: ustaw ref przytrzymując na zakładce Mapa';

  @override
  String get cancel => 'Anuluj';

  @override
  String get addAction => 'Dodaj';

  @override
  String get apply => 'Zastosuj';

  @override
  String get searchEvents => 'Szukaj zdarzeń';

  @override
  String get searchInSummaryOrTags => 'Szukaj w podsumowaniu lub tagach';

  @override
  String get battery => 'Bateria';

  @override
  String get charging => 'ładowanie';

  @override
  String get location => 'Lokalizacja';

  @override
  String get locationUnavailable => 'Brak lokalizacji dla tego węzła';

  @override
  String get sourceDevice => 'Urządzenie źródłowe';

  @override
  String get viaMqtt => 'przez MQTT';

  @override
  String get connectFailed => 'Połączenie nieudane';

  @override
  String get meshtasticConnectFailed => 'Połączenie z Meshtastic nieudane';

  @override
  String get deviceError => 'Błąd urządzenia';

  @override
  String get eventsTitle => 'Zdarzenia';

  @override
  String failedToShareEvents(Object error) {
    return 'Nie udało się udostępnić zdarzeń: $error';
  }

  @override
  String get noEventsYet => 'Brak zdarzeń';

  @override
  String get eventDetailsTitle => 'Szczegóły zdarzenia';

  @override
  String get timestamp => 'Znacznik czasu';

  @override
  String get summary => 'Podsumowanie';

  @override
  String get tags => 'Tagi';

  @override
  String get payload => 'Ładunek';

  @override
  String get waypoint => 'Punkt trasy';

  @override
  String get user => 'Użytkownik';

  @override
  String get routing => 'Routing';

  @override
  String get routingPayload => 'Ładunek routingu';

  @override
  String get admin => 'Administrator';

  @override
  String get remoteHardware => 'Zdalny sprzęt';

  @override
  String get neighborInfo => 'Informacje o sąsiadach';

  @override
  String get neighbors => 'Sąsiedzi';

  @override
  String get storeForward => 'Przechowaj i przekaż';

  @override
  String get telemetry => 'Telemetria';

  @override
  String get paxcounter => 'Paxcounter';

  @override
  String get traceroute => 'Traceroute';

  @override
  String get keyVerification => 'Weryfikacja klucza';

  @override
  String get rawPayload => 'Surowy ładunek';

  @override
  String get fullscreen => 'Pełny ekran';

  @override
  String get close => 'Zamknij';

  @override
  String get shareEvents => 'Udostępnij zdarzenia (JSON)';

  @override
  String get eventsExport => 'Eksport zdarzeń';

  @override
  String get shareLogs => 'Udostępnij logi (JSON)';

  @override
  String get logsExport => 'Eksport logów';

  @override
  String get addFilters => 'Dodaj filtry';

  @override
  String get resume => 'Wznów';

  @override
  String get pause => 'Pauza';

  @override
  String get clearAll => 'Wyczyść';

  @override
  String failedToShareLogs(Object error) {
    return 'Nie udało się udostępnić logów: $error';
  }

  @override
  String get mapAttribution => '© Współtwórcy OpenStreetMap';

  @override
  String nodeIdHex(Object hex) {
    return 'ID: 0x$hex';
  }

  @override
  String nodeTitleHex(Object hex) {
    return 'Węzeł 0x$hex';
  }

  @override
  String get roleLabel => 'Rola';

  @override
  String get hopsAway => 'Skoki';

  @override
  String get snrLabel => 'SNR';

  @override
  String get lastSeenLabel => 'Ostatnio widziany';

  @override
  String get chat => 'Czat';

  @override
  String get typeMessage => 'Wpisz wiadomość...';

  @override
  String get messageTooLong => 'Wiadomość za długa';

  @override
  String sendFailed(Object error) {
    return 'Nie udało się wysłać: $error';
  }

  @override
  String get buildPrefix => 'Wersja: ';

  @override
  String get builtPrefix => 'Zbudowano: ';

  @override
  String agoSeconds(Object seconds) {
    return '${seconds}s temu';
  }

  @override
  String agoMinutes(Object minutes) {
    return '${minutes}m temu';
  }

  @override
  String agoHours(Object hours) {
    return '${hours}g temu';
  }

  @override
  String agoDays(Object days) {
    return '${days}d temu';
  }

  @override
  String get sortAsc => 'ROS';

  @override
  String get sortDesc => 'MAL';

  @override
  String get unknownState => 'Nieznany';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageFollowSystem => 'Zgodnie z systemem';

  @override
  String languageAppLanguage(Object language) {
    return 'Język aplikacji: $language';
  }

  @override
  String get eventDetails => 'Szczegóły zdarzenia';

  @override
  String get myInfo => 'MyInfo';

  @override
  String get config => 'Konfiguracja';

  @override
  String get configComplete => 'Konfiguracja zakończona';

  @override
  String get rebooted => 'Zrestartowano';

  @override
  String get moduleConfig => 'Konfiguracja modułu';

  @override
  String get channel => 'Kanał';

  @override
  String get channels => 'Kanały';

  @override
  String get queueStatus => 'Stan kolejki';

  @override
  String get deviceMetadata => 'Metadane urządzenia';

  @override
  String get mqttProxy => 'Proxy MQTT';

  @override
  String get fileInfo => 'Informacje o pliku';

  @override
  String get clientNotification => 'Powiadomienie klienta';

  @override
  String get deviceUiConfig => 'Konfiguracja UI urządzenia';

  @override
  String get logRecord => 'Wpis logu';

  @override
  String get packet => 'Pakiet';

  @override
  String get textPayload => 'Ładunek tekstowy';

  @override
  String get position => 'Pozycja';

  @override
  String rawPayloadDetails(Object bytes, Object id, Object name) {
    return 'Surowy ładunek ($name:$id, $bytes bajtów)';
  }

  @override
  String get encryptedUnknownPayload => 'Zaszyfrowany/nieznany ładunek';

  @override
  String get configUpdate => 'Aktualizacja konfiguracji';

  @override
  String get configStreamComplete => 'Strumień konfiguracji zakończony';

  @override
  String get deviceReportedReboot => 'Urządzenie zgłosiło restart';

  @override
  String get noReboot => 'Brak restartu';

  @override
  String get channelUpdate => 'Aktualizacja kanału';

  @override
  String get routingMessage => 'Wiadomość routingu';

  @override
  String get adminMessage => 'Wiadomość admina';

  @override
  String get positionUpdate => 'Aktualizacja pozycji';

  @override
  String get userInfo => 'Informacje o użytkowniku';

  @override
  String remoteHw(Object mask, Object type, Object value) {
    return 'Zdalny sprzęt: $type maska=$mask wartość=$value';
  }

  @override
  String storeForwardVariant(Object variant) {
    return 'Przechowaj i przekaż ($variant)';
  }

  @override
  String telemetryVariant(Object variant) {
    return 'Telemetria ($variant)';
  }

  @override
  String get device => 'Urządzenie';

  @override
  String get serial => 'Port szeregowy';

  @override
  String get rangeTest => 'Test zasięgu';

  @override
  String get externalNotification => 'Powiadomienie zewnętrzne';

  @override
  String get audio => 'Audio';

  @override
  String get cannedMessage => 'Wiadomość szablonowa';

  @override
  String get ambientLighting => 'Oświetlenie otoczenia';

  @override
  String get detectionSensor => 'Czujnik wykrywania';

  @override
  String get dtnOverlay => 'Nakładka DTN';

  @override
  String get broadcastAssist => 'Asystent rozgłaszania';

  @override
  String get nodeFilter => 'Filtr węzłów';

  @override
  String get nodeHighlight => 'Podświetlenie węzłów';

  @override
  String get map => 'Mapa';

  @override
  String snrDb(Object value) {
    return 'SNR $value dB';
  }

  @override
  String nodeTitle(Object name) {
    return 'Węzeł $name';
  }

  @override
  String nodeTitleId(Object id) {
    return 'Węzeł ($id)';
  }

  @override
  String get nodeInfo => 'NodeInfo';

  @override
  String batteryLevel(Object percentage) {
    return '🔋$percentage%';
  }

  @override
  String viaNameId(Object id, Object name) {
    return 'przez $name (0x$id)';
  }

  @override
  String viaName(Object name) {
    return 'przez $name';
  }

  @override
  String viaId(Object id) {
    return 'przez 0x$id';
  }

  @override
  String get devicesTab => 'Urządzenia';

  @override
  String get searchLogs => 'Szukaj w logach';

  @override
  String get searchLogsHint =>
      'Szukaj w czasie, poziomie, tagach lub wiadomości';

  @override
  String get logsTitle => 'Logi';

  @override
  String get tag => 'Tag';

  @override
  String get level => 'Poziom';

  @override
  String get valueEmptyPresence =>
      'Wartość (pusta = tylko obecność dla dokładnego)';

  @override
  String get regexTip =>
      'Wskazówka: regex używa składni Dart i domyślnie nie rozróżnia wielkości liter';

  @override
  String get selectLevels => 'Wybierz poziomy';

  @override
  String get unspecified => '(nieokreślony)';

  @override
  String connectFailedError(Object error) {
    return 'Połączenie nieudane: $error';
  }

  @override
  String get power => 'Zasilanie';

  @override
  String get network => 'Sieć';

  @override
  String get display => 'Wyświetlacz';

  @override
  String get lora => 'LoRa';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get security => 'Bezpieczeństwo';

  @override
  String get sessionKey => 'Klucz sesji';

  @override
  String get nodeMod => 'Modyfikacje węzła';

  @override
  String get nodeModAdmin => 'Admin modyfikacji węzła';

  @override
  String get idleGame => 'Gra bezczynności';

  @override
  String get deviceState => 'Stan urządzenia';

  @override
  String get noDeviceState => 'Brak stanu urządzenia';

  @override
  String get connectToViewState =>
      'Połącz się z urządzeniem, aby zobaczyć jego stan';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get enableNotifications => 'Włącz powiadomienia';

  @override
  String roleWithRole(Object role) {
    return 'Rola: $role';
  }

  @override
  String get knownNodes => 'Znane węzły';

  @override
  String get notConfigured => 'Nie skonfigurowano';

  @override
  String get noConfigurationData => 'Brak danych konfiguracyjnych';

  @override
  String nodesWithCount(Object count) {
    return 'Węzły ($count)';
  }

  @override
  String get messageDetails => 'Szczegóły wiadomości';

  @override
  String statusWithStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String packetIdWithId(Object id) {
    return 'ID pakietu: $id';
  }

  @override
  String get messageInfo => 'Info o wiadomości';

  @override
  String get sessionKeyRequested => 'Zażądano klucza sesji';

  @override
  String get stateMissing => 'Brak stanu';

  @override
  String idWithId(Object id) {
    return 'ID: $id';
  }

  @override
  String get xmodem => 'XModem';

  @override
  String xmodemStatus(Object control, Object seq) {
    return 'Status XModem';
  }

  @override
  String get idTitle => 'ID';

  @override
  String get protectApp => 'Chroń aplikację';

  @override
  String get setPassword => 'Ustaw hasło';

  @override
  String get enterPassword => 'Wprowadź hasło';

  @override
  String get currentPassword => 'Obecne hasło';

  @override
  String get incorrectPassword => 'Nieprawidłowe hasło';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get save => 'Zapisz';

  @override
  String get hostInputLabel => 'Host (adres IP lub nazwa)';

  @override
  String get portInputLabel => 'Port';

  @override
  String get invalidHostPort => 'Wprowadź poprawny host i port';

  @override
  String get connectedToIpDevice => 'Połączono z urządzeniem IP';

  @override
  String get connectedToUsbDevice => 'Połączono z urządzeniem USB';

  @override
  String get refreshPorts => 'Odśwież porty';

  @override
  String get noSerialPortsFound => 'Nie znaleziono portów szeregowych';

  @override
  String get selectSerialPort => 'Wybierz port szeregowy';

  @override
  String get xmodemTitle => 'XModem';

  @override
  String get emptyState => '—';

  @override
  String get filterKey => 'Klucz';

  @override
  String get satelliteEmoji => '📡';

  @override
  String get puzzleEmoji => '🧩';

  @override
  String get appProtected => 'Aplikacja chroniona';

  @override
  String get disableProtection => 'Wyłącz ochronę';

  @override
  String get password => 'Hasło';

  @override
  String get connectToIpDevice => 'Połącz z urządzeniem Meshtastic przez IP';

  @override
  String get connectViaUsb => 'Połącz przez USB';

  @override
  String get event => 'Zdarzenie';

  @override
  String get defaultChannel => 'Domyślny';

  @override
  String rssiDbm(Object value) {
    return '$value dBm';
  }

  @override
  String get sendingToRadio => 'Wysyłanie do radia...';

  @override
  String get sentToRadio => 'Wysłano do radia';

  @override
  String get acknowledgedByReceiver => 'Potwierdzono przez odbiorcę';

  @override
  String get acknowledgedByRelay => 'Potwierdzono przez węzeł pośredni';

  @override
  String get notAcknowledgedTimeout => 'Brak potwierdzenia (Timeout)';

  @override
  String get received => 'Odebrano';

  @override
  String get packetInfo => 'Info o pakiecie:';

  @override
  String nodeName(Object name) {
    return 'Węzeł $name';
  }

  @override
  String unknownNode(Object id) {
    return 'Węzeł $id (Nieznany)';
  }

  @override
  String get deviceConfig => 'Konfiguracja urządzenia';

  @override
  String get positionConfig => 'Konfiguracja pozycji';

  @override
  String get powerConfig => 'Konfiguracja zasilania';

  @override
  String get networkConfig => 'Konfiguracja sieci';

  @override
  String get displayConfig => 'Konfiguracja wyświetlacza';

  @override
  String get loraConfig => 'Konfiguracja LoRa';

  @override
  String get bluetoothConfig => 'Konfiguracja Bluetooth';

  @override
  String get securityConfig => 'Konfiguracja bezpieczeństwa';

  @override
  String get mqttConfig => 'Konfiguracja MQTT';

  @override
  String get telemetryConfig => 'Konfiguracja telemetrii';

  @override
  String get serialConfig => 'Konfiguracja portu szeregowego';

  @override
  String get storeForwardConfig => 'Konfiguracja Przechowaj i Przekaż';

  @override
  String get rangeTestConfig => 'Konfiguracja testu zasięgu';

  @override
  String get externalNotificationConfig =>
      'Konfiguracja powiadomień zewnętrznych';

  @override
  String get audioConfig => 'Konfiguracja audio';

  @override
  String get neighborInfoConfig => 'Konfiguracja informacji o sąsiadach';

  @override
  String get remoteHardwareConfig => 'Konfiguracja zdalnego sprzętu';

  @override
  String get paxcounterConfig => 'Konfiguracja licznika osób';

  @override
  String get cannedMessageConfig => 'Konfiguracja wiadomości szablonowych';

  @override
  String get ambientLightingConfig => 'Konfiguracja oświetlenia otoczenia';

  @override
  String get detectionSensorConfig => 'Konfiguracja czujnika wykrywania';

  @override
  String get dtnOverlayConfig => 'Konfiguracja nakładki DTN';

  @override
  String get broadcastAssistConfig => 'Konfiguracja asystenta rozgłaszania';

  @override
  String get nodeModConfig => 'Konfiguracja modyfikacji węzła';

  @override
  String get nodeModAdminConfig => 'Konfiguracja admina modyfikacji węzła';

  @override
  String get idleGameConfig => 'Konfiguracja gry bezczynności';

  @override
  String get serialEnabled => 'Port szeregowy włączony';

  @override
  String get buttonGpio => 'GPIO przycisku';

  @override
  String get buzzerGpio => 'GPIO brzęczyka';

  @override
  String get rebroadcastMode => 'Tryb retransmisji';

  @override
  String get nodeInfoBroadcastSecs => 'Czas rozgłaszania info o węźle (s)';

  @override
  String get doubleTapAsButtonPress => 'Podwójne stuknięcie jako przycisk';

  @override
  String get isManaged => 'Zarządzany';

  @override
  String get disableTripleClick => 'Wyłącz potrójne kliknięcie';

  @override
  String get timezone => 'Strefa czasowa';

  @override
  String get ledHeartbeatDisabled => 'Dioda heartbeat wyłączona';

  @override
  String get buzzerMode => 'Tryb brzęczyka';

  @override
  String get positionBroadcastSecs => 'Czas rozgłaszania pozycji (s)';

  @override
  String get positionBroadcastSmartEnabled =>
      'Inteligentne rozgłaszanie pozycji';

  @override
  String get fixedPosition => 'Stała pozycja';

  @override
  String get gpsEnabled => 'GPS włączony';

  @override
  String get gpsUpdateInterval => 'Interwał aktualizacji GPS';

  @override
  String get gpsAttemptTime => 'Czas próby GPS';

  @override
  String get positionFlags => 'Flagi pozycji';

  @override
  String get rxGpio => 'RX GPIO';

  @override
  String get txGpio => 'TX GPIO';

  @override
  String get broadcastSmartMinimumDistance => 'Min. dystans smart rozgłaszania';

  @override
  String get broadcastSmartMinimumIntervalSecs =>
      'Min. interwał smart rozgłaszania (s)';

  @override
  String get gpsEnableGpio => 'GPIO włączenia GPS';

  @override
  String get gpsMode => 'Tryb GPS';

  @override
  String get isPowerSaving => 'Oszczędzanie energii';

  @override
  String get onBatteryShutdownAfterSecs => 'Wyłącz po czasie na baterii (s)';

  @override
  String get adcMultiplierOverride => 'Nadpisanie mnożnika ADC';

  @override
  String get waitBluetoothSecs => 'Czekaj na Bluetooth (s)';

  @override
  String get sdsSecs => 'SDS (s)';

  @override
  String get lsSecs => 'LS (s)';

  @override
  String get minWakeSecs => 'Min. czas wybudzenia (s)';

  @override
  String get deviceBatteryInaAddress => 'Adres INA baterii urządzenia';

  @override
  String get powermonEnables => 'Włączenia Powermon';

  @override
  String get wifiEnabled => 'WiFi włączone';

  @override
  String get wifiSsid => 'SSID WiFi';

  @override
  String get screenOnSecs => 'Czas włączenia ekranu (s)';

  @override
  String get autoScreenCarouselSecs => 'Auto karuzela ekranu (s)';

  @override
  String get compassNorthTop => 'Kompas północ na górze';

  @override
  String get flipScreen => 'Odwróć ekran';

  @override
  String get units => 'Jednostki';

  @override
  String get oled => 'OLED';

  @override
  String get displayMode => 'Tryb wyświetlania';

  @override
  String get headingBold => 'Pogrubiony nagłówek';

  @override
  String get wakeOnTapOrMotion => 'Wybudź przy stuknięciu lub ruchu';

  @override
  String get compassOrientation => 'Orientacja kompasu';

  @override
  String get use12hClock => 'Zegar 12h';

  @override
  String get useLongNodeName => 'Długa nazwa węzła';

  @override
  String get region => 'Region';

  @override
  String get modemPreset => 'Preset modemu';

  @override
  String get hopLimit => 'Limit skoków';

  @override
  String get txEnabled => 'TX włączone';

  @override
  String get txPower => 'Moc TX';

  @override
  String get enabled => 'Włączone';

  @override
  String get mode => 'Tryb';

  @override
  String get fixedPin => 'Stały PIN';

  @override
  String get publicKey => 'Klucz publiczny';

  @override
  String get privateKey => 'Klucz prywatny';

  @override
  String get adminKeys => 'Klucze admina';

  @override
  String get debugLogApiEnabled => 'API logów debugowania';

  @override
  String get adminChannelEnabled => 'Kanał admina włączony';

  @override
  String get address => 'Adres';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get encryption => 'Szyfrowanie';

  @override
  String get json => 'JSON';

  @override
  String get tls => 'TLS';

  @override
  String get rootTopic => 'Temat główny';

  @override
  String get proxyToClient => 'Proxy do klienta';

  @override
  String get mapReporting => 'Raportowanie mapy';

  @override
  String get deviceUpdateInterval => 'Interwał aktualizacji urządzenia';

  @override
  String get environmentUpdateInterval => 'Interwał aktualizacji środowiska';

  @override
  String get environmentMeasurement => 'Pomiar środowiska';

  @override
  String get environmentScreen => 'Ekran środowiska';

  @override
  String get airQuality => 'Jakość powietrza';

  @override
  String get airQualityInterval => 'Interwał jakości powietrza';

  @override
  String get powerMeasurement => 'Pomiar mocy';

  @override
  String get powerUpdateInterval => 'Interwał aktualizacji mocy';

  @override
  String get powerScreen => 'Ekran mocy';

  @override
  String get healthMeasurement => 'Pomiar zdrowia';

  @override
  String get healthUpdateInterval => 'Interwał aktualizacji zdrowia';

  @override
  String get healthScreen => 'Ekran zdrowia';

  @override
  String get deviceTelemetry => 'Telemetria urządzenia';

  @override
  String get echo => 'Echo';

  @override
  String get rxd => 'RXD';

  @override
  String get txd => 'TXD';

  @override
  String get baud => 'Baud';

  @override
  String get timeout => 'Timeout';

  @override
  String get overrideConsole => 'Nadpisz konsolę';

  @override
  String get heartbeat => 'Heartbeat';

  @override
  String get records => 'Rekordy';

  @override
  String get historyReturnMax => 'Max zwrot historii';

  @override
  String get historyReturnWindow => 'Okno zwrotu historii';

  @override
  String get isServer => 'Jest serwerem';

  @override
  String get emitControlSignals => 'Emituj sygnały sterujące';

  @override
  String get sender => 'Nadawca';

  @override
  String get clearOnReboot => 'Wyczyść przy restarcie';

  @override
  String get outputMs => 'Wyjście MS';

  @override
  String get output => 'Wyjście';

  @override
  String get active => 'Aktywne';

  @override
  String get alertMessage => 'Wiadomość alarmowa';

  @override
  String get alertBell => 'Dzwonek alarmowy';

  @override
  String get usePwm => 'Użyj PWM';

  @override
  String get outputVibra => 'Wibracje';

  @override
  String get outputBuzzer => 'Brzęczyk';

  @override
  String get nagTimeout => 'Timeout nękania';

  @override
  String get useI2sAsBuzzer => 'Użyj I2S jako brzęczyka';

  @override
  String get codec2Enabled => 'Codec2 włączony';

  @override
  String get pttPin => 'Pin PTT';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get i2sWs => 'I2S WS';

  @override
  String get i2sSd => 'I2S SD';

  @override
  String get i2sDin => 'I2S DIN';

  @override
  String get i2sSck => 'I2S SCK';

  @override
  String get updateInterval => 'Interwał aktualizacji';

  @override
  String get transmitOverLora => 'Transmisja przez LoRa';

  @override
  String get allowUndefinedPinAccess =>
      'Zezwól na dostęp do niezdefiniowanych pinów';

  @override
  String get paxcounterUpdateInterval => 'Interwał aktualizacji Paxcounter';

  @override
  String get wifiThreshold => 'Próg WiFi';

  @override
  String get bleThreshold => 'Próg BLE';

  @override
  String get rotary1Enabled => 'Rotary1 włączone';

  @override
  String get inputBrokerPinA => 'Input Broker Pin A';

  @override
  String get inputBrokerPinB => 'Input Broker Pin B';

  @override
  String get inputBrokerPinPress => 'Input Broker Pin Press';

  @override
  String get upDown1Enabled => 'Up/Down 1 włączone';

  @override
  String get allowInputSource => 'Zezwól na źródło wejścia';

  @override
  String get sendBell => 'Wyślij dzwonek';

  @override
  String get ledState => 'Stan LED';

  @override
  String get current => 'Prąd';

  @override
  String get red => 'Czerwony';

  @override
  String get green => 'Zielony';

  @override
  String get blue => 'Niebieski';

  @override
  String get minBroadcastSecs => 'Min. czas rozgłaszania (s)';

  @override
  String get stateBroadcastSecs => 'Czas rozgłaszania stanu (s)';

  @override
  String get monitorPin => 'Pin monitorowania';

  @override
  String get triggerType => 'Typ wyzwalacza';

  @override
  String get usePullup => 'Użyj Pullup';

  @override
  String get ttlMinutes => 'TTL (minuty)';

  @override
  String get initialDelayBaseMs => 'Początkowe opóźnienie bazowe (ms)';

  @override
  String get retryBackoffMs => 'Backoff ponowienia (ms)';

  @override
  String get maxTries => 'Maks. prób';

  @override
  String get degreeThreshold => 'Próg stopnia';

  @override
  String get dupThreshold => 'Próg duplikatów';

  @override
  String get windowMs => 'Okno (ms)';

  @override
  String get maxExtraHops => 'Maks. dodatkowe skoki';

  @override
  String get jitterMs => 'Jitter (ms)';

  @override
  String get airtimeGuard => 'Ochrona czasu antenowego';

  @override
  String get textStatus => 'Status tekstowy';

  @override
  String get emoji => 'Emoji';

  @override
  String get snifferEnabled => 'Sniffer włączony';

  @override
  String get doNotSendPrvOverMqtt => 'Nie wysyłaj PRV przez MQTT';

  @override
  String get localStatsOverMesh => 'Lokalne statystyki przez Mesh';

  @override
  String get idlegameEnabled => 'Gra bezczynności włączona';

  @override
  String get autoResponderEnabled => 'Autoresponder włączony';

  @override
  String get autoResponderText => 'Tekst autorespondera';

  @override
  String get autoRedirectMessages => 'Automatyczne przekierowanie wiadomości';

  @override
  String get autoRedirectTarget => 'Cel przekierowania';

  @override
  String get telemetryLimiter => 'Limiter telemetrii';

  @override
  String get positionLimiter => 'Limiter pozycji';

  @override
  String get opportunisticFlooding => 'Oportunistyczny flooding';

  @override
  String get idleGameVariant => 'Wariant gry bezczynności';

  @override
  String get telemetryTitle => 'Telemetria';

  @override
  String get noTelemetryData => 'Brak danych telemetrycznych';

  @override
  String get telemetryBattery => 'Bateria';

  @override
  String get telemetryVoltage => 'Napięcie';

  @override
  String get telemetryChannelUtil => 'Wykorzystanie kanału';

  @override
  String get telemetryAirUtilTx => 'Wykorzystanie TX';

  @override
  String get telemetryTemperature => 'Temperatura';

  @override
  String get telemetryHumidity => 'Wilgotność';

  @override
  String get telemetryPressure => 'Ciśnienie';

  @override
  String get telemetryPm25 => 'PM2.5';

  @override
  String get telemetryCo2 => 'CO2';

  @override
  String telemetryChVoltage(Object channel) {
    return 'Napięcie kan. $channel';
  }

  @override
  String telemetryHistory(Object count) {
    return 'Historia: $count punktów';
  }

  @override
  String get traces => 'Śledzenie tras';

  @override
  String get traceRoute => 'Śledź trasę';

  @override
  String get startTrace => 'Rozpocznij śledzenie';

  @override
  String get traceTarget => 'Cel';

  @override
  String get tracePending => 'W toku';

  @override
  String get traceCompleted => 'Zakończono';

  @override
  String get traceFailed => 'Nieudane';

  @override
  String get traceTimeout => 'Przekroczono czas';

  @override
  String get traceNoHistory => 'Brak śledzeń';

  @override
  String get traceEvents => 'Zdarzenia śledzenia';

  @override
  String get traceForwardRoute => 'Trasa tam';

  @override
  String get traceReturnRoute => 'Trasa powrotna';

  @override
  String traceHopCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skoków',
      few: '$count skoki',
      one: '1 skok',
      zero: '0 skoków',
    );
    return '$_temp0';
  }

  @override
  String get traceShowOnMap => 'Pokaż na mapie';

  @override
  String get traceSelectNode => 'Wybierz węzeł do śledzenia';

  @override
  String get traceSent => 'Wysłano żądanie śledzenia';

  @override
  String get traceToggleVisualization => 'Przełącz wizualizację śledzenia';

  @override
  String get noNodesAvailable => 'Brak dostępnych węzłów';

  @override
  String get refresh => 'Odśwież';

  @override
  String get noDeviceConnected => 'Brak połączonego urządzenia';

  @override
  String get selectDevice => 'Wybierz urządzenie';

  @override
  String get bleHeartbeatInterval => 'Interwał Heartbeat BLE';

  @override
  String get bleHeartbeatIntervalDescription =>
      'Czas między wiadomościami heartbeat wysyłanymi do urządzeń BLE (w sekundach)';

  @override
  String get tracerouteMinInterval => 'Limit częstotliwości Traceroute';

  @override
  String get tracerouteMinIntervalDescription =>
      'Minimalna liczba sekund między żądaniami traceroute do tego samego węzła. Firmware również wymusza limity częstotliwości, aby zapobiec przeciążeniu sieci.';

  @override
  String get configTimeout => 'Timeout Pobierania Konfiguracji';

  @override
  String get configTimeoutDescription =>
      'Maksymalny czas bez aktywności podczas pobierania konfiguracji urządzenia (w sekundach)';
}
