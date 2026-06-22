import 'package:captain/core/network/video_analysis_failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  VideoAnalysisFailure? get failureOrNull => switch (this) {
        Success() => null,
        Failure(:final failure) => failure,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(VideoAnalysisFailure failure) onFailure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failure(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final VideoAnalysisFailure failure;
}
