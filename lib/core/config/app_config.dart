final class AppConfig {
  const AppConfig({required this.baseUrl, this.useFixture = false});

  factory AppConfig.fromEnvironment() {
    const value = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://jsonplaceholder.typicode.com/',
    );
    // Bản Web có thể gọi API cùng máy chủ qua đường dẫn /api/.
    final uri = value.startsWith('/')
        ? Uri.base.resolve(value)
        : Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        !{'http', 'https'}.contains(uri.scheme) ||
        !uri.path.endsWith('/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('API_BASE_URL phải là URL HTTP(S), kết thúc bằng /');
    }
    return AppConfig(
      baseUrl: uri,
      useFixture: const bool.fromEnvironment('USE_FIXTURE'),
    );
  }

  final Uri baseUrl;
  final bool useFixture;
}
