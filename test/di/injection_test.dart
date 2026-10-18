import 'package:clean_reader/core/config/app_config.dart';
import 'package:clean_reader/core/di/injection.dart';
import 'package:clean_reader/features/posts/data/datasources/post_data_source.dart';
import 'package:clean_reader/features/posts/data/datasources/post_fixture_data_source.dart';
import 'package:clean_reader/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:clean_reader/features/posts/domain/repositories/post_repository.dart';
import 'package:clean_reader/features/posts/domain/usecases/get_posts.dart';
import 'package:clean_reader/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  late GetIt container;
  setUp(() => container = GetIt.asNewInstance());
  tearDown(() => container.reset());

  test(
    'production dùng REST, repository/usecase lazy singleton, Cubit factory',
    () async {
      configureDependencies(
        container,
        AppConfig(baseUrl: Uri.parse('https://example.test/')),
      );
      expect(container<PostDataSource>(), isA<PostRemoteDataSource>());
      expect(container<PostRepository>(), same(container<PostRepository>()));
      expect(container<GetPosts>(), same(container<GetPosts>()));
      final first = container<PostsCubit>();
      final second = container<PostsCubit>();
      expect(first, isNot(same(second)));
      await first.close();
      await second.close();
    },
  );
  test(
    'đổi DataSource bằng cấu hình DI, vẫn giữ nguyên lớp UseCase và Cubit',
    () async {
      configureDependencies(
        container,
        AppConfig(
          baseUrl: Uri.parse('https://example.test/'),
          useFixture: true,
        ),
      );
      expect(container<PostDataSource>(), isA<PostFixtureDataSource>());
      expect(container<GetPosts>(), isA<GetPosts>());
      final cubit = container<PostsCubit>();
      await cubit.close();
    },
  );
}
