library results;

import 'dart:async';

part 'extensions.dart';

sealed class Result<S, E> {
  const Result();

  bool get isSuccess => this is Success<S, E>;
  bool get isError => this is Error<S, E>;

  Result<S?, E> nullable() {
    return when(
      success: (data) => Success(data),
      error: (err) => Error(err),
    );
  }

  T when<T>({
    required T Function(S data) success,
    required T Function(E error) error,
  }) {
    return switch (this) {
      Success<S, E> sucs => success(sucs.data),
      Error<S, E> err => error(err.error),
    };
  }

  S getOrThrow() {
    return when(
      success: (data) => data,
      error: (err) => throw Exception(err),
    );
  }

  Result<S2, E> mapSuccess<S2>(S2 Function(S data) mapper) {
    return switch (this) {
      Success<S, E> sucs => Success(mapper(sucs.data)),
      Error<S, E> err => Error(err.error),
    };
  }

  Result<S2, E> mapOnSuccess<S2>(Result<S2, E> Function(S data) mapper) {
    return switch (this) {
      Success<S, E> sucs => mapper(sucs.data),
      Error<S, E> err => Error(err.error),
    };
  }

  Result<S, E2> mapError<E2>(E2 Function(E err) mapper) {
    return switch (this) {
      Success<S, E> sucs => Success(sucs.data),
      Error<S, E> err => Error(mapper(err.error)),
    };
  }

  Result<S, E2> mapOnError<E2>(Result<S, E2> Function(E err) mapper) {
    return switch (this) {
      Success<S, E> sucs => Success(sucs.data),
      Error<S, E> err => mapper(err.error),
    };
  }

  Result<S, E> onSuccess(void Function(S data) onSuccess) {
    final v = this;
    if (v is Success<S, E>) {
      onSuccess(v.data);
    }
    return this;
  }

  Result<S, E> onError(void Function(E error) onError) {
    final v = this;
    if (v is Error<S, E>) {
      onError(v.error);
    }
    return this;
  }

  Success<S, E> resolve({required S Function(E error) onError}) {
    return switch (this) {
      Success<S, E> sucs => sucs,
      Error<S, E> err => Success(onError(err.error)),
    };
  }

  void execute() {
    when(success: (_) {}, error: (_) {});
  }

  (S?, E?) flat() {
    return when(success: (dta) => (dta, null), error: (e) => (null, e));
  }
}

class Success<S, E> extends Result<S, E> {
  final S data;
  const Success(this.data);

  X map<X extends Result>(
    X Function(S data) mapper,
  ) {
    return mapper(data);
  }

  @override
  toString() {
    return 'Success {data: $data}';
  }

  @override
  (S, E?) flat() {
    return (data, null);
  }
}

class Error<S, E> extends Result<S, E> {
  final E error;
  const Error(this.error);

  X map<X extends Result>(
    X Function(E error) errorMapper,
  ) {
    return errorMapper(error);
  }

  @override
  toString() {
    return 'Error {error: $error}';
  }

  @override
  (S?, E) flat() {
    return (null, error);
  }
}
