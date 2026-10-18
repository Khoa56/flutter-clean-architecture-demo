import 'dart:io';

import 'package:clean_reader/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:clean_reader/features/posts/data/repositories/post_repository_impl.dart';
import 'package:clean_reader/features/posts/domain/entities/post.dart';
import 'package:clean_reader/features/posts/domain/failures/app_failure.dart';
import 'package:clean_reader/features/posts/domain/usecases/get_post_detail.dart';
import 'package:clean_reader/features/posts/domain/usecases/get_posts.dart';
import 'package:http/http.dart' as http;

/// Kiểm tra REST thật qua Data -> Domain, không cần mở giao diện.
Future<void> main() async {
  final client = http.Client();
  try {
    final repository = PostRepositoryImpl(
      PostRemoteDataSource(
        client: client,
        baseUrl: Uri.parse('https://jsonplaceholder.typicode.com/'),
      ),
    );
    final posts = await GetPosts(repository)();
    if (posts case Success<List<Post>>(:final value) when value.isNotEmpty) {
      stdout.writeln('GET /posts: OK (${value.length} posts)');
      final detail = await GetPostDetail(repository)(value.first.id);
      if (detail case Success<Post>(:final value)) {
        stdout.writeln('GET /posts/${value.id}: OK');
        return;
      }
    }
    stderr.writeln('API check failed. Check Internet and API availability.');
    exitCode = 1;
  } finally {
    client.close();
  }
}
