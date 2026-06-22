import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_upload_response.freezed.dart';
part 'video_upload_response.g.dart';

@freezed
abstract class VideoUploadResponse with _$VideoUploadResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VideoUploadResponse({
    required String videoId,
    required String status,
    required double durationSeconds,
  }) = _VideoUploadResponse;

  factory VideoUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoUploadResponseFromJson(json);
}
