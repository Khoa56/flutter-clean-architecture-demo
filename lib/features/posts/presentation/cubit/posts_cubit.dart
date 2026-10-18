import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/usecases/filter_posts.dart';
import '../../domain/usecases/get_posts.dart';

enum LoadStatus { initial, loading, success, failure }

final class PostsState {
  const PostsState({
    this.status = LoadStatus.initial,
    this.allPosts = const [],
    this.visiblePosts = const [],
    this.query = const PostQuery(),
    this.error,
  });

  final LoadStatus status;
  final List<Post> allPosts;
  final List<Post> visiblePosts;
  final PostQuery query;
  final AppFailure? error;

  List<int> get authorIds =>
      (allPosts.map((p) => p.authorId).toSet().toList()..sort());
}

/// Cubit chỉ nhận UseCase qua constructor. Không biết DataSource/GetIt/HTTP.
final class PostsCubit extends Cubit<PostsState> {
  PostsCubit(this._getPosts, this._filterPosts) : super(const PostsState());
  final GetPosts _getPosts;
  final FilterPosts _filterPosts;
  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(
      PostsState(
        status: LoadStatus.loading,
        allPosts: state.allPosts,
        visiblePosts: state.visiblePosts,
        query: state.query,
      ),
    );
    final result = await _getPosts();
    // Bỏ kết quả cũ khi tải lại hoặc màn hình đã bị đóng.
    if (isClosed || requestId != _requestId) return;
    switch (result) {
      case Success<List<Post>>(:final value):
        final posts = List<Post>.unmodifiable(value);
        emit(
          PostsState(
            status: LoadStatus.success,
            allPosts: posts,
            visiblePosts: _filterPosts(posts, state.query),
            query: state.query,
          ),
        );
      case Failure<List<Post>>(:final error):
        emit(
          PostsState(
            status: LoadStatus.failure,
            allPosts: state.allPosts,
            visiblePosts: state.visiblePosts,
            query: state.query,
            error: error,
          ),
        );
    }
  }

  void search(String text) => _apply(
    PostQuery(
      text: text,
      authorId: state.query.authorId,
      newestFirst: state.query.newestFirst,
    ),
  );

  void selectAuthor(int? id) => _apply(
    PostQuery(
      text: state.query.text,
      authorId: id,
      newestFirst: state.query.newestFirst,
    ),
  );

  void setNewestFirst(bool value) => _apply(
    PostQuery(
      text: state.query.text,
      authorId: state.query.authorId,
      newestFirst: value,
    ),
  );

  void resetFilters() => _apply(const PostQuery());

  void _apply(PostQuery query) {
    emit(
      PostsState(
        status: state.status,
        allPosts: state.allPosts,
        visiblePosts: _filterPosts(state.allPosts, query),
        query: query,
        error: state.error,
      ),
    );
  }
}
