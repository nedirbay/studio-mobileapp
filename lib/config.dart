class Config {
  // For Gemymotion use 10.0.3.2, for real device use your LAN IP via --dart-define.
  static String backendHost = const String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: '10.0.3.2:8000',
  );

  // Use HTTPS for production domains, HTTP for local development (Genymotion, emulator, LAN)
  static String get _scheme => (backendHost.contains('10.0.') || 
                                backendHost.contains('192.168.') || 
                                backendHost.contains('127.0.0.1') || 
                                backendHost.contains('localhost')) ? 'http' : 'https';

  static String get apiBaseUrl => '$_scheme://$backendHost/api';
  static String get mediaBaseUrl => '$_scheme://$backendHost';
  static String get _wsScheme => _scheme == 'https' ? 'wss' : 'ws';
  static String get wsBaseUrl => '$_wsScheme://$backendHost';

  static String activeCurrencySymbol = 'TMT';
}
