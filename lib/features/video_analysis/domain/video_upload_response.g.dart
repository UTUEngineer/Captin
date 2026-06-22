// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoUploadResponse _$VideoUploadResponseFromJson(Map<String, dynamic> json) =>
    _VideoUploadResponse(
      videoId: json['video_id'] as String,
      status: json['status'] as String,
      durationSeconds: (json['duration_seconds'] as num).toDouble(),
    );

Map<String, dynamic> _$VideoUploadResponseToJson(
  _VideoUploadResponse instance,
) => <String, dynamic>{
  'video_id': instance.videoId,
  'status': instance.status,
  'duration_seconds': instance.durationSeconds,
};
