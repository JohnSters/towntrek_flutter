/// Result type for handling operations that can succeed or fail
/// This follows the Result pattern commonly used in functional programming
sealed class Result<T> {
  const Result();

  /// Creates a successful result
  factory Result.success(T data) = Success<T>;

  /// Creates a failed result
  factory Result.failure(String error, [dynamic originalError]) = Failure<T>;

  /// Whether this result represents success
  bool get isSuccess => this is Success<T>;

  /// Whether this result represents failure
  bool get isFailure => this is Failure<T>;

  /// Gets the data if successful, otherwise throws
  T get data => switch (this) {
        Success(:final data) => data,
        Failure(:final error, :final originalError) =>
          throw ResultException(error, originalError),
      };

  /// Gets the error message if failed, otherwise null
  String? get error => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Gets the original error if failed, otherwise null
  dynamic get originalError => switch (this) {
        Success() => null,
        Failure(:final originalError) => originalError,
      };

  /// Maps the successful data to a new type
  Result<R> map<R>(R Function(T data) mapper) => switch (this) {
        Success(:final data) => Result.success(mapper(data)),
        Failure(:final error, :final originalError) => Result.failure(error, originalError),
      };

  /// Maps the successful data to a new result
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) => switch (this) {
        Success(:final data) => mapper(data),
        Failure(:final error, :final originalError) => Result.failure(error, originalError),
      };

  /// Handles both success and failure cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error, dynamic originalError) onFailure,
  }) =>
      switch (this) {
        Success(:final data) => onSuccess(data),
        Failure(:final error, :final originalError) => onFailure(error, originalError),
      };

  /// Executes the provided function if successful
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Executes the provided function if failed
  Result<T> onFailure(void Function(String error, dynamic originalError) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).error, (this as Failure<T>).originalError);
    }
    return this;
  }
}

/// Successful result containing data
class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Failed result containing error information
class Failure<T> extends Result<T> {
  @override
  final String error;
  @override
  final dynamic originalError;

  const Failure(this.error, [this.originalError]);

  @override
  String toString() => 'Failure($error${originalError != null ? ', $originalError' : ''})';
}

/// Exception thrown when trying to access data from a failed result
class ResultException implements Exception {
  final String message;
  final dynamic originalError;

  const ResultException(this.message, [this.originalError]);

  @override
  String toString() => 'ResultException: $message${originalError != null ? ', $originalError' : ''}';
}

/// Extension methods for working with Results in async operations
extension ResultAsyncExtension<T> on Future<Result<T>> {
  /// Maps successful async results
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    final result = await this;
    return result.fold(
      onSuccess: (data) async => Result.success(await mapper(data)),
      onFailure: (error, originalError) => Result.failure(error, originalError),
    );
  }

  /// Flat maps successful async results
  Future<Result<R>> flatMapAsync<R>(Future<Result<R>> Function(T data) mapper) async {
    final result = await this;
    return result.fold(
      onSuccess: mapper,
      onFailure: (error, originalError) => Future.value(Result.failure(error, originalError)),
    );
  }
}

/// Extension methods for working with Results in collections
extension ResultListExtension<T> on Result<List<T>> {
  /// Maps each item in a successful list result
  Result<List<R>> mapList<R>(R Function(T item) mapper) {
    return map((list) => list.map(mapper).toList());
  }

  /// Filters items in a successful list result
  Result<List<T>> whereList(bool Function(T item) predicate) {
    return map((list) => list.where(predicate).toList());
  }
}
