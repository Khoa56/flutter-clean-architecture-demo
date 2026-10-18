import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import 'injection.config.dart';

/// Composition root là nơi biết cách ghép implementation cụ thể.
/// Config và client được cung cấp sẵn; injectable sinh các đăng ký còn lại.
@InjectableInit(
  preferRelativeImports: true,
  ignoreUnregisteredTypes: [AppConfig, http.Client],
)
void configureDependencies(GetIt container, AppConfig config) {
  container.registerSingleton<AppConfig>(config);
  container.registerLazySingleton<http.Client>(
    http.Client.new,
    dispose: (client) => client.close(),
  );
  container.init();
}
