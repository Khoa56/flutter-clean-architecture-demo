import '../entities/post.dart';
import '../failures/app_failure.dart';
import '../repositories/post_repository.dart';

final class GetPostDetail {
  const GetPostDetail(this._repository);
  final PostRepository _repository;

  Future<Result<Post>> call(int id) {
    if (id <= 0) {
      return Future.value(const Failure(AppFailure(FailureKind.notFound)));
    }
    return _repository.getPost(id);
  }
}
