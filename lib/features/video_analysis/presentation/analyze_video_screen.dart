import 'package:captain/core/config/app_config.dart';
import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/video_analysis/application/backend_availability_provider.dart';
import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';
import 'package:captain/features/video_analysis/domain/selected_video_file.dart';
import 'package:captain/features/video_analysis/domain/youtube_url_validator.dart';
import 'package:captain/features/video_analysis/presentation/widgets/backend_unavailable_banner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum AnalyzeVideoSource {
  upload,
  youtube,
}

class AnalyzeVideoScreen extends ConsumerStatefulWidget {
  const AnalyzeVideoScreen({super.key});

  @override
  ConsumerState<AnalyzeVideoScreen> createState() => _AnalyzeVideoScreenState();
}

class _AnalyzeVideoScreenState extends ConsumerState<AnalyzeVideoScreen> {
  AnalyzeVideoSource _source = AnalyzeVideoSource.upload;
  SelectedVideoFile? _selectedVideo;
  final _youtubeController = TextEditingController();
  var _youtubeTouched = false;
  var _isStarting = false;

  static const _allowedExtensions = ['mp4', 'mov', 'mkv'];

  bool get _canStartAnalysis {
    return switch (_source) {
      AnalyzeVideoSource.upload => _selectedVideo != null,
      AnalyzeVideoSource.youtube =>
        YoutubeUrlValidator.isValid(_youtubeController.text),
    };
  }

  bool get _backendReady {
    final availability = ref.watch(backendAvailabilityProvider);
    return availability.maybeWhen(
      data: (value) => value == BackendAvailability.available,
      orElse: () => false,
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
      withReadStream: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null) return;

    setState(() => _selectedVideo = SelectedVideoFile.fromPath(path));
  }

  Future<void> _startAnalysis() async {
    if (!_canStartAnalysis || !_backendReady || _isStarting) return;

    setState(() => _isStarting = true);

    final repository = ref.read(videoAnalysisRepositoryProvider);
    final quotaResult = await repository.checkAnalysisQuota();
    if (!mounted) return;

    if (quotaResult.isFailure || quotaResult.valueOrNull != true) {
      setState(() => _isStarting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video analysis quota reached. Try again later.'),
        ),
      );
      return;
    }

    final args = switch (_source) {
      AnalyzeVideoSource.upload => VideoProcessingArgs.upload(
          filePath: _selectedVideo!.path,
          label: _selectedVideo!.name,
        ),
      AnalyzeVideoSource.youtube => VideoProcessingArgs.youtube(
          youtubeUrl: _youtubeController.text.trim(),
        ),
    };

    setState(() => _isStarting = false);
    if (!mounted) return;
    context.push(AppRoutes.analyzeVideoProcessing, extra: args);
  }

  @override
  Widget build(BuildContext context) {
    final availability = ref.watch(backendAvailabilityProvider);
    final backendUrl =
        ref.watch(appPreferencesProvider).value?.effectiveBackendUrl ??
            AppConfig.visionApiBaseUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Match Video'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _AnalysisInfoBanner(
                maxMinutes: AppConfig.maxVideoDurationMinutes,
              ),
            ),
            availability.when(
              loading: () => const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: LinearProgressIndicator(minHeight: 2),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: BackendUnavailableBanner(
                  backendUrl: backendUrl,
                  onRetry: () => ref
                      .read(backendAvailabilityProvider.notifier)
                      .refresh(),
                ),
              ),
              data: (value) {
                if (value == BackendAvailability.available) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: BackendUnavailableBanner(
                    backendUrl: backendUrl,
                    onRetry: () => ref
                        .read(backendAvailabilityProvider.notifier)
                        .refresh(),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<AnalyzeVideoSource>(
                segments: const [
                  ButtonSegment(
                    value: AnalyzeVideoSource.upload,
                    label: Text('Upload video'),
                    icon: Icon(Icons.upload_file_outlined),
                  ),
                  ButtonSegment(
                    value: AnalyzeVideoSource.youtube,
                    label: Text('YouTube link'),
                    icon: Icon(Icons.link_outlined),
                  ),
                ],
                selected: {_source},
                onSelectionChanged: (selection) {
                  setState(() => _source = selection.first);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _source == AnalyzeVideoSource.upload
                      ? _UploadVideoPanel(
                          key: const ValueKey('upload'),
                          selectedVideo: _selectedVideo,
                          onPickVideo: _pickVideo,
                        )
                      : SingleChildScrollView(
                          key: const ValueKey('youtube'),
                          child: _YoutubeLinkPanel(
                            controller: _youtubeController,
                            showValidationError: _youtubeTouched,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: () =>
                                setState(() => _youtubeTouched = true),
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _canStartAnalysis && _backendReady && !_isStarting
                    ? _startAnalysis
                    : null,
                icon: _isStarting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle_outline),
                label: Text(_isStarting ? 'Checking…' : 'Start analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisInfoBanner extends StatelessWidget {
  const _AnalysisInfoBanner({required this.maxMinutes});

  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.accentOrange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Video analysis takes several minutes depending on clip length. '
              'For best accuracy, use clips under $maxMinutes minutes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadVideoPanel extends StatelessWidget {
  const _UploadVideoPanel({
    super.key,
    required this.selectedVideo,
    required this.onPickVideo,
  });

  final SelectedVideoFile? selectedVideo;
  final VoidCallback onPickVideo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedVideo == null)
          Expanded(
            child: Center(
              child: OutlinedButton.icon(
                onPressed: onPickVideo,
                icon: const Icon(Icons.video_library_outlined),
                label: const Text('Choose video'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _SelectedVideoCard(video: selectedVideo!),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onPickVideo,
                  icon: const Icon(Icons.swap_horiz_outlined),
                  label: const Text('Choose a different video'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Supported formats: MP4, MOV, MKV',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SelectedVideoCard extends StatelessWidget {
  const _SelectedVideoCard({required this.video});

  final SelectedVideoFile video;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.pitchGreen.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.pitchLine),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 56,
                    color: AppColors.pitchGreenLight,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Video ready for analysis',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              video.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Size: ${video.formattedSize}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _YoutubeLinkPanel extends StatelessWidget {
  const _YoutubeLinkPanel({
    required this.controller,
    required this.showValidationError,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool showValidationError;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final url = controller.text.trim();
    final isValid = YoutubeUrlValidator.isValid(url);
    final showError = showValidationError && url.isNotEmpty && !isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paste a public YouTube match clip link',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'We download the clip for analysis. Private or deleted videos are not supported.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://youtube.com/watch?v=...',
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showError ? AppColors.accentRed : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: showError
                    ? AppColors.accentRed
                    : AppColors.pitchGreenLight,
              ),
            ),
            errorText: showError ? 'Enter a valid YouTube URL' : null,
            prefixIcon: const Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
          onEditingComplete: onSubmitted,
        ),
        if (isValid)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: AppColors.pitchGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pitchLine),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.pitchGreenLight),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Link looks valid and ready to analyze.'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
