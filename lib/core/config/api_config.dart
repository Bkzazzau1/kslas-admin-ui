class ApiConfig {
  const ApiConfig._();

  static const String _definedBaseUrl = String.fromEnvironment(
    'KSLAS_API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) {
      return _stripTrailingSlash(_definedBaseUrl);
    }

    final currentOrigin = Uri.base.origin;
    if (currentOrigin.startsWith('http')) {
      return _stripTrailingSlash(currentOrigin);
    }

    return 'http://localhost:8080';
  }

  static Uri uri(String path, [Map<String, String>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath').replace(
      queryParameters: queryParameters,
    );
  }

  static String _stripTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
