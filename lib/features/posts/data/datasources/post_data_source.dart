import '../models/post_model.dart';

abstract interface class PostDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPost(int id);
}

final class HttpStatusException implements Exception {
  const HttpStatusException(this.statusCode);
  final int statusCode;
}
