class Config {
  // For Gemymotion use 10.0.3.2, for real device use your LAN IP via --dart-define.
  static const String backendHost = String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: '10.0.3.2:8000',
  );

  static const String apiBaseUrl = 'http://$backendHost/api';
  static const String mediaBaseUrl = 'http://$backendHost';
}
