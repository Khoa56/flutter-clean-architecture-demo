import '../../domain/entities/post.dart';

/// DTO chịu trách nhiệm kiểm tra dữ liệu JSON và chuyển thành Entity.
final class PostModel {
  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory PostModel.fromJson(Object? json) {
    if (json case {
      'id': final int id,
      'userId': final int userId,
      'title': final String title,
      'body': final String body,
    } when id > 0 && userId > 0 && title.trim().isNotEmpty) {
      return PostModel(id: id, userId: userId, title: title, body: body);
    }
    throw const FormatException('Invalid post JSON');
  }

  final int id;
  final int userId;
  final String title;
  final String body;

  Post toEntity() => Post(id: id, authorId: userId, title: title, body: body);
}
