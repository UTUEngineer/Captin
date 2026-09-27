import 'dart:async';
import 'package:captain/core/config/app_config.dart';
import 'package:captain/core/constants/app_constants.dart';
import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const Color _emeraldAccent = Color(0xFF10B981);
const Color _emerald = Color(0xFF059669);

class DynamicTacticalSplashScreen extends SplashScreen {
  const DynamicTacticalSplashScreen({super.key});
}

class TacticalSplashScreen extends SplashScreen {
  const TacticalSplashScreen({super.key});
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // التشكيلات الافتراضية بالنسب المئوية من حجم الشاشة (X, Y)
  final List<Map<String, dynamic>> _presetFormations = [
    {
      'title': 'التشكيلة الأساسية: 4-3-3',
      'code': '4-3-3',
      'positions': [
        const Offset(0.5, 0.85), // GK
        const Offset(0.15, 0.68), const Offset(0.38, 0.72), const Offset(0.62, 0.72), const Offset(0.85, 0.68), // Defense
        const Offset(0.3, 0.5), const Offset(0.5, 0.52), const Offset(0.7, 0.5), // Midfield
        const Offset(0.2, 0.25), const Offset(0.5, 0.22), const Offset(0.8, 0.25), // Attack
      ]
    },
    {
      'title': 'الاستحواذ والتحكم: 3-2-4-1',
      'code': '3-2-4-1',
      'positions': [
        const Offset(0.5, 0.85), // GK
        const Offset(0.25, 0.72), const Offset(0.5, 0.74), const Offset(0.75, 0.72), // 3 Defenders
        const Offset(0.38, 0.58), const Offset(0.62, 0.58), // 2 Pivots
        const Offset(0.15, 0.38), const Offset(0.38, 0.38), const Offset(0.62, 0.38), const Offset(0.85, 0.38), // 4 Attacking Mid
        const Offset(0.5, 0.2), // Forward
      ]
    },
    {
      'title': 'بناء اللعب والتوزيع: 4-2-4',
      'code': '4-2-4',
      'positions': [
        const Offset(0.5, 0.85), // GK
        const Offset(0.15, 0.68), const Offset(0.38, 0.72), const Offset(0.62, 0.72), const Offset(0.85, 0.68), // 4 Defense
        const Offset(0.38, 0.5), const Offset(0.62, 0.5), // 2 Mid
        const Offset(0.15, 0.22), const Offset(0.38, 0.2), const Offset(0.62, 0.2), const Offset(0.85, 0.22), // 4 Attackers
      ]
    },
  ];

  List<Map<String, dynamic>> _dynamicBoards = [];
  int _currentIndex = 0;
  Timer? _timer;
  bool _isLoadingBoards = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadTacticalBoards();
  }

  Future<void> _loadTacticalBoards() async {
    if (!AppConfig.isSupabaseConfigured) {
      if (mounted) setState(() => _isLoadingBoards = false);
      _startTimer();
      return;
    }

    try {
      final boards = await _supabaseService.fetchCoachTacticalBoards();
      if (mounted && boards.isNotEmpty) {
        setState(() {
          _dynamicBoards = boards;
          _isLoadingBoards = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingBoards = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBoards = false);
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (!mounted) return;
      final totalCount = _dynamicBoards.isNotEmpty ? _dynamicBoards.length : _presetFormations.length;
      setState(() {
        _currentIndex = (_currentIndex + 1) % totalCount;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    if (_isNavigating) return;
    _isNavigating = true;
    _timer?.cancel();

    try {
      final prefs = await ref.read(appPreferencesProvider.future);
      if (!mounted) return;

      if (!prefs.onboardingCompleted) {
        context.go(AppRoutes.onboarding);
      } else {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      if (!mounted) return;
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDynamicBoards = _dynamicBoards.isNotEmpty;
    final int totalCount = hasDynamicBoards ? _dynamicBoards.length : _presetFormations.length;
    final int safeIndex = _currentIndex % (totalCount > 0 ? totalCount : 1);

    String currentTitle = '';
    List<Map<String, dynamic>> playerNodes = [];

    if (hasDynamicBoards) {
      final board = _dynamicBoards[safeIndex];
      currentTitle = board['title'] as String? ?? 'خطة تكتيكية سحابية';
      final List rawPlayers = (board['board_data'] as Map<String, dynamic>?)?['players'] as List? ?? [];

      playerNodes = rawPlayers.map((p) {
        final Map<String, dynamic> map = p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p as Map);
        final double dx = (map['x'] as num? ?? 50).toDouble() / 100;
        final double dy = (map['y'] as num? ?? 50).toDouble() / 100;
        return {
          'offset': Offset(dx, dy),
          'name': map['name']?.toString() ?? '',
          'isGk': map['isGk'] == true,
        };
      }).toList();
    } else {
      final preset = _presetFormations[safeIndex];
      currentTitle = preset['title'] as String;
      final List<Offset> positions = preset['positions'] as List<Offset>;

      playerNodes = List.generate(positions.length, (index) {
        return {
          'offset': positions[index],
          'name': '${index + 1}',
          'isGk': index == 0,
        };
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Logo & Branding
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _emeraldAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _emeraldAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: _emeraldAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppConstants.appName.contains('EL CAPTAIN')
                      ? AppConstants.appName
                      : "${AppConstants.appName} / EL CAPTAIN",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated Formation Title Pill
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Container(
                key: ValueKey<int>(_currentIndex),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _emeraldAccent.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: _emeraldAccent.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  currentTitle,
                  style: const TextStyle(
                    color: _emeraldAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tactical Pitch Display
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _emerald, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (_isLoadingBoards) {
                        return const Center(
                          child: CircularProgressIndicator(color: _emeraldAccent),
                        );
                      }

                      return Stack(
                        children: [
                          // Realistic Pitch Lines Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: TacticalPitchPainter(),
                            ),
                          ),
                          // Player Nodes (Animated Positions)
                          ...List.generate(playerNodes.length, (index) {
                            final node = playerNodes[index];
                            final Offset pos = node['offset'] as Offset;
                            final String name = node['name'] as String;
                            final bool isGK = node['isGk'] as bool;
                            final color = isGK ? Colors.amber : _emeraldAccent;

                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 1100),
                              curve: Curves.easeInOutCubic,
                              left: pos.dx * constraints.maxWidth - 14,
                              top: pos.dy * constraints.maxHeight - 14,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: name.length > 2 ? 9 : 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Formation Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalCount, (index) {
                final isSelected = index == safeIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? _emeraldAccent : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            // Enter App Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emeraldAccent,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shadowColor: _emeraldAccent.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _navigateNext,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "دخول التطبيق",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.black),
                    ],
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

/// Custom painter to render tactical soccer pitch lines smoothly.
class TacticalPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Pitch boundary line
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      linePaint,
    );

    // Center line
    final centerLineY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerLineY),
      Offset(size.width, centerLineY),
      linePaint,
    );

    // Center circle
    final centerCircleRadius = size.width * 0.18;
    canvas.drawCircle(
      Offset(size.width / 2, centerLineY),
      centerCircleRadius,
      linePaint,
    );

    // Center spot
    final spotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, centerLineY), 3, spotPaint);

    // Attacking Goal Box (Top)
    final topBoxWidth = size.width * 0.55;
    final topBoxHeight = size.height * 0.16;
    final topBoxRect = Rect.fromLTWH(
      (size.width - topBoxWidth) / 2,
      0,
      topBoxWidth,
      topBoxHeight,
    );
    canvas.drawRect(topBoxRect, linePaint);

    // Defending Goal Box (Bottom)
    final bottomBoxRect = Rect.fromLTWH(
      (size.width - topBoxWidth) / 2,
      size.height - topBoxHeight,
      topBoxWidth,
      topBoxHeight,
    );
    canvas.drawRect(bottomBoxRect, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
