// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoStatusResponse _$VideoStatusResponseFromJson(Map<String, dynamic> json) =>
    _VideoStatusResponse(
      videoId: json['video_id'] as String,
      status: json['status'] as String,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
      jobId: json['job_id'] as String?,
    );

Map<String, dynamic> _$VideoStatusResponseToJson(
  _VideoStatusResponse instance,
) => <String, dynamic>{
  'video_id': instance.videoId,
  'status': instance.status,
  'progress_percent': instance.progressPercent,
  'message': instance.message,
  'job_id': instance.jobId,
};
