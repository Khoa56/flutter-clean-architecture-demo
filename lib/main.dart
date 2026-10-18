import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'features/posts/presentation/cubit/post_detail_cubit.dart';
import 'features/posts/presentation/cubit/posts_cubit.dart';

void main() {
  // Khởi tạo binding trước khi composition root sử dụng Flutter services.
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final container = GetIt.asNewInstance();
  configureDependencies(container, config);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PostsCubit>(
          create: (_) => container<PostsCubit>()..load(),
        ),
      ],
      child: ReaderApp(
        createDetailCubit: () => container<PostDetailCubit>(),
        useFixture: config.useFixture,
      ),
    ),
  );
}
