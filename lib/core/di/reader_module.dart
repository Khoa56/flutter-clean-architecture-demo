import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../features/posts/data/datasources/post_data_source.dart';
import '../../features/posts/data/datasources/post_fixture_data_source.dart';
import '../../features/posts/data/datasources/post_remote_data_source.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';
import '../../features/posts/domain/repositories/post_repository.dart';
import '../../features/posts/domain/usecases/filter_posts.dart';
import '../../features/posts/domain/usecases/get_post_detail.dart';
import '../../features/posts/domain/usecases/get_posts.dart';
import '../../features/posts/presentation/cubit/post_detail_cubit.dart';
import '../../features/posts/presentation/cubit/posts_cubit.dart';
import '../config/app_config.dart';

/// Annotation nằm ở composition root, Domain không phụ thuộc injectable.
@module
abstract class ReaderModule {
  @lazySingleton
  PostDataSource postDataSource(AppConfig config, http.Client client) =>
      config.useFixture
      ? PostFixtureDataSource(
          () => rootBundle.loadString('assets/fixtures/posts.json'),
        )
      : PostRemoteDataSource(client: client, baseUrl: config.baseUrl);

  @lazySingleton
  PostRepository repository(PostDataSource source) =>
      PostRepositoryImpl(source);

  @lazySingleton
  GetPosts getPosts(PostRepository repository) => GetPosts(repository);

  @lazySingleton
  GetPostDetail getPostDetail(PostRepository repository) =>
      GetPostDetail(repository);

  @lazySingleton
  FilterPosts get filterPosts => const FilterPosts();

  // Module method mặc định là factory; mỗi route sở hữu Cubit riêng.
  PostsCubit postsCubit(GetPosts getPosts, FilterPosts filterPosts) =>
      PostsCubit(getPosts, filterPosts);

  PostDetailCubit detailCubit(GetPostDetail getPostDetail) =>
      PostDetailCubit(getPostDetail);
}
