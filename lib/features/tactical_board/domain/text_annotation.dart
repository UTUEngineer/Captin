import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_annotation.freezed.dart';
part 'text_annotation.g.dart';

@freezed
abstract class TextAnnotation with _$TextAnnotation {
  const factory TextAnnotation({
    required String id,
    required double x,
    required double y,
    required String text,
    @Default(false) bool locked,
    @Default(0) int zIndex,
  }) = _TextAnnotation;

  factory TextAnnotation.fromJson(Map<String, dynamic> json) =>
      _$TextAnnotationFromJson(json);
}
