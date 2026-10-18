import 'package:clean_reader/features/posts/domain/entities/post.dart';
import 'package:clean_reader/features/posts/domain/failures/app_failure.dart';
import 'package:clean_reader/features/posts/domain/repositories/post_repository.dart';
import 'package:clean_reader/features/posts/domain/usecases/filter_posts.dart';
import 'package:clean_reader/features/posts/domain/usecases/get_post_detail.dart';
import 'package:clean_reader/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

const first = Post(
  id: 1,
  authorId: 1,
  title: 'Dart cơ bản',
  body: 'Học Future',
);
const second = Post(
  id: 2,
  authorId: 2,
  title: 'Flutter',
  body: 'Dart và widget',
);
const third = Post(id: 3, authorId: 1, title: 'Kiến trúc', body: 'Repository');

void main() {
  late MockPostRepository repository;
  setUp(() => repository = MockPostRepository());

  group('GetPosts - mock abstract interface, không cần API', () {
    test('trả dữ liệu và gọi Repository đúng một lần', () async {
      const result = Success<List<Post>>([first, second]);
      when(() => repository.getPosts()).thenAnswer((_) async => result);
      expect(await GetPosts(repository)(), same(result));
      verify(() => repository.getPosts()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test(
      'truyền lỗi Domain cho tầng gọi, không nuốt lỗi thành danh sách rỗng',
      () async {
        const result = Failure<List<Post>>(AppFailure(FailureKind.network));
        when(() => repository.getPosts()).thenAnswer((_) async => result);
        expect(await GetPosts(repository)(), same(result));
      },
    );

    test('phân biệt API trả danh sách rỗng với thất bại', () async {
      when(
        () => repository.getPosts(),
      ).thenAnswer((_) async => const Success<List<Post>>([]));
      final result = await GetPosts(repository)();
      expect(result, isA<Success<List<Post>>>());
      expect((result as Success<List<Post>>).value, isEmpty);
    });
  });

  group('GetPostDetail', () {
    test('truyền chính xác ID vào Repository', () async {
      when(
        () => repository.getPost(2),
      ).thenAnswer((_) async => const Success(second));
      final result = await GetPostDetail(repository)(2);
      expect((result as Success<Post>).value, same(second));
      verify(() => repository.getPost(2)).called(1);
    });
    for (final id in [0, -1]) {
      test('ID $id không hợp lệ: không gọi Repository', () async {
        final result = await GetPostDetail(repository)(id);
        expect((result as Failure<Post>).error.kind, FailureKind.notFound);
        verifyZeroInteractions(repository);
      });
    }
    test('trả lỗi không tìm thấy từ Repository', () async {
      when(() => repository.getPost(99)).thenAnswer(
        (_) async => const Failure(AppFailure(FailureKind.notFound)),
      );
      final result = await GetPostDetail(repository)(99);
      expect((result as Failure<Post>).error.kind, FailureKind.notFound);
    });
  });

  group('FilterPosts - quy tắc nghiệp vụ thuần Dart', () {
    const filter = FilterPosts();
    final posts = [first, second, third];

    test('mặc định ID giảm dần, không sửa danh sách đầu vào', () {
      expect(filter(posts, const PostQuery()).map((p) => p.id), [3, 2, 1]);
      expect(posts.map((p) => p.id), [1, 2, 3]);
    });
    test('tìm không phân biệt hoa thường, loại khoảng trắng hai đầu', () {
      expect(
        filter(posts, const PostQuery(text: '  DART  ')).map((p) => p.id),
        [2, 1],
      );
    });
    test('tìm trong nội dung bài viết', () {
      expect(filter(posts, const PostQuery(text: 'Repository')).single, third);
    });
    test('lọc đồng thời tác giả và từ khóa', () {
      expect(filter(posts, const PostQuery(text: 'dart', authorId: 1)), [
        first,
      ]);
    });
    test('ID tăng dần khi yêu cầu', () {
      expect(
        filter(posts, const PostQuery(newestFirst: false)).map((p) => p.id),
        [1, 2, 3],
      );
    });
    test('không có kết quả phù hợp', () {
      expect(filter(posts, const PostQuery(text: 'xyz987')), isEmpty);
    });
    test('danh sách đầu vào rỗng', () {
      expect(filter([], const PostQuery()), isEmpty);
    });
    test('kết quả không thể bị UI sửa trực tiếp', () {
      final result = filter(posts, const PostQuery());
      expect(() => result.clear(), throwsUnsupportedError);
    });
  });
}
