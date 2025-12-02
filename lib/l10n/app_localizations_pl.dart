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
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

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
  String get coordinates => 'Coordinates';

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
  String get apply => 'Apply';

  @override
  String get searchEvents => 'Search events';

  @override
  String get searchInSummaryOrTags => 'Search in summary or tags';

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
}
