part of 'results.dart';

typedef FtrResult<S, E> = Future<Result<S, E>>;
typedef FtrSuccess<S, E> = Future<Result<S, E>>;
typedef FtrError<S, E> = Future<Result<S, E>>;

extension FtrResultExt<S, E> on FtrResult<S, E> {
  Future<S> getOrThrow() async {
    return (await this).getOrThrow();
  }

  FtrResult<S?, E> nullable() async {
    return (await this).nullable();
  }

  Future<T> when<T>(
      {required T Function(S data) success,
      required T Function(E error) error}) async {
    return (await this).when(success: success, error: error);
  }

  FtrResult<S2, E> mapOnSuccess<S2>(
    FutureOr<Result<S2, E>> Function(S data) mapper,
  ) async {
    return switch (await this) {
      Success<S, E> sucs => await mapper(sucs.data),
      Error<S, E> err => Error(err.error),
    };
  }

  FtrResult<S, E2> mapOnError<E2>(
    FutureOr<Result<S, E2>> Function(E err) mapper,
  ) async {
    return switch (await this) {
      Success<S, E> sucs => Success(sucs.data),
      Error<S, E> err => await mapper(err.error),
    };
  }

  FtrResult<S, E> onSuccess(void Function(S data) onSuccess) async {
    return (await this).onSuccess(onSuccess);
  }

  FtrResult<S, E> onError(void Function(E error) onError) async {
    return (await this).onError(onError);
  }

  Future<Success<S, E>> resolve({required S Function(E error) onError}) async {
    return (await this).resolve(onError: onError);
  }

  Future<void> execute() async {
    return (await this).execute();
  }

  FtrResult<S2, E> mapSuccess<S2>(S2 Function(S data) mapper) async {
    return (await this).mapSuccess(mapper);
  }

  FtrResult<S, E2> mapError<E2>(E2 Function(E err) mapper) async {
    return (await this).mapError(mapper);
  }

  Future<(S?, E?)> flat() async {
    return (await this).flat();
  }

  Future<bool> get isSuccess async => (await this) is Success<S, E>;
  Future<bool> get isError async => (await this) is Error<S, E>;
}

extension FtrSuccessExt<S, E> on Future<Success<S, E>> {
  Future<S> get data async => (await this).data;
  Future<X> map<X extends Result>(
    X Function(S data) mapper,
  ) async {
    return (await this).map(mapper);
  }

  Future<(S, E?)> flat() async {
    return (await this).flat();
  }
}
