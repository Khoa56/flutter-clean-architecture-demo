import 'package:clean_reader/app.dart';
import 'package:clean_reader/core/config/app_config.dart';
import 'package:clean_reader/core/di/injection.dart';
import 'package:clean_reader/features/posts/data/datasources/post_data_source.dart';
import 'package:clean_reader/features/posts/data/datasources/post_fixture_data_source.dart';
import 'package:clean_reader/features/posts/presentation/cubit/post_detail_cubit.dart';
import 'package:clean_reader/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  Future<GetIt> pumpReader(WidgetTester tester, Size size) async {
    // Đọc asset bằng đồng hồ thật, tránh chờ I/O trong fake clock của widget test.
    final fixture = (await tester.runAsync(
      () => rootBundle.loadString('assets/fixtures/posts.json'),
    ))!;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = GetIt.asNewInstance();
    configureDependencies(
      container,
      AppConfig(baseUrl: Uri.parse('https://example.test/'), useFixture: true),
    );
    await container.unregister<PostDataSource>();
    container.registerLazySingleton<PostDataSource>(
      () => PostFixtureDataSource(() async => fixture),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await container.reset();
    });
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => container<PostsCubit>()..load(),
        child: ReaderApp(
          useFixture: true,
          createDetailCubit: () => container<PostDetailCubit>(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('tải, tìm kiếm, xóa bộ lọc trên màn hình ${size.width}', (
      tester,
    ) async {
      await pumpReader(tester, size);
      expect(find.text('6 bài viết'), findsOneWidget);
      expect(find.text('Đang dùng dữ liệu mẫu'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'không-có-bài-này');
      await tester.pumpAndSettle();
      expect(find.text('0 bài viết'), findsOneWidget);
      expect(find.text('Không tìm thấy bài viết phù hợp.'), findsOneWidget);
      await tester.tap(find.byTooltip('Xóa tìm kiếm'));
      await tester.pumpAndSettle();
      expect(find.text('6 bài viết'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('mở chi tiết qua UseCase rồi quay lại danh sách', (tester) async {
    await pumpReader(tester, const Size(1280, 900));
    final title = find.text('Học bằng cách thử và quan sát');
    await tester.ensureVisible(title);
    await tester.tap(title);
    await tester.pumpAndSettle();
    expect(find.text('Đọc bài viết'), findsOneWidget);
    expect(find.text('Bài 6 · 1 phút đọc'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Dành cho bạn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
