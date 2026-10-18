import '../entities/post.dart';
import '../failures/app_failure.dart';
import '../repositories/post_repository.dart';

final class GetPosts {
  const GetPosts(this._repository);
  final PostRepository _repository;

  Future<Result<List<Post>>> call() => _repository.getPosts();
}
