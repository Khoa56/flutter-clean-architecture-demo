import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import 'post_data_source.dart';

final class PostRemoteDataSource implements PostDataSource {
  const PostRemoteDataSource({
    required http.Client client,
    required Uri baseUrl,
    Duration timeout = const Duration(seconds: 12),
  }) : _client = client,
       _baseUrl = baseUrl,
       _timeout = timeout;

  final http.Client _client;
  final Uri _baseUrl;
  final Duration _timeout;

  Future<Object?> _get(String path) async {
    final response = await _client
        .get(_baseUrl.resolve(path), headers: {'Accept': 'application/json'})
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw HttpStatusException(response.statusCode);
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  @override
  Future<List<PostModel>> getPosts() async {
    final json = await _get('posts');
    if (json is! List<Object?>) {
      throw const FormatException('Expected a list of posts');
    }
    return json.map(PostModel.fromJson).toList(growable: false);
  }

  @override
  Future<PostModel> getPost(int id) async =>
      PostModel.fromJson(await _get('posts/$id'));
}
