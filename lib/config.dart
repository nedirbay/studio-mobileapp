class Config {
  // For Gemymotion use 10.0.3.2, for real device use your LAN IP via --dart-define.
  static String backendHost = const String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: '10.0.3.2:8000',
  );

  static String get apiBaseUrl => 'http://$backendHost/api';
  static String get mediaBaseUrl => 'http://$backendHost';
}
