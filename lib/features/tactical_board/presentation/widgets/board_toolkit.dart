import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Floating, draggable tool panel for the tactical board.
///
/// Drag it by the grip; on release it docks to the nearest side edge.
/// Tap the chevron to collapse it into a single round button.
class BoardToolkit extends ConsumerStatefulWidget {
  const BoardToolkit({super.key, required this.area});

  /// Size of the area the toolkit floats in (the pitch viewport).
  final Size area;

  @override
  ConsumerState<BoardToolkit> createState() => _BoardToolkitState();
}

class _BoardToolkitState extends ConsumerState<BoardToolkit> {
  static const _panelWidth = 124.0;
  static const _margin = 8.0;

  Offset? _position;
  late bool _collapsed = widget.area.width < 600;
  bool _dragging = false;

  double get _width => _collapsed ? 52 : _panelWidth;

  Offset _defaultPosition(bool rtl) {
    final x = rtl ? widget.area.width - _width - _margin : _margin;
    return Offset(x, _margin);
  }

  Offset _dock(Offset pos) {
    final maxX = widget.area.width - _width - _margin;
    final dockLeft = pos.dx + _width / 2 < widget.area.width / 2;
    final maxY = (widget.area.height - 80).clamp(_margin, double.infinity);
    return Offset(
      dockLeft ? _margin : maxX.clamp(_margin, double.infinity),
      pos.dy.clamp(_margin, maxY),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final pos = _position ?? _defaultPosition(rtl);
    final clamped = Offset(
      pos.dx.clamp(0, (widget.area.width - _width).clamp(0, double.infinity)),
      pos.dy.clamp(0, (widget.area.height - 60).clamp(0, double.infinity)),
    );

    return AnimatedPositioned(
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      left: clamped.dx,
      top: clamped.dy,
      child: _collapsed
          ? _CollapsedButton(
              onExpand: () => setState(() {
                _collapsed = false;
                _position = _dock(clamped);
              }),
              onDrag: (delta) => setState(() {
                _dragging = true;
                _position = clamped + delta;
              }),
              onDragEnd: () => setState(() {
                _dragging = false;
                _position = _dock(_position ?? clamped);
              }),
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: (widget.area.height - clamped.dy - _margin)
                    .clamp(120, double.infinity),
              ),
              child: _Panel(
                width: _panelWidth,
                onDrag: (delta) => setState(() {
                  _dragging = true;
                  _position = clamped + delta;
                }),
                onDragEnd: () => setState(() {
                  _dragging = false;
                  _position = _dock(_position ?? clamped);
                }),
                onCollapse: () => setState(() => _collapsed = true),
              ),
            ),
    );
  }
}

class _CollapsedButton extends ConsumerWidget {
  const _CollapsedButton({
    required this.onExpand,
    required this.onDrag,
    required this.onDragEnd,
  });

  final VoidCallback onExpand;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(tacticalBoardProvider.select((s) => s.activeTool));
    return GestureDetector(
      onTap: onExpand,
      onPanUpdate: (d) => onDrag(d.delta),
      onPanEnd: (_) => onDragEnd(),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.96),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Icon(tool.icon, color: AppColors.primary),
      ),
    );
  }
}

class _Panel extends ConsumerWidget {
  const _Panel({
    required this.width,
    required this.onDrag,
    required this.onDragEnd,
    required this.onCollapse,
  });

  final double width;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onDragEnd;
  final VoidCallback onCollapse;

  static const _arrowTools = [
    BoardTool.passArrow,
    BoardTool.runArrow,
    BoardTool.dribbleArrow,
    BoardTool.shotArrow,
    BoardTool.pressArrow,
    BoardTool.curvedRun,
    BoardTool.line,
  ];
  static const _zoneTools = [
    BoardTool.zone,
    BoardTool.freeZone,
    BoardTool.circle,
  ];
  static const _objectTools = [
    BoardTool.select,
    BoardTool.ball,
    BoardTool.textNote,
    BoardTool.eraser,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(tacticalBoardProvider);
    final notifier = ref.read(tacticalBoardProvider.notifier);
    final playback = ref.watch(tacticPlaybackProvider);
    final arabic = ref.watch(appPreferencesProvider).value?.isArabic ?? false;
    final tool = board.activeTool;
    final paletteSelected = tool.usesZoneColor
        ? board.selectedZoneColor
        : board.arrowColorValue;

    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        );

    Widget toolGrid(List<BoardTool> tools) => Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final t in tools)
              _ToolTile(
                icon: t.icon,
                tooltip: t.label(arabic: arabic),
                selected: tool == t,
                onTap: () => notifier.setTool(t),
              ),
          ],
        );

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => onDrag(d.delta),
              onPanEnd: (_) => onDragEnd(),
              child: MouseRegion(
                cursor: SystemMouseCursors.move,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.drag_indicator_rounded,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          arabic ? 'الأدوات' : 'Toolkit',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onCollapse,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.unfold_less_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    section(arabic ? 'عناصر' : 'OBJECTS'),
                    toolGrid(_objectTools),
                    section(arabic ? 'الأسهم' : 'ARROWS'),
                    toolGrid(_arrowTools),
                    section(arabic ? 'المناطق' : 'ZONES'),
                    toolGrid(_zoneTools),
                    section(arabic ? 'اللون' : 'COLOR'),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (!tool.usesZoneColor)
                          _Swatch(
                            color: null,
                            selected: paletteSelected == null,
                            onTap: () => notifier.setArrowColor(null),
                          ),
                        for (final color in zoneColorPalette)
                          _Swatch(
                            color: color,
                            selected: paletteSelected == color.toARGB32(),
                            onTap: () => tool.usesZoneColor
                                ? notifier.setZoneColor(color.toARGB32())
                                : notifier.setArrowColor(color.toARGB32()),
                          ),
                      ],
                    ),
                    section(arabic ? 'المرحلة' : 'PHASE'),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (var i = 1;
                            i <= (board.stepCount + 1).clamp(1, maxBoardSteps);
                            i++)
                          _PhaseChip(
                            step: i,
                            selected: board.activeStep == i,
                            onTap: () {
                              notifier.setActiveStep(i);
                              if (board.selectedElements.isNotEmpty) {
                                notifier.setSelectedArrowsStep(i);
                              }
                            },
                          ),
                      ],
                    ),
                    section(arabic ? 'اللاعبون' : 'PLAYERS'),
                    Row(
                      children: [
                        Expanded(
                          child: _ToolTile(
                            icon: Icons.person_add_alt_1_rounded,
                            tooltip: arabic ? 'لاعب للفريق الأول' : 'Add home player',
                            tint: AppColors.homeTeam,
                            onTap: () => notifier.addPlayer(isHomeTeam: true),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _ToolTile(
                            icon: Icons.person_add_alt_1_rounded,
                            tooltip: arabic ? 'لاعب للخصم' : 'Add away player',
                            tint: AppColors.awayTeam,
                            onTap: () => notifier.addPlayer(isHomeTeam: false),
                          ),
                        ),
                      ],
                    ),
                    section(arabic ? 'إجراءات' : 'ACTIONS'),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _ToolTile(
                          icon: Icons.select_all_rounded,
                          tooltip: arabic ? 'تحديد الكل' : 'Select all',
                          onTap: notifier.selectAll,
                        ),
                        _ToolTile(
                          icon: board.animateArrows
                              ? Icons.motion_photos_on_rounded
                              : Icons.motion_photos_off_outlined,
                          tooltip: arabic ? 'تحريك الأسهم' : 'Animate arrows',
                          selected: board.animateArrows,
                          onTap: notifier.toggleAnimateArrows,
                        ),
                        _ToolTile(
                          icon: Icons.undo_rounded,
                          tooltip: arabic ? 'تراجع' : 'Undo',
                          onTap: board.canUndo ? notifier.undo : null,
                        ),
                        _ToolTile(
                          icon: Icons.redo_rounded,
                          tooltip: arabic ? 'إعادة' : 'Redo',
                          onTap: board.canRedo ? notifier.redo : null,
                        ),
                        _ToolTile(
                          icon: Icons.layers_clear_outlined,
                          tooltip: arabic ? 'مسح الرسومات' : 'Clear drawings',
                          tint: AppColors.danger,
                          onTap: notifier.clearDrawings,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () {
                        final playbackNotifier =
                            ref.read(tacticPlaybackProvider.notifier);
                        if (playback.isActive) {
                          playbackNotifier.togglePlay();
                          return;
                        }
                        final started = playbackNotifier.play();
                        if (!started) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                arabic
                                    ? 'ارسم أسهم جري أو تمرير تبدأ من اللاعبين لتشغيل الخطة'
                                    : 'Draw run or pass arrows starting at players to play the tactic',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        playback.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(
                        playback.isPlaying
                            ? (arabic ? 'إيقاف' : 'Pause')
                            : (arabic ? 'تشغيل' : 'Play'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
    this.tint,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool selected;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? AppColors.primary;
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Semantics(
        button: true,
        selected: selected,
        label: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.18)
                  : AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? color : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: !enabled
                  ? AppColors.textMuted.withValues(alpha: 0.5)
                  : (selected || tint != null ? color : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  /// null = "auto" (default color per arrow type).
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          gradient: color == null
              ? const SweepGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFEE58),
                    Color(0xFFE53935),
                    Color(0xFF67E8F9),
                    Color(0xFFFFFFFF),
                  ],
                )
              : null,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.border,
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.step,
    required this.selected,
    required this.onTap,
  });

  final int step;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          '$step',
          style: TextStyle(
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
