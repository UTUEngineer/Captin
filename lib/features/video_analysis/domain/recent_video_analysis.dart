class RecentVideoAnalysis {
  const RecentVideoAnalysis({
    required this.videoId,
    required this.label,
    required this.completedAt,
  });

  factory RecentVideoAnalysis.fromJson(Map<String, dynamic> json) {
    return RecentVideoAnalysis(
      videoId: json['video_id'] as String,
      label: json['label'] as String? ?? 'Video analysis',
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String videoId;
  final String label;
  final DateTime completedAt;

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'label': label,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
