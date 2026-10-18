import 'dart:convert';

import '../models/post_model.dart';
import 'post_data_source.dart';

/// Chỉ được DI chọn khi USE_FIXTURE=true. Không tự thay thế lỗi mạng.
/// Loader được truyền từ composition root, Data không import Flutter.
final class PostFixtureDataSource implements PostDataSource {
  const PostFixtureDataSource(this._loadJson);
  final Future<String> Function() _loadJson;

  @override
  Future<List<PostModel>> getPosts() async {
    final json = jsonDecode(await _loadJson());
    if (json is! List<Object?>) {
      throw const FormatException('Expected fixture list');
    }
    return json.map(PostModel.fromJson).toList(growable: false);
  }

  @override
  Future<PostModel> getPost(int id) async {
    final posts = await getPosts();
    for (final post in posts) {
      if (post.id == id) return post;
    }
    throw const HttpStatusException(404);
  }
}
