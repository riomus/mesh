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
  String statusReconnecting(Object attempt, Object max) {
    return 'Ponowne łączenie (próba $attempt/$max)...';
  }

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
  String get scanRequiredFirst =>
      'Device not found. Please scan for devices first.';

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
  String get loadingConfig => 'Ładowanie konfiguracji';

  @override
  String get pleaseWaitFetchingConfig =>
      'Proszę czekać, pobieranie konfiguracji urządzenia...';

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
  String get sessionKeyRequested => 'sessionKeyRequested';

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
  String get save => 'save';

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
  String get password => 'password';

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
  String get serialEnabled => 'serialEnabled';

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
  String get isManaged => 'isManaged';

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
  String get screenOnSecs => 'screenOnSecs';

  @override
  String get autoScreenCarouselSecs => 'autoScreenCarouselSecs';

  @override
  String get compassNorthTop => 'compassNorthTop';

  @override
  String get flipScreen => 'flipScreen';

  @override
  String get units => 'units';

  @override
  String get oled => 'oled';

  @override
  String get displayMode => 'Tryb wyświetlania';

  @override
  String get headingBold => 'headingBold';

  @override
  String get wakeOnTapOrMotion => 'wakeOnTapOrMotion';

  @override
  String get compassOrientation => 'compassOrientation';

  @override
  String get use12hClock => 'use12hClock';

  @override
  String get useLongNodeName => 'useLongNodeName';

  @override
  String get region => 'region';

  @override
  String get modemPreset => 'modemPreset';

  @override
  String get hopLimit => 'hopLimit';

  @override
  String get txEnabled => 'txEnabled';

  @override
  String get txPower => 'txPower';

  @override
  String get enabled => 'enabled';

  @override
  String get mode => 'mode';

  @override
  String get fixedPin => 'fixedPin';

  @override
  String get publicKey => 'publicKey';

  @override
  String get privateKey => 'privateKey';

  @override
  String get adminKeys => 'Klucze admina';

  @override
  String get debugLogApiEnabled => 'debugLogApiEnabled';

  @override
  String get adminChannelEnabled => 'adminChannelEnabled';

  @override
  String get address => 'address';

  @override
  String get username => 'username';

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
  String get deviceUpdateInterval => 'deviceUpdateInterval';

  @override
  String get environmentUpdateInterval => 'environmentUpdateInterval';

  @override
  String get environmentMeasurement => 'Pomiar środowiska';

  @override
  String get environmentScreen => 'Ekran środowiska';

  @override
  String get airQuality => 'Jakość powietrza';

  @override
  String get airQualityInterval => 'airQualityInterval';

  @override
  String get powerMeasurement => 'Pomiar mocy';

  @override
  String get powerUpdateInterval => 'powerUpdateInterval';

  @override
  String get powerScreen => 'Ekran mocy';

  @override
  String get healthMeasurement => 'Pomiar zdrowia';

  @override
  String get healthUpdateInterval => 'healthUpdateInterval';

  @override
  String get healthScreen => 'Ekran zdrowia';

  @override
  String get deviceTelemetry => 'Telemetria urządzenia';

  @override
  String get echo => 'echo';

  @override
  String get rxd => 'rxd';

  @override
  String get txd => 'txd';

  @override
  String get baud => 'baud';

  @override
  String get timeout => 'timeout';

  @override
  String get overrideConsole => 'Nadpisz konsolę';

  @override
  String get heartbeat => 'heartbeat';

  @override
  String get records => 'records';

  @override
  String get historyReturnMax => 'historyReturnMax';

  @override
  String get historyReturnWindow => 'historyReturnWindow';

  @override
  String get isServer => 'isServer';

  @override
  String get emitControlSignals => 'emitControlSignals';

  @override
  String get sender => 'sender';

  @override
  String get clearOnReboot => 'clearOnReboot';

  @override
  String get outputMs => 'outputMs';

  @override
  String get output => 'output';

  @override
  String get active => 'active';

  @override
  String get alertMessage => 'alertMessage';

  @override
  String get alertBell => 'alertBell';

  @override
  String get usePwm => 'usePwm';

  @override
  String get outputVibra => 'outputVibra';

  @override
  String get outputBuzzer => 'outputBuzzer';

  @override
  String get nagTimeout => 'nagTimeout';

  @override
  String get useI2sAsBuzzer => 'useI2sAsBuzzer';

  @override
  String get codec2Enabled => 'codec2Enabled';

  @override
  String get pttPin => 'pttPin';

  @override
  String get bitrate => 'bitrate';

  @override
  String get i2sWs => 'i2sWs';

  @override
  String get i2sSd => 'i2sSd';

  @override
  String get i2sDin => 'i2sDin';

  @override
  String get i2sSck => 'i2sSck';

  @override
  String get updateInterval => 'updateInterval';

  @override
  String get transmitOverLora => 'transmitOverLora';

  @override
  String get allowUndefinedPinAccess => 'allowUndefinedPinAccess';

  @override
  String get paxcounterUpdateInterval => 'paxcounterUpdateInterval';

  @override
  String get wifiThreshold => 'wifiThreshold';

  @override
  String get bleThreshold => 'bleThreshold';

  @override
  String get rotary1Enabled => 'rotary1Enabled';

  @override
  String get inputBrokerPinA => 'Input Broker Pin A';

  @override
  String get inputBrokerPinB => 'Input Broker Pin B';

  @override
  String get inputBrokerPinPress => 'Input Broker Pin Press';

  @override
  String get upDown1Enabled => 'Up/Down 1 włączone';

  @override
  String get allowInputSource => 'allowInputSource';

  @override
  String get sendBell => 'sendBell';

  @override
  String get ledState => 'ledState';

  @override
  String get current => 'current';

  @override
  String get red => 'red';

  @override
  String get green => 'green';

  @override
  String get blue => 'blue';

  @override
  String get minBroadcastSecs => 'Min. czas rozgłaszania (s)';

  @override
  String get stateBroadcastSecs => 'stateBroadcastSecs';

  @override
  String get monitorPin => 'monitorPin';

  @override
  String get triggerType => 'Typ wyzwalacza';

  @override
  String get usePullup => 'usePullup';

  @override
  String get ttlMinutes => 'ttlMinutes';

  @override
  String get initialDelayBaseMs => 'initialDelayBaseMs';

  @override
  String get retryBackoffMs => 'retryBackoffMs';

  @override
  String get maxTries => 'maxTries';

  @override
  String get degreeThreshold => 'degreeThreshold';

  @override
  String get dupThreshold => 'dupThreshold';

  @override
  String get windowMs => 'windowMs';

  @override
  String get maxExtraHops => 'maxExtraHops';

  @override
  String get jitterMs => 'jitterMs';

  @override
  String get airtimeGuard => 'airtimeGuard';

  @override
  String get textStatus => 'textStatus';

  @override
  String get emoji => 'emoji';

  @override
  String get snifferEnabled => 'snifferEnabled';

  @override
  String get doNotSendPrvOverMqtt => 'doNotSendPrvOverMqtt';

  @override
  String get localStatsOverMesh => 'Lokalne statystyki przez Mesh';

  @override
  String get idlegameEnabled => 'idlegameEnabled';

  @override
  String get autoResponderEnabled => 'autoResponderEnabled';

  @override
  String get autoResponderText => 'autoResponderText';

  @override
  String get autoRedirectMessages => 'autoRedirectMessages';

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

  @override
  String get nodesWithoutLocation => 'Węzły bez lokalizacji';

  @override
  String targetNodeNoLocation(Object id) {
    return 'Węzeł docelowy $id nie ma danych lokalizacyjnych. Linia śledzenia nie może zostać narysowana.';
  }

  @override
  String get startLocal => 'Start (Lokalny)';

  @override
  String get traceTooltip => 'Ślad';

  @override
  String get ackTooltip => 'Potw.';

  @override
  String get localDevice => 'Urządzenie Lokalne';

  @override
  String get deviceMetricsTitle => 'Metryki Urządzenia';

  @override
  String get environmentMetricsTitle => 'Metryki Środowiskowe';

  @override
  String get airQualityMetricsTitle => 'Metryki Jakości Powietrza';

  @override
  String get powerMetricsTitle => 'Metryki Zasilania';

  @override
  String get localStatsTitle => 'Statystyki Lokalne';

  @override
  String get healthMetricsTitle => 'Metryki Zdrowia';

  @override
  String get hostMetricsTitle => 'Metryki Hosta';

  @override
  String errorPrefix(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get tabBle => 'BLE';

  @override
  String get tabIp => 'IP';

  @override
  String get tabUsb => 'USB';

  @override
  String get tabSim => 'Sim';

  @override
  String get simulationEnvironment => 'Środowisko Symulacji';

  @override
  String get simulationDescription =>
      'Połącz się z symulowanym urządzeniem, aby przetestować komponenty interfejsu z fałszywymi danymi (węzły, czat, ślady itp.).';

  @override
  String get startSimulation => 'Rozpocznij Symulację';

  @override
  String get connectedToSimulation => 'Połączono z Urządzeniem Symulacyjnym';

  @override
  String simulationFailed(Object error) {
    return 'Symulacja nieudana: $error';
  }

  @override
  String get statusHistory => 'Historia Statusu';

  @override
  String sourceNodePrefix(Object name) {
    return 'Źródło: $name';
  }

  @override
  String get me => 'JA';

  @override
  String get targetLabel => '[Cel]';

  @override
  String get sourceLabel => '[Źródło]';

  @override
  String get ackLabel => '[Potw]';

  @override
  String traceStreamError(Object error) {
    return 'Błąd w strumieniu śledzenia: $error';
  }

  @override
  String errorLoadingMessages(Object error) {
    return 'Błąd ładowania wiadomości: $error';
  }

  @override
  String configSaveError(Object error) {
    return 'Błąd zapisu konfiguracji: $error';
  }

  @override
  String myNodeNumLabel(Object num) {
    return 'mójNumerWęzła=$num';
  }

  @override
  String nodeNumLabel(Object num) {
    return 'numer=$num';
  }

  @override
  String idLabel(Object id) {
    return 'id=$id';
  }

  @override
  String channelIndexLabel(Object index) {
    return 'indeks=$index';
  }

  @override
  String freeLabel(Object value) {
    return 'wolne=$value';
  }

  @override
  String maxLabel(Object value) {
    return 'maks=$value';
  }

  @override
  String fwLabel(Object value) {
    return 'fw=$value';
  }

  @override
  String hwLabel(Object value) {
    return 'hw=$value';
  }

  @override
  String roleKey(Object value) {
    return 'rola=$value';
  }

  @override
  String get wifiLabel => 'wifi';

  @override
  String get btLabel => 'bt';

  @override
  String get ethLabel => 'eth';

  @override
  String bytesLabel(Object value) {
    return '$value bajtów';
  }

  @override
  String fromLabel(Object value) {
    return 'od=$value';
  }

  @override
  String toLabel(Object value) {
    return 'do=$value';
  }

  @override
  String chLabel(Object value) {
    return 'kan=$value';
  }

  @override
  String nonceLabel(Object value) {
    return 'nonce=$value';
  }

  @override
  String get nA => 'N/D';

  @override
  String secondsSuffix(Object value) {
    return '${value}s';
  }

  @override
  String get myNodeNum => 'myNodeNum';

  @override
  String get rebootCount => 'rebootCount';

  @override
  String get minAppVersion => 'minAppVersion';

  @override
  String get firmwareEdition => 'firmwareEdition';

  @override
  String get nodedbCount => 'nodedbCount';

  @override
  String get pioEnv => 'pioEnv';

  @override
  String get deviceId => 'deviceId';

  @override
  String get nodeNum => 'num';

  @override
  String get userLongName => 'user.longName';

  @override
  String get userShortName => 'user.shortName';

  @override
  String get positionLat => 'position.lat';

  @override
  String get positionLon => 'position.lon';

  @override
  String get lastHeard => 'lastHeard';

  @override
  String get isFavorite => 'isFavorite';

  @override
  String get isIgnored => 'isIgnored';

  @override
  String get isKeyManuallyVerified => 'isKeyManuallyVerified';

  @override
  String get volt => 'volt';

  @override
  String get chUtil => 'chUtil';

  @override
  String get airUtil => 'airUtil';

  @override
  String get uptime => 'uptime';

  @override
  String get res => 'res';

  @override
  String get size => 'size';

  @override
  String get maxlen => 'maxlen';

  @override
  String get meshPacketId => 'meshPacketId';

  @override
  String get firmware => 'fw';

  @override
  String get hardware => 'hw';

  @override
  String get wifi => 'wifi';

  @override
  String get ethernet => 'eth';

  @override
  String get stateVersion => 'stateVer';

  @override
  String get canShutdown => 'canShutdown';

  @override
  String get hasRemoteHw => 'hasRemoteHw';

  @override
  String get hasPKC => 'hasPKC';

  @override
  String get excluded => 'excluded';

  @override
  String get hasFwPlus => 'hasFwPlus';

  @override
  String get hasNodemod => 'hasNodemod';

  @override
  String get topic => 'topic';

  @override
  String get retained => 'retained';

  @override
  String get text => 'text';

  @override
  String get dataLength => 'dataLen';

  @override
  String get fileName => 'name';

  @override
  String get sizeBytes => 'sizeBytes';

  @override
  String get message => 'message';

  @override
  String get replyId => 'replyId';

  @override
  String get time => 'time';

  @override
  String get payloadVariant => 'payloadVariant';

  @override
  String get source => 'source';

  @override
  String get control => 'control';

  @override
  String get seq => 'seq';

  @override
  String get crc16 => 'crc16';

  @override
  String get buffer => 'buffer';

  @override
  String get from => 'from';

  @override
  String get to => 'to';

  @override
  String get rxTime => 'rxTime';

  @override
  String get rxRssi => 'rxRssi';

  @override
  String get rxSnr => 'rxSnr';

  @override
  String get wantAck => 'wantAck';

  @override
  String get priority => 'priority';

  @override
  String get transport => 'transport';

  @override
  String get hopStart => 'hopStart';

  @override
  String get encrypted => 'encrypted';

  @override
  String get pkiEncrypted => 'pkiEncrypted';

  @override
  String get nextHop => 'nextHop';

  @override
  String get relayNode => 'relayNode';

  @override
  String get txAfter => 'txAfter';

  @override
  String get latI => 'latI';

  @override
  String get lonI => 'lonI';

  @override
  String get altitude => 'alt';

  @override
  String get gpsAccuracy => 'gpsAcc';

  @override
  String get sats => 'sats';

  @override
  String get locationSource => 'locSource';

  @override
  String get altitudeSource => 'altSource';

  @override
  String get tsMillisAdj => 'tsMillisAdj';

  @override
  String get altHae => 'altHae';

  @override
  String get altGeoSep => 'altGeoSep';

  @override
  String get pDOP => 'pDOP';

  @override
  String get hDOP => 'hDOP';

  @override
  String get vDOP => 'vDOP';

  @override
  String get groundSpeed => 'groundSpeed';

  @override
  String get groundTrack => 'groundTrack';

  @override
  String get fixQuality => 'fixQuality';

  @override
  String get fixType => 'fixType';

  @override
  String get sensorId => 'sensorId';

  @override
  String get nextUpdate => 'nextUpdate';

  @override
  String get seqNumber => 'seqNumber';

  @override
  String get precisionBits => 'precisionBits';

  @override
  String get expire => 'expire';

  @override
  String get lockedTo => 'lockedTo';

  @override
  String get description => 'desc';

  @override
  String get icon => 'icon';

  @override
  String get mac => 'mac';

  @override
  String get isLicensed => 'isLicensed';

  @override
  String get isUnmessagable => 'isUnmessagable';

  @override
  String get variant => 'variant';

  @override
  String get errorReason => 'errorReason';

  @override
  String get requestId => 'requestId';

  @override
  String get type => 'type';

  @override
  String get gpioMask => 'gpioMask';

  @override
  String get gpioValue => 'gpioValue';

  @override
  String get nodeId => 'nodeId';

  @override
  String get lastSentById => 'lastSentById';

  @override
  String get nodeBroadcastIntervalSecs => 'nodeBroadcastIntervalSecs';

  @override
  String get lastRxTime => 'lastRxTime';

  @override
  String get broadcastIntSecs => 'broadcastIntSecs';

  @override
  String get routeLen => 'routeLen';

  @override
  String get snrTowards => 'snrTowards';

  @override
  String get routeBackLen => 'routeBackLen';

  @override
  String get snrBack => 'snrBack';

  @override
  String get nonce => 'nonce';

  @override
  String get hash1 => 'hash1';

  @override
  String get hash2 => 'hash2';

  @override
  String get port => 'port';

  @override
  String get bytes => 'bytes';

  @override
  String get relativeHumidity => 'relativeHumidity';

  @override
  String get barometricPressure => 'barometricPressure';

  @override
  String get gasResistance => 'gasResistance';

  @override
  String get iaq => 'iaq';

  @override
  String get lux => 'lux';

  @override
  String get whiteLux => 'whiteLux';

  @override
  String get irLux => 'irLux';

  @override
  String get uvLux => 'uvLux';

  @override
  String get windDirection => 'windDirection';

  @override
  String get windSpeed => 'windSpeed';

  @override
  String get weight => 'weight';

  @override
  String get windGust => 'windGust';

  @override
  String get windLull => 'windLull';

  @override
  String get pm10Standard => 'pm10Standard';

  @override
  String get pm25Standard => 'pm25Standard';

  @override
  String get pm100Standard => 'pm100Standard';

  @override
  String get pm10Environmental => 'pm10Environmental';

  @override
  String get pm25Environmental => 'pm25Environmental';

  @override
  String get pm100Environmental => 'pm100Environmental';

  @override
  String get particles03um => 'particles03um';

  @override
  String get particles05um => 'particles05um';

  @override
  String get particles10um => 'particles10um';

  @override
  String get particles25um => 'particles25um';

  @override
  String get particles50um => 'particles50um';

  @override
  String get particles100um => 'particles100um';

  @override
  String get co2Temperature => 'co2Temperature';

  @override
  String get co2Humidity => 'co2Humidity';

  @override
  String get formaldehyde => 'formFormaldehyde';

  @override
  String get formaldehydeHumidity => 'formHumidity';

  @override
  String get formaldehydeTemperature => 'formTemperature';

  @override
  String get pm40Standard => 'pm40Standard';

  @override
  String get ch1Voltage => 'ch1Voltage';

  @override
  String get ch1Current => 'ch1Current';

  @override
  String get ch2Voltage => 'ch2Voltage';

  @override
  String get ch2Current => 'ch2Current';

  @override
  String get ch3Voltage => 'ch3Voltage';

  @override
  String get ch3Current => 'ch3Current';

  @override
  String get numPacketsTx => 'numPacketsTx';

  @override
  String get numPacketsRx => 'numPacketsRx';

  @override
  String get numPacketsRxBad => 'numPacketsRxBad';

  @override
  String get numOnlineNodes => 'numOnlineNodes';

  @override
  String get heartBpm => 'heartBpm';

  @override
  String get spO2 => 'spO2';

  @override
  String get freememBytes => 'freememBytes';

  @override
  String get diskfree1Bytes => 'diskfree1Bytes';

  @override
  String get diskfree2Bytes => 'diskfree2Bytes';

  @override
  String get diskfree3Bytes => 'diskfree3Bytes';

  @override
  String get load1 => 'load1';

  @override
  String get load5 => 'load5';

  @override
  String get load15 => 'load15';

  @override
  String get userString => 'userString';

  @override
  String get wifiPsk => 'wifiPsk';

  @override
  String get ntpServer => 'ntpServer';

  @override
  String get ethEnabled => 'ethEnabled';

  @override
  String get addressMode => 'addressMode';

  @override
  String get rsyslogServer => 'rsyslogServer';

  @override
  String get enabledProtocols => 'enabledProtocols';

  @override
  String get ipv6Enabled => 'ipv6Enabled';

  @override
  String get ip => 'ip';

  @override
  String get gateway => 'gateway';

  @override
  String get subnet => 'subnet';

  @override
  String get dns => 'dns';

  @override
  String get displaymode => 'displaymode';

  @override
  String get usePreset => 'usePreset';

  @override
  String get bandwidth => 'bandwidth';

  @override
  String get spreadFactor => 'spreadFactor';

  @override
  String get codingRate => 'codingRate';

  @override
  String get frequencyOffset => 'frequencyOffset';

  @override
  String get channelNum => 'channelNum';

  @override
  String get overrideDutyCycle => 'overrideDutyCycle';

  @override
  String get sx126xRxBoostedGain => 'sx126xRxBoostedGain';

  @override
  String get overrideFrequency => 'overrideFrequency';

  @override
  String get paFanDisabled => 'paFanDisabled';

  @override
  String get ignoreIncoming => 'ignoreIncoming';

  @override
  String get ignoreMqtt => 'ignoreMqtt';

  @override
  String get configOkToMqtt => 'configOkToMqtt';

  @override
  String get adminKeyCount => 'adminKeyCount';

  @override
  String get encryptionEnabled => 'encryptionEnabled';

  @override
  String get jsonEnabled => 'jsonEnabled';

  @override
  String get tlsEnabled => 'tlsEnabled';

  @override
  String get root => 'root';

  @override
  String get proxyToClientEnabled => 'proxyToClientEnabled';

  @override
  String get mapReportingEnabled => 'mapReportingEnabled';

  @override
  String get publishIntervalSecs => 'publishIntervalSecs';

  @override
  String get positionPrecision => 'positionPrecision';

  @override
  String get shouldReportLocation => 'shouldReportLocation';

  @override
  String get environmentMeasurementEnabled => 'environmentMeasurementEnabled';

  @override
  String get environmentScreenEnabled => 'environmentScreenEnabled';

  @override
  String get environmentDisplayFahrenheit => 'environmentDisplayFahrenheit';

  @override
  String get airQualityEnabled => 'airQualityEnabled';

  @override
  String get powerMeasurementEnabled => 'powerMeasurementEnabled';

  @override
  String get powerScreenEnabled => 'powerScreenEnabled';

  @override
  String get healthMeasurementEnabled => 'healthMeasurementEnabled';

  @override
  String get healthScreenEnabled => 'healthScreenEnabled';

  @override
  String get deviceTelemetryEnabled => 'deviceTelemetryEnabled';

  @override
  String get overrideConsoleSerialPort => 'overrideConsoleSerialPort';

  @override
  String get alertMessageVibra => 'alertMessageVibra';

  @override
  String get alertMessageBuzzer => 'alertMessageBuzzer';

  @override
  String get alertBellVibra => 'alertBellVibra';

  @override
  String get alertBellBuzzer => 'alertBellBuzzer';

  @override
  String get availablePinsCount => 'availablePinsCount';

  @override
  String get gpioPin => 'gpioPin';

  @override
  String get inputbrokerPinA => 'inputbrokerPinA';

  @override
  String get inputbrokerPinB => 'inputbrokerPinB';

  @override
  String get inputbrokerPinPress => 'inputbrokerPinPress';

  @override
  String get inputbrokerEventCw => 'inputbrokerEventCw';

  @override
  String get inputbrokerEventCcw => 'inputbrokerEventCcw';

  @override
  String get inputbrokerEventPress => 'inputbrokerEventPress';

  @override
  String get updown1Enabled => 'updown1Enabled';

  @override
  String get enabledDeprecated => 'enabled(deprecated)';

  @override
  String get minimumBroadcastSecs => 'minimumBroadcastSecs';

  @override
  String get detectionTriggerType => 'detectionTriggerType';

  @override
  String get lateFallbackEnabled => 'lateFallbackEnabled';

  @override
  String get fallbackTailPercent => 'fallbackTailPercent';

  @override
  String get milestonesEnabled => 'milestonesEnabled';

  @override
  String get perDestMinSpacingMs => 'perDestMinSpacingMs';

  @override
  String get maxActiveDm => 'maxActiveDm';

  @override
  String get probeFwplusNearDeadline => 'probeFwplusNearDeadline';

  @override
  String get allowedPorts => 'allowedPorts';

  @override
  String get localStatsOverMeshEnabled => 'localStatsOverMeshEnabled';

  @override
  String get localStatsExtendedOverMeshEnabled =>
      'localStatsExtendedOverMeshEnabled';

  @override
  String get additionalChutil => 'additionalChutil';

  @override
  String get additionalTxutil => 'additionalTxutil';

  @override
  String get additionalPoliteChannelPercent => 'additionalPoliteChannelPercent';

  @override
  String get additionalPoliteDutyCyclePercent =>
      'additionalPoliteDutyCyclePercent';

  @override
  String get currentTxUtilLimit => 'currentTxUtilLimit';

  @override
  String get currentMaxChannelUtilPercent => 'currentMaxChannelUtilPercent';

  @override
  String get currentPoliteChannelUtilPercent =>
      'currentPoliteChannelUtilPercent';

  @override
  String get currentPoliteDutyCyclePercent => 'currentPoliteDutyCyclePercent';

  @override
  String get autoRedirectTargetNodeId => 'autoRedirectTargetNodeId';

  @override
  String get telemetryLimiterEnabled => 'telemetryLimiterEnabled';

  @override
  String get telemetryLimiterPacketsPerMinute =>
      'telemetryLimiterPacketsPerMinute';

  @override
  String get telemetryLimiterAutoChanutilEnabled =>
      'telemetryLimiterAutoChanutilEnabled';

  @override
  String get telemetryLimiterAutoChanutilThreshold =>
      'telemetryLimiterAutoChanutilThreshold';

  @override
  String get positionLimiterEnabled => 'positionLimiterEnabled';

  @override
  String get positionLimiterTimeMinutesThreshold =>
      'positionLimiterTimeMinutesThreshold';

  @override
  String get opportunisticFloodingEnabled => 'opportunisticFloodingEnabled';

  @override
  String get opportunisticBaseDelayMs => 'opportunisticBaseDelayMs';

  @override
  String get opportunisticHopDelayMs => 'opportunisticHopDelayMs';

  @override
  String get opportunisticSnrGainMs => 'opportunisticSnrGainMs';

  @override
  String get opportunisticJitterMs => 'opportunisticJitterMs';

  @override
  String get opportunisticCancelOnFirstHear => 'opportunisticCancelOnFirstHear';

  @override
  String get opportunisticAuto => 'opportunisticAuto';

  @override
  String get version => 'version';

  @override
  String get screenBrightness => 'screenBrightness';

  @override
  String get screenTimeout => 'screenTimeout';

  @override
  String get screenLock => 'screenLock';

  @override
  String get settingsLock => 'settingsLock';

  @override
  String get pinCode => 'pinCode';

  @override
  String get theme => 'theme';

  @override
  String get alertEnabled => 'alertEnabled';

  @override
  String get bannerEnabled => 'bannerEnabled';

  @override
  String get ringToneId => 'ringToneId';

  @override
  String get language => 'language';

  @override
  String get compassMode => 'compassMode';

  @override
  String get screenRgbColor => 'screenRgbColor';

  @override
  String get isClockfaceAnalog => 'isClockfaceAnalog';

  @override
  String get gpsFormat => 'gpsFormat';

  @override
  String get calibrationDataLen => 'calibrationDataLen';

  @override
  String get filterEnabled => 'filterEnabled';

  @override
  String get minSnr => 'minSnr';

  @override
  String get hideIgnoredNodes => 'hideIgnoredNodes';

  @override
  String get highlightEnabled => 'highlightEnabled';

  @override
  String get zoom => 'zoom';

  @override
  String get centerLatI => 'centerLatI';

  @override
  String get centerLonI => 'centerLonI';

  @override
  String get followMe => 'followMe';

  @override
  String get psk => 'psk';

  @override
  String get uplinkEnabled => 'uplinkEnabled';

  @override
  String get downlinkEnabled => 'downlinkEnabled';

  @override
  String get ownerEditTitle => 'Edytuj Właściciela';

  @override
  String get ownerLongName => 'Pełna Nazwa';

  @override
  String get ownerShortName => 'Krótka Nazwa';

  @override
  String get ownerLongNameHint => 'np. Jan Kowalski';

  @override
  String get ownerShortNameHint => 'np. JK';

  @override
  String get ownerLongNameHelper => 'Pełna nazwa dla tego urządzenia';

  @override
  String get ownerShortNameHelper => 'Krótka nazwa (maks. 4 znaki)';

  @override
  String get ownerEditAtLeastOneName =>
      'Podaj przynajmniej jedną nazwę (długą lub krótką)';

  @override
  String get ownerUpdateSuccess =>
      'Informacje o właścicielu zaktualizowane pomyślnie';

  @override
  String ownerUpdateFailed(Object error) {
    return 'Błąd aktualizacji informacji o właścicielu: $error';
  }

  @override
  String get configHelpTitle => 'Pomoc Konfiguracji';

  @override
  String get readMoreDocumentation => 'Czytaj więcej w dokumentacji';

  @override
  String get editTooltip => 'Edytuj';

  @override
  String get deviceRoleLabel => 'Rola';

  @override
  String get serialEnabledLabel => 'Port Szeregowy Włączony';

  @override
  String get serialEnabledSubtitle => 'Przestarzałe (upstream)';

  @override
  String get buttonGpioLabel => 'GPIO Przycisku';

  @override
  String get buzzerGpioLabel => 'GPIO Brzęczyka';

  @override
  String get rebroadcastModeLabel => 'Tryb Retransmisji';

  @override
  String get nodeInfoBroadcastIntervalLabel =>
      'Interwał Rozgłaszania Info o Węźle (sekundy)';

  @override
  String get nodeInfoBroadcastIntervalHint =>
      'Jak często rozgłaszać info o węźle';

  @override
  String get doubleTapAsButtonPressLabel => 'Podwójne Stuknięcie jako Przycisk';

  @override
  String get isManagedLabel => 'Zarządzany';

  @override
  String get disableTripleClickLabel => 'Wyłącz Potrójne Kliknięcie';

  @override
  String get timezoneDefinitionLabel => 'Definicja Strefy Czasowej';

  @override
  String get timezoneDefinitionHint => 'np. CET-1CEST,M3.5.0,M10.5.0/3';

  @override
  String get ledHeartbeatDisabledLabel => 'Dioda Heartbeat Wyłączona';

  @override
  String get buzzerModeLabel => 'Tryb Brzęczyka';

  @override
  String get positionBroadcastIntervalLabel =>
      'Interwał Rozgłaszania Pozycji (sekundy)';

  @override
  String get smartPositionBroadcastLabel => 'Inteligentne Rozgłaszanie Pozycji';

  @override
  String get fixedPositionLabel => 'Stała Pozycja';

  @override
  String get gpsEnabledLabel => 'GPS Włączony';

  @override
  String get gpsUpdateIntervalLabel => 'Interwał Aktualizacji GPS (sekundy)';

  @override
  String get gpsAttemptTimeLabel => 'Czas Próby GPS (sekundy)';

  @override
  String get positionFlagsLabel => 'Flagi Pozycji';

  @override
  String get rxGpioLabel => 'RX GPIO';

  @override
  String get txGpioLabel => 'TX GPIO';

  @override
  String get smartBroadcastMinDistanceLabel =>
      'Min. Dystans Smart Rozgłaszania';

  @override
  String get smartBroadcastMinIntervalLabel =>
      'Min. Interwał Smart Rozgłaszania (sekundy)';

  @override
  String get gpsEnableGpioLabel => 'GPIO Włączenia GPS';

  @override
  String get gpsModeLabel => 'Tryb GPS';
}
