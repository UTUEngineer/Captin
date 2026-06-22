import 'package:captain/core/constants/app_constants.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/export/domain/export_hub_context.dart';
import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/presentation/widgets/football_api_key_dialog.dart';
import 'package:captain/features/scouting/application/scouting_providers.dart';
import 'package:captain/features/scouting/presentation/widgets/claude_api_key_dialog.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/settings/application/local_data_controller.dart';
import 'package:captain/features/settings/domain/app_language.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/settings/domain/app_theme_variant.dart';
import 'package:captain/features/settings/domain/coach_role.dart';
import 'package:captain/features/settings/presentation/legal_document_screen.dart';
import 'package:captain/features/settings/presentation/widgets/data_practices_summary.dart';
import 'package:captain/features/settings/presentation/widgets/emoji_picker_sheet.dart';
import 'package:captain/features/video_analysis/application/analysis_cache_providers.dart';
import 'package:captain/features/video_analysis/application/backend_availability_provider.dart';
import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/shared/widgets/pulsing_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _teamController;
  late final TextEditingController _sessionController;
  late final TextEditingController _backendController;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _teamController = TextEditingController();
    _sessionController = TextEditingController();
    _backendController = TextEditingController();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    _sessionController.dispose();
    _backendController.dispose();
    super.dispose();
  }

  Future<void> _updatePrefs(AppPreferences Function(AppPreferences) updater) {
    final current = ref.read(appPreferencesProvider).value ?? const AppPreferences();
    return ref.read(appPreferencesProvider.notifier).savePreferences(updater(current));
  }

  Future<void> _confirmClearCache(BuildContext context, bool isArabic) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'مسح النتائج المحفوظة؟' : 'Clear saved results?'),
        content: Text(
          isArabic
              ? 'سيتم حذف نتائج تحليل الفيديو من هذا الجهاز.'
              : 'This removes cached video analysis data from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isArabic ? 'مسح' : 'Clear'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) return;
    final clearedCount =
        await ref.read(analysisCacheControllerProvider).clearSavedResults();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          clearedCount == 0
              ? (isArabic ? 'لا توجد نتائج محفوظة.' : 'No cached results.')
              : (isArabic
                  ? 'تم مسح $clearedCount نتيجة.'
                  : 'Cleared $clearedCount result(s).'),
        ),
      ),
    );
  }

  Future<void> _testBackend(bool isArabic) async {
    ref.invalidate(videoAnalysisRepositoryProvider);
    ref.invalidate(backendAvailabilityProvider);
    await ref.read(backendAvailabilityProvider.future);
    if (!mounted) return;
    final status = ref.read(backendAvailabilityProvider).value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == BackendAvailability.available
              ? (isArabic ? 'الاتصال بالخادم ناجح.' : 'Backend connection OK.')
              : (isArabic ? 'تعذر الاتصال بالخادم.' : 'Backend connection failed.'),
        ),
      ),
    );
  }

  Future<void> _openContact(bool isArabic) async {
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=Captain%20App',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تعذر فتح البريد.' : 'Could not open mail client.',
          ),
        ),
      );
    }
  }

  Future<void> _openPrivacyPolicy(bool isArabic) async {
    final url = AppConstants.privacyPolicyUrl;
    if (url.isNotEmpty) {
      await _openExternalUrl(url, isArabic);
      return;
    }

    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => LegalDocumentScreen(
          title: isArabic ? 'سياسة الخصوصية' : 'Privacy policy',
          assetPath: AppConstants.bundledPrivacyPolicyAsset,
        ),
      ),
    );
  }

  Future<void> _openExternalUrl(String url, bool isArabic) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تعذر فتح الرابط.' : 'Could not open link.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmClearAllLocalData(BuildContext context, bool isArabic) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'مسح جميع البيانات المحلية؟' : 'Clear all local data?'),
        content: Text(
          isArabic
              ? 'سيتم حذف الإعدادات، اللوحات المحفوظة، نتائج التحليل، ومفاتيح Claude وAPI-Football من هذا الجهاز. لا يمكن التراجع.'
              : 'This removes settings, saved boards, analysis cache, and your Claude and API-Football keys from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              isArabic ? 'مسح الكل' : 'Clear all',
              style: const TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );

    if (shouldClear != true || !context.mounted) return;
    await ref.read(localDataControllerProvider).clearAllLocalData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم مسح البيانات المحلية.' : 'Local data cleared.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(appPreferencesProvider);
    final cacheCountAsync = ref.watch(analysisCacheEntryCountProvider);
    final backendAsync = ref.watch(backendAvailabilityProvider);
    final apiKeyConfigured = ref.watch(claudeApiKeyConfiguredProvider);
    final footballApiConfigured = ref.watch(footballApiKeyConfiguredProvider);

    return prefsAsync.when(
      loading: () => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonList(itemCount: 4, itemHeight: 88),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(child: Text('$error')),
      ),
      data: (prefs) {
        if (_nameController.text != prefs.displayName) {
          _nameController.text = prefs.displayName;
        }
        if (_teamController.text != prefs.teamName) {
          _teamController.text = prefs.teamName;
        }
        if (_sessionController.text != prefs.defaultSessionName) {
          _sessionController.text = prefs.defaultSessionName;
        }
        if (_backendController.text != prefs.backendBaseUrl) {
          _backendController.text = prefs.backendBaseUrl;
        }

        final isArabic = prefs.isArabic;
        final textStyle = isArabic ? GoogleFonts.cairo() : null;

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                isArabic ? 'الإعدادات' : 'Settings',
                style: textStyle,
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(
                  title: isArabic ? 'الحساب' : 'Account',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    ListTile(
                      leading: Text(prefs.avatarEmoji, style: const TextStyle(fontSize: 28)),
                      title: Text(isArabic ? 'الصورة الرمزية' : 'Avatar'),
                      subtitle: Text(isArabic ? 'اختر رمزاً' : 'Pick an emoji'),
                      onTap: () => EmojiPickerSheet.show(
                        context,
                        selectedEmoji: prefs.avatarEmoji,
                        onSelected: (emoji) => _updatePrefs(
                          (current) => current.copyWith(avatarEmoji: emoji),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الاسم' : 'Name',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _updatePrefs(
                        (current) => current.copyWith(displayName: value.trim()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _teamController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الفريق' : 'Team',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _updatePrefs(
                        (current) => current.copyWith(teamName: value.trim()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CoachRole>(
                      value: prefs.coachRole,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الدور' : 'Role',
                        border: const OutlineInputBorder(),
                      ),
                      items: CoachRole.values
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                isArabic ? role.arabicLabel : role.englishLabel,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (role) {
                        if (role == null) return;
                        _updatePrefs((current) => current.copyWith(coachRole: role));
                      },
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'التطبيق' : 'App',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    Text(isArabic ? 'اللغة' : 'Language'),
                    SegmentedButton<AppLanguage>(
                      segments: AppLanguage.values
                          .map(
                            (language) => ButtonSegment(
                              value: language,
                              label: Text(language.label),
                            ),
                          )
                          .toList(),
                      selected: {prefs.language},
                      onSelectionChanged: (value) => _updatePrefs(
                        (current) => current.copyWith(language: value.first),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(isArabic ? 'المظهر' : 'Theme'),
                    SegmentedButton<AppThemeVariant>(
                      segments: AppThemeVariant.values
                          .map(
                            (variant) => ButtonSegment(
                              value: variant,
                              label: Text(
                                isArabic ? variant.arabicLabel : variant.englishLabel,
                              ),
                            ),
                          )
                          .toList(),
                      selected: {prefs.themeVariant},
                      onSelectionChanged: (value) => _updatePrefs(
                        (current) => current.copyWith(themeVariant: value.first),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'الاهتزاز اللمسي' : 'Haptic feedback'),
                      value: prefs.hapticFeedbackEnabled,
                      onChanged: (value) => _updatePrefs(
                        (current) => current.copyWith(hapticFeedbackEnabled: value),
                      ),
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'الذكاء الاصطناعي' : 'AI',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    apiKeyConfigured.when(
                      data: (configured) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          configured ? Icons.check_circle : Icons.key_off_outlined,
                          color: configured
                              ? AppColors.pitchGreenLight
                              : AppColors.accentOrange,
                        ),
                        title: Text(isArabic ? 'مفتاح Claude API' : 'Claude API key'),
                        subtitle: Text(
                          configured
                              ? (isArabic ? 'تم الإعداد • sk-ant-••••' : 'Configured • sk-ant-••••')
                              : (isArabic ? 'غير مُعد بعد' : 'Not configured yet'),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => ClaudeApiKeyDialog.show(context),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    Text(
                      isArabic
                          ? 'النموذج: claude-sonnet-4-20250514'
                          : 'Model: claude-sonnet-4-20250514',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'الدوريات والبيانات' : 'Leagues & data',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    footballApiConfigured.when(
                      data: (configured) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          configured ? Icons.check_circle : Icons.key_off_outlined,
                          color: configured
                              ? AppColors.pitchGreenLight
                              : AppColors.accentOrange,
                        ),
                        title: Text(
                          isArabic ? 'مفتاح API-Football' : 'API-Football key',
                        ),
                        subtitle: Text(
                          configured
                              ? (isArabic ? 'تم الإعداد' : 'Configured')
                              : (isArabic ? 'غير مُعد بعد' : 'Not configured yet'),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => FootballApiKeyDialog.show(context),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    Text(
                      isArabic
                          ? 'TODO(release): تحقق من ترخيص api-football.com لعرض الشعارات تجارياً.'
                          : 'TODO(release): Verify api-football.com logo/branding rights for commercial use.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'التعاون' : 'Collaboration',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    TextField(
                      controller: _sessionController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'اسم الجلسة الافتراضي' : 'Default session name',
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _updatePrefs(
                        (current) => current.copyWith(defaultSessionName: value.trim()),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isArabic
                            ? 'الانضمام تلقائياً لآخر جلسة'
                            : 'Auto-join last session',
                      ),
                      value: prefs.autoJoinLastSession,
                      onChanged: (value) => _updatePrefs(
                        (current) => current.copyWith(autoJoinLastSession: value),
                      ),
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'التصدير' : 'Export',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    DropdownButtonFormField<ExportFileFormat>(
                      value: prefs.defaultExportFormat,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'صيغة التصدير الافتراضية' : 'Default export format',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        ExportFileFormat.png,
                        ExportFileFormat.pdf,
                        ExportFileFormat.gif,
                      ]
                          .map(
                            (format) => DropdownMenuItem(
                              value: format,
                              child: Text(format.label),
                            ),
                          )
                          .toList(),
                      onChanged: (format) {
                        if (format == null) return;
                        _updatePrefs(
                          (current) => current.copyWith(defaultExportFormat: format),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ExportQuality>(
                      value: prefs.defaultExportQuality,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'جودة PDF' : 'PDF quality',
                        border: const OutlineInputBorder(),
                      ),
                      items: ExportQuality.values
                          .map(
                            (quality) => DropdownMenuItem(
                              value: quality,
                              child: Text(quality.label),
                            ),
                          )
                          .toList(),
                      onChanged: (quality) {
                        if (quality == null) return;
                        _updatePrefs(
                          (current) => current.copyWith(defaultExportQuality: quality),
                        );
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'علامة مائية' : 'Watermark'),
                      value: prefs.exportWatermarkEnabled,
                      onChanged: (value) => _updatePrefs(
                        (current) => current.copyWith(exportWatermarkEnabled: value),
                      ),
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'الخادم' : 'Server',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    TextField(
                      controller: _backendController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'رابط الخادم' : 'Backend URL',
                        hintText: prefs.effectiveBackendUrl,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (value) async {
                        await _updatePrefs(
                          (current) => current.copyWith(backendBaseUrl: value.trim()),
                        );
                        ref.invalidate(videoAnalysisRepositoryProvider);
                        ref.invalidate(backendAvailabilityProvider);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatusDot(
                          isOnline: backendAsync.value == BackendAvailability.available,
                          isLoading: backendAsync.isLoading,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          backendAsync.when(
                            data: (status) => switch (status) {
                              BackendAvailability.available =>
                                isArabic ? 'متصل' : 'Connected',
                              BackendAvailability.unavailable =>
                                isArabic ? 'غير متصل' : 'Offline',
                              BackendAvailability.checking =>
                                isArabic ? 'جاري الفحص…' : 'Checking…',
                            },
                            loading: () => isArabic ? 'جاري الفحص…' : 'Checking…',
                            error: (_, __) => isArabic ? 'خطأ' : 'Error',
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => _testBackend(isArabic),
                          child: Text(isArabic ? 'اختبار الاتصال' : 'Test connection'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_outline, color: AppColors.accentRed),
                      title: Text(isArabic ? 'مسح نتائج التحليل' : 'Clear analysis cache'),
                      subtitle: cacheCountAsync.maybeWhen(
                        data: (count) => Text('$count'),
                        orElse: () => const Text('…'),
                      ),
                      onTap: () => _confirmClearCache(context, isArabic),
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'الخصوصية والبيانات' : 'Privacy & data',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    DataPracticesSummary(isArabic: isArabic),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'سياسة الخصوصية' : 'Privacy policy'),
                      trailing: Icon(
                        AppConstants.privacyPolicyUrl.isEmpty
                            ? Icons.article_outlined
                            : Icons.open_in_new,
                      ),
                      onTap: () => _openPrivacyPolicy(isArabic),
                    ),
                    if (AppConstants.termsOfServiceUrl.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(isArabic ? 'شروط الاستخدام' : 'Terms of service'),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _openExternalUrl(
                          AppConstants.termsOfServiceUrl,
                          isArabic,
                        ),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever_outlined, color: AppColors.accentRed),
                      title: Text(isArabic ? 'مسح جميع البيانات المحلية' : 'Clear all local data'),
                      subtitle: Text(
                        isArabic
                            ? 'يحذف الإعدادات والمحتوى المحفوظ على الجهاز'
                            : 'Removes settings and saved content on this device',
                      ),
                      onTap: () => _confirmClearAllLocalData(context, isArabic),
                    ),
                  ],
                ),
                _SectionHeader(
                  title: isArabic ? 'حول' : 'About',
                  style: textStyle,
                ),
                _SettingsCard(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'الإصدار' : 'Version'),
                      subtitle: Text(
                        _packageInfo == null
                            ? '…'
                            : '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'تواصل معنا' : 'Contact us'),
                      trailing: const Icon(Icons.mail_outline),
                      onTap: () => _openContact(isArabic),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'التراخيص مفتوحة المصدر' : 'Open source licenses'),
                      trailing: const Icon(Icons.article_outlined),
                      onTap: () => showLicensePage(context: context),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isArabic ? 'مصدر بيانات الدوريات' : 'League data provider'),
                      subtitle: const Text('api-football.com / API-Sports'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.style});

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: style ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.isOnline,
    required this.isLoading,
  });

  final bool isOnline;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = isLoading
        ? AppColors.accentOrange
        : isOnline
            ? AppColors.pitchGreenLight
            : AppColors.accentRed;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
