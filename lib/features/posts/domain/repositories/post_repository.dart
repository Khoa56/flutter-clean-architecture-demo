import '../entities/post.dart';
import '../failures/app_failure.dart';

/// Abstraction thuộc Domain. Data phải triển khai hợp đồng này (DIP).
abstract interface class PostRepository {
  Future<Result<List<Post>>> getPosts();
  Future<Result<Post>> getPost(int id);
}
