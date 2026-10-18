enum FailureKind { network, timeout, server, notFound, invalidData, unknown }

/// Lỗi ở mức nghiệp vụ. UI không cần đọc mã HTTP hoặc bắt ClientException.
final class AppFailure {
  const AppFailure(this.kind);

  final FailureKind kind;
}

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppFailure error;
}
