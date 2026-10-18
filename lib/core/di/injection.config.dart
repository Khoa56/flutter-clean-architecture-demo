// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/posts/data/datasources/post_data_source.dart' as _i1003;
import '../../features/posts/domain/repositories/post_repository.dart' as _i450;
import '../../features/posts/domain/usecases/filter_posts.dart' as _i485;
import '../../features/posts/domain/usecases/get_post_detail.dart' as _i751;
import '../../features/posts/domain/usecases/get_posts.dart' as _i1032;
import '../../features/posts/presentation/cubit/post_detail_cubit.dart' as _i76;
import '../../features/posts/presentation/cubit/posts_cubit.dart' as _i21;
import '../config/app_config.dart' as _i650;
import 'reader_module.dart' as _i33;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final readerModule = _$ReaderModule();
    gh.lazySingleton<_i485.FilterPosts>(() => readerModule.filterPosts);
    gh.lazySingleton<_i1003.PostDataSource>(
      () => readerModule.postDataSource(
        gh<_i650.AppConfig>(),
        gh<_i519.Client>(),
      ),
    );
    gh.lazySingleton<_i450.PostRepository>(
      () => readerModule.repository(gh<_i1003.PostDataSource>()),
    );
    gh.lazySingleton<_i1032.GetPosts>(
      () => readerModule.getPosts(gh<_i450.PostRepository>()),
    );
    gh.lazySingleton<_i751.GetPostDetail>(
      () => readerModule.getPostDetail(gh<_i450.PostRepository>()),
    );
    gh.factory<_i21.PostsCubit>(
      () => readerModule.postsCubit(
        gh<_i1032.GetPosts>(),
        gh<_i485.FilterPosts>(),
      ),
    );
    gh.factory<_i76.PostDetailCubit>(
      () => readerModule.detailCubit(gh<_i751.GetPostDetail>()),
    );
    return this;
  }
}

class _$ReaderModule extends _i33.ReaderModule {}
