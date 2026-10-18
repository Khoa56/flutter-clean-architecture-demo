import 'dart:async';
import 'dart:convert';

import 'package:clean_reader/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:clean_reader/features/posts/data/repositories/post_repository_impl.dart';
import 'package:clean_reader/features/posts/domain/entities/post.dart';
import 'package:clean_reader/features/posts/domain/failures/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const postJson = {
  'id': 7,
  'userId': 2,
  'title': 'Tiếng Việt',
  'body': 'Nội dung',
};

void main() {
  PostRepositoryImpl createRepository(
    Future<http.Response> Function(http.Request) handler, {
    Duration timeout = const Duration(seconds: 1),
  }) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return PostRepositoryImpl(
      PostRemoteDataSource(
        client: client,
        baseUrl: Uri.parse('https://example.test/api/'),
        timeout: timeout,
      ),
    );
  }

  http.Response jsonResponse(Object value) => http.Response(
    jsonEncode(value),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  test(
    'GET danh sách đúng URL, map userId thành authorId, đọc UTF-8',
    () async {
      final repo = createRepository((request) async {
        expect(request.url.toString(), 'https://example.test/api/posts');
        expect(request.method, 'GET');
        return jsonResponse([postJson]);
      });
      final result = await repo.getPosts() as Success<List<Post>>;
      expect(result.value.single.title, 'Tiếng Việt');
      expect(result.value.single.authorId, 2);
      expect(() => result.value.clear(), throwsUnsupportedError);
    },
  );

  test('GET chi tiết gọi endpoint /posts/id', () async {
    final repo = createRepository((request) async {
      expect(request.url.path, '/api/posts/7');
      return jsonResponse(postJson);
    });
    expect(((await repo.getPost(7)) as Success<Post>).value.id, 7);
  });

  for (final entry in {
    404: FailureKind.notFound,
    500: FailureKind.server,
    401: FailureKind.server,
  }.entries) {
    test('HTTP ${entry.key} -> ${entry.value.name}', () async {
      final repo = createRepository((_) async => http.Response('', entry.key));
      expect(
        ((await repo.getPosts()) as Failure<List<Post>>).error.kind,
        entry.value,
      );
    });
  }
  test('lỗi kết nối -> network', () async {
    final repo = createRepository(
      (_) async => throw http.ClientException('Offline'),
    );
    expect(
      ((await repo.getPosts()) as Failure<List<Post>>).error.kind,
      FailureKind.network,
    );
  });
  test('timeout -> timeout', () async {
    final repo = createRepository((_) async => throw TimeoutException('Slow'));
    expect(
      ((await repo.getPosts()) as Failure<List<Post>>).error.kind,
      FailureKind.timeout,
    );
  });
  test('request vượt thời hạn thực sự được trả lỗi timeout', () async {
    final repo = createRepository(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 5),
    );
    expect(
      ((await repo.getPosts()) as Failure<List<Post>>).error.kind,
      FailureKind.timeout,
    );
  });
  for (final value in <Object>[
    {'wrong': 'object'},
    [
      {'id': '7', 'userId': 2, 'title': 'x', 'body': 'y'},
    ],
    [
      {'id': 7, 'userId': 2, 'title': '', 'body': 'y'},
    ],
    [null],
  ]) {
    test('JSON sai cấu trúc được chuyển thành invalidData: $value', () async {
      final repo = createRepository((_) async => jsonResponse(value));
      expect(
        ((await repo.getPosts()) as Failure<List<Post>>).error.kind,
        FailureKind.invalidData,
      );
    });
  }
  test('JSON không hợp lệ -> invalidData', () async {
    final repo = createRepository((_) async => http.Response('{', 200));
    expect(
      ((await repo.getPosts()) as Failure<List<Post>>).error.kind,
      FailureKind.invalidData,
    );
  });
}
