import 'package:captain/features/video_analysis/domain/video_processing_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_status_response.freezed.dart';
part 'video_status_response.g.dart';

@freezed
abstract class VideoStatusResponse with _$VideoStatusResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VideoStatusResponse({
    required String videoId,
    required String status,
    @Default(0) int progressPercent,
    String? message,
    String? jobId,
  }) = _VideoStatusResponse;

  const VideoStatusResponse._();

  factory VideoStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoStatusResponseFromJson(json);

  VideoProcessingStatus get processingStatus =>
      VideoProcessingStatus.fromApiValue(status);
}
