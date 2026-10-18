import 'dart:async';

import 'package:clean_reader/features/posts/domain/entities/post.dart';
import 'package:clean_reader/features/posts/domain/failures/app_failure.dart';
import 'package:clean_reader/features/posts/domain/repositories/post_repository.dart';
import 'package:clean_reader/features/posts/domain/usecases/filter_posts.dart';
import 'package:clean_reader/features/posts/domain/usecases/get_posts.dart';
import 'package:clean_reader/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

const post = Post(id: 1, authorId: 2, title: 'Dart', body: 'Content');

void main() {
  late MockPostRepository repository;
  late PostsCubit cubit;
  setUp(() {
    repository = MockPostRepository();
    cubit = PostsCubit(GetPosts(repository), const FilterPosts());
  });
  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  test('initial -> loading -> success', () async {
    when(
      () => repository.getPosts(),
    ).thenAnswer((_) async => const Success([post]));
    final states = <LoadStatus>[];
    final sub = cubit.stream.listen((s) => states.add(s.status));
    expect(cubit.state.status, LoadStatus.initial);
    await cubit.load();
    await Future<void>.delayed(Duration.zero);
    expect(states, [LoadStatus.loading, LoadStatus.success]);
    expect(cubit.state.visiblePosts, [post]);
    await sub.cancel();
  });
  test('failure rồi retry thành công', () async {
    when(
      () => repository.getPosts(),
    ).thenAnswer((_) async => const Failure(AppFailure(FailureKind.network)));
    await cubit.load();
    expect(cubit.state.status, LoadStatus.failure);
    when(
      () => repository.getPosts(),
    ).thenAnswer((_) async => const Success([post]));
    await cubit.load();
    expect(cubit.state.status, LoadStatus.success);
    expect(cubit.state.error, isNull);
  });
  test('tìm/lọc chỉ dùng dữ liệu đã tải, không gọi API lần nữa', () async {
    when(
      () => repository.getPosts(),
    ).thenAnswer((_) async => const Success([post]));
    await cubit.load();
    cubit.search('missing');
    expect(cubit.state.visiblePosts, isEmpty);
    cubit.resetFilters();
    expect(cubit.state.visiblePosts, [post]);
    cubit.selectAuthor(3);
    expect(cubit.state.visiblePosts, isEmpty);
    verify(() => repository.getPosts()).called(1);
  });
  test('chỉ chấp nhận phản hồi của lần tải mới nhất', () async {
    final oldRequest = Completer<Result<List<Post>>>();
    var calls = 0;
    when(() => repository.getPosts()).thenAnswer((_) {
      return ++calls == 1
          ? oldRequest.future
          : Future.value(const Success([post]));
    });
    final firstLoad = cubit.load();
    await cubit.load();
    oldRequest.complete(const Failure(AppFailure(FailureKind.network)));
    await firstLoad;
    expect(cubit.state.status, LoadStatus.success);
  });
  test('không emit vào Cubit đã đóng khi request hoàn thành muộn', () async {
    final request = Completer<Result<List<Post>>>();
    when(() => repository.getPosts()).thenAnswer((_) => request.future);
    final pending = cubit.load();
    await cubit.close();
    request.complete(const Success([post]));
    await expectLater(pending, completes);
  });
}
