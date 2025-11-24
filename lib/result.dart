// Generic Result type for operations that can fail
// Similar to Either or Result types in other languages
typedef VoidCallback = void Function();

abstract class Result<T> {
  const Result();

  R when<R>({
    required R Function(T) success,
    required R Function(Object) failure,
  });

  Result<T> onSuccess(void Function(T) cb) {
    when(success: (v) => cb(v), failure: (e) {});
    return this;
  }

  Result<T> onFailure(void Function(Object) cb) {
    when(success: (v) {}, failure: (e) => cb(e));
    return this;
  }

  Result<R> map<R>(R Function(T) f) {
    return when(
      success: (v) => Success<R>(f(v)),
      failure: (e) => Failure<R>(e),
    );
  }

  T? get valueOrNull {
    return when(success: (v) => v, failure: (e) => null);
  }

  T valueOr(T defaultValue) {
    return when(success: (v) => v, failure: (e) => defaultValue);
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  R when<R>({
    required R Function(T) success,
    required R Function(Object) failure,
  }) {
    return success(value);
  }
}

class Failure<T> extends Result<T> {
  final Object error;
  const Failure(this.error);

  @override
  R when<R>({
    required R Function(T) success,
    required R Function(Object) failure,
  }) {
    return failure(error);
  }
}
