class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String authApiBaseUrl = '$apiBaseUrl/api/v1/auth';

  static const String userMeUrl = '$apiBaseUrl/api/v1/user/me';
}
