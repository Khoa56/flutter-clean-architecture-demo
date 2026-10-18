import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/usecases/get_post_detail.dart';

sealed class PostDetailState {
  const PostDetailState();
}

final class DetailLoading extends PostDetailState {
  const DetailLoading();
}

final class DetailReady extends PostDetailState {
  const DetailReady(this.post);
  final Post post;
}

final class DetailFailed extends PostDetailState {
  const DetailFailed(this.error);
  final AppFailure error;
}

final class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._getPostDetail) : super(const DetailLoading());
  final GetPostDetail _getPostDetail;
  int _requestId = 0;

  Future<void> load(int id) async {
    final requestId = ++_requestId;
    emit(const DetailLoading());
    final result = await _getPostDetail(id);
    if (isClosed || requestId != _requestId) return;
    switch (result) {
      case Success<Post>(:final value):
        emit(DetailReady(value));
      case Failure<Post>(:final error):
        emit(DetailFailed(error));
    }
  }
}
