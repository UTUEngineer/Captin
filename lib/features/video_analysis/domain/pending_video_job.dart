import 'package:captain/features/video_analysis/domain/video_processing_status.dart';

class PendingVideoJob {
  const PendingVideoJob({
    required this.videoId,
    required this.label,
    required this.status,
    required this.updatedAt,
  });

  factory PendingVideoJob.fromJson(Map<String, dynamic> json) {
    return PendingVideoJob(
      videoId: json['video_id'] as String,
      label: json['label'] as String? ?? 'Video analysis',
      status: VideoProcessingStatus.fromApiValue(json['status'] as String?),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String videoId;
  final String label;
  final VideoProcessingStatus status;
  final DateTime updatedAt;

  bool get isActive {
    return switch (status) {
      VideoProcessingStatus.completed ||
      VideoProcessingStatus.failed =>
        false,
      _ => true,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'label': label,
      'status': status.apiValue,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PendingVideoJob copyWith({
    String? videoId,
    String? label,
    VideoProcessingStatus? status,
    DateTime? updatedAt,
  }) {
    return PendingVideoJob(
      videoId: videoId ?? this.videoId,
      label: label ?? this.label,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
