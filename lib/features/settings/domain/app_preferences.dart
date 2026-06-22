import 'package:captain/core/config/app_config.dart';
import 'package:captain/features/export/domain/export_hub_context.dart';
import 'package:captain/features/settings/domain/app_language.dart';
import 'package:captain/features/settings/domain/app_theme_variant.dart';
import 'package:captain/features/settings/domain/coach_role.dart';

class AppPreferences {
  const AppPreferences({
    this.onboardingCompleted = false,
    this.language = AppLanguage.arabic,
    this.themeVariant = AppThemeVariant.dark,
    this.hapticFeedbackEnabled = true,
    this.displayName = '',
    this.teamName = '',
    this.teamColorValue = 0xFF2E7D32,
    this.avatarEmoji = '⚽',
    this.coachRole = CoachRole.headCoach,
    this.defaultSessionName = '',
    this.autoJoinLastSession = false,
    this.defaultExportFormat = ExportFileFormat.png,
    this.defaultExportQuality = ExportQuality.standard,
    this.exportWatermarkEnabled = true,
    this.backendBaseUrl = '',
  });

  final bool onboardingCompleted;
  final AppLanguage language;
  final AppThemeVariant themeVariant;
  final bool hapticFeedbackEnabled;
  final String displayName;
  final String teamName;
  final int teamColorValue;
  final String avatarEmoji;
  final CoachRole coachRole;
  final String defaultSessionName;
  final bool autoJoinLastSession;
  final ExportFileFormat defaultExportFormat;
  final ExportQuality defaultExportQuality;
  final bool exportWatermarkEnabled;
  final String backendBaseUrl;

  String get effectiveBackendUrl {
    final trimmed = backendBaseUrl.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return AppConfig.visionApiBaseUrl;
  }

  bool get isArabic => language == AppLanguage.arabic;

  AppPreferences copyWith({
    bool? onboardingCompleted,
    AppLanguage? language,
    AppThemeVariant? themeVariant,
    bool? hapticFeedbackEnabled,
    String? displayName,
    String? teamName,
    int? teamColorValue,
    String? avatarEmoji,
    CoachRole? coachRole,
    String? defaultSessionName,
    bool? autoJoinLastSession,
    ExportFileFormat? defaultExportFormat,
    ExportQuality? defaultExportQuality,
    bool? exportWatermarkEnabled,
    String? backendBaseUrl,
  }) {
    return AppPreferences(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      language: language ?? this.language,
      themeVariant: themeVariant ?? this.themeVariant,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      displayName: displayName ?? this.displayName,
      teamName: teamName ?? this.teamName,
      teamColorValue: teamColorValue ?? this.teamColorValue,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      coachRole: coachRole ?? this.coachRole,
      defaultSessionName: defaultSessionName ?? this.defaultSessionName,
      autoJoinLastSession: autoJoinLastSession ?? this.autoJoinLastSession,
      defaultExportFormat: defaultExportFormat ?? this.defaultExportFormat,
      defaultExportQuality: defaultExportQuality ?? this.defaultExportQuality,
      exportWatermarkEnabled:
          exportWatermarkEnabled ?? this.exportWatermarkEnabled,
      backendBaseUrl: backendBaseUrl ?? this.backendBaseUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onboardingCompleted': onboardingCompleted,
      'language': language.code,
      'themeVariant': themeVariant.name,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'displayName': displayName,
      'teamName': teamName,
      'teamColorValue': teamColorValue,
      'avatarEmoji': avatarEmoji,
      'coachRole': coachRole.wireName,
      'defaultSessionName': defaultSessionName,
      'autoJoinLastSession': autoJoinLastSession,
      'defaultExportFormat': defaultExportFormat.name,
      'defaultExportQuality': defaultExportQuality.name,
      'exportWatermarkEnabled': exportWatermarkEnabled,
      'backendBaseUrl': backendBaseUrl,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      language: AppLanguage.fromCode(json['language'] as String?),
      themeVariant: AppThemeVariant.fromWire(json['themeVariant'] as String?),
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] as bool? ?? true,
      displayName: json['displayName'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      teamColorValue: json['teamColorValue'] as int? ?? 0xFF2E7D32,
      avatarEmoji: json['avatarEmoji'] as String? ?? '⚽',
      coachRole: CoachRole.fromWire(json['coachRole'] as String?),
      defaultSessionName: json['defaultSessionName'] as String? ?? '',
      autoJoinLastSession: json['autoJoinLastSession'] as bool? ?? false,
      defaultExportFormat: ExportFileFormat.values.firstWhere(
        (format) => format.name == json['defaultExportFormat'],
        orElse: () => ExportFileFormat.png,
      ),
      defaultExportQuality: ExportQuality.values.firstWhere(
        (quality) => quality.name == json['defaultExportQuality'],
        orElse: () => ExportQuality.standard,
      ),
      exportWatermarkEnabled: json['exportWatermarkEnabled'] as bool? ?? true,
      backendBaseUrl: json['backendBaseUrl'] as String? ?? '',
    );
  }
}

const teamColorSwatches = <int>[
  0xFF2E7D32,
  0xFF1565C0,
  0xFFE53935,
  0xFFFF6D00,
  0xFF6A1B9A,
  0xFF00838F,
  0xFF4527A0,
  0xFFAD1457,
  0xFF558B2F,
  0xFF283593,
  0xFF4E342E,
  0xFF37474F,
];

const avatarEmojiOptions = <String>[
  '⚽',
  '🦁',
  '🦅',
  '🐺',
  '🔥',
  '⭐',
  '🏆',
  '🛡️',
  '🎯',
  '👑',
];
