import 'dart:async';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../domain/entities/post.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_data_source.dart';

final class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl(this._dataSource);
  final PostDataSource _dataSource;

  @override
  Future<Result<List<Post>>> getPosts() => _guard(() async {
    final models = await _dataSource.getPosts();
    return List.unmodifiable(models.map((model) => model.toEntity()));
  });

  @override
  Future<Result<Post>> getPost(int id) =>
      _guard(() async => (await _dataSource.getPost(id)).toEntity());

  /// Chuyển lỗi hạ tầng thành kiểu lỗi Domain tại biên Data/Domain.
  Future<Result<T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } on TimeoutException {
      return const Failure(AppFailure(FailureKind.timeout));
    } on http.ClientException {
      return const Failure(AppFailure(FailureKind.network));
    } on HttpStatusException catch (error) {
      return Failure(
        AppFailure(
          error.statusCode == 404 ? FailureKind.notFound : FailureKind.server,
        ),
      );
    } on FormatException {
      return const Failure(AppFailure(FailureKind.invalidData));
    } catch (error, stackTrace) {
      // Không ghi body/token; lưu lỗi bất ngờ để phục vụ chẩn đoán.
      developer.log(
        'Unexpected repository failure',
        name: 'PostRepository',
        error: error,
        stackTrace: stackTrace,
      );
      return const Failure(AppFailure(FailureKind.unknown));
    }
  }
}
