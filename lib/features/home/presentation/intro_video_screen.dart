import 'dart:async';

import 'package:captain/core/router/app_router.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

const introVideoAsset = 'assets/video/intro.mp4';

/// Plays the Captain intro clip on every launch. Tap anywhere or "Skip" to
/// continue. Falls back to the splash immediately on platforms without a
/// video backend (e.g. Windows desktop, widget tests).
class IntroVideoScreen extends ConsumerStatefulWidget {
  const IntroVideoScreen({super.key});

  @override
  ConsumerState<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends ConsumerState<IntroVideoScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _leaving = false;
  bool _muted = false;
  Timer? _fallback;

  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    // If the video can't start after a reasonable delay, don't keep the user waiting.
    _fallback = Timer(const Duration(seconds: 8), () {
      if (!_ready) _finish();
    });
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.asset(introVideoAsset);
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || _leaving) return;
      await controller.setLooping(false);
      controller.addListener(_onTick);

      // Web browsers enforce strict autoplay policies blocking unmuted media.
      // Start muted on web so playback begins reliably without user gesture blocking.
      if (kIsWeb) {
        _muted = true;
        await controller.setVolume(0.0);
      } else {
        _muted = false;
        await controller.setVolume(1.0);
      }

      try {
        await controller.play();
      } catch (e) {
        debugPrint('Initial play attempt failed, retrying muted: $e');
        _muted = true;
        await controller.setVolume(0.0);
        await controller.play();
      }

      if (!mounted || _leaving) return;
      setState(() => _ready = true);
      _fade.forward();
    } catch (e) {
      debugPrint('Intro video controller init failed: $e');
      _finish();
    }
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final v = c.value;
    if (v.hasError) {
      debugPrint('Intro playback error: ${v.errorDescription}');
      _finish();
      return;
    }
    if (v.duration > Duration.zero &&
        v.position >= v.duration - const Duration(milliseconds: 150)) {
      _finish();
    }
    if (mounted) setState(() {});
  }

  Future<void> _finish() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    _fallback?.cancel();
    if (_ready) {
      await _fade.reverse();
    }
    if (!mounted) return;
    context.go(AppRoutes.splash);
  }

  void _toggleMute() {
    final c = _controller;
    if (c == null) return;
    setState(() => _muted = !_muted);
    c.setVolume(_muted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = ref.watch(appPreferencesProvider).value?.isArabic ?? true;
    final controller = _controller;
    final value = controller?.value;
    final progress = value != null &&
            value.isInitialized &&
            value.duration.inMilliseconds > 0
        ? value.position.inMilliseconds / value.duration.inMilliseconds
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_ready && controller != null)
              FadeTransition(
                opacity: _fade,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = controller.value.size;
                    final portraitScreen =
                        constraints.maxHeight >= constraints.maxWidth;
                    final aspectRatio = controller.value.aspectRatio > 0
                        ? controller.value.aspectRatio
                        : (size.width > 0 && size.height > 0
                            ? size.width / size.height
                            : 9 / 16);

                    // Portrait (phone): cover the entire display
                    if (portraitScreen) {
                      return SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: size.width > 0 ? size.width : constraints.maxWidth,
                            height: size.height > 0 ? size.height : constraints.maxHeight,
                            child: VideoPlayer(controller),
                          ),
                        ),
                      );
                    }

                    // Landscape (desktop / tablet):
                    // Mount single VideoPlayer instance centered with preserved aspect ratio
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.2,
                              colors: [
                                Color(0xFF0D281E),
                                Color(0xFF06120D),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            child: AspectRatio(
                              aspectRatio: aspectRatio,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: VideoPlayer(controller),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white54,
                  ),
                ),
              ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_ready)
                        _GlassButton(
                          onTap: _toggleMute,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _muted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              if (_muted) ...[
                                const SizedBox(width: 6),
                                Text(
                                  arabic ? 'تشغيل الصوت' : 'Unmute',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      _GlassButton(
                        onTap: _finish,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              arabic ? 'تخطي' : 'Skip',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: Colors.white24,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const StadiumBorder(side: BorderSide(color: Colors.white24)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: child,
        ),
      ),
    );
  }
}
