import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/timeline/application/timeline_providers.dart';
import 'package:captain/features/timeline/domain/timeline_event.dart';
import 'package:captain/features/timeline/presentation/widgets/add_event_sheet.dart';
import 'package:captain/features/timeline/presentation/widgets/event_detail_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimelineWidget extends ConsumerStatefulWidget {
  const TimelineWidget({
    super.key,
    this.matchId = defaultMatchId,
    this.showControls = true,
    this.height = 80,
  });

  final String matchId;
  final bool showControls;
  final double height;

  @override
  ConsumerState<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends ConsumerState<TimelineWidget> {
  TimelineEvent? _selectedEvent;

  double _minuteFromLocal(double dx, double width, int maxMinute) {
    if (width <= 0) return 0;
    return (dx / width * maxMinute).clamp(0.0, maxMinute.toDouble());
  }

  double _xForMinute(double minute, double width, int maxMinute) {
    if (maxMinute <= 0) return 0;
    return (minute / maxMinute) * width;
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineControllerProvider(widget.matchId));
    final controller =
        ref.read(timelineControllerProvider(widget.matchId).notifier);
    final maxMinute = timelineState.maxMinute;

    return Container(
      height: widget.height,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showControls)
            Row(
              children: [
                IconButton(
                  tooltip: timelineState.isPlaying ? 'Pause' : 'Play',
                  onPressed: controller.togglePlayPause,
                  icon: Icon(
                    timelineState.isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                ),
                Text(
                  "${timelineState.currentMinute.floor()}'",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.cyclePlaybackSpeed,
                  child: Text('${timelineState.playbackSpeed}x'),
                ),
              ],
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                final trackHeight = constraints.maxHeight;

                return GestureDetector(
                  onLongPressStart: (details) {
                    final minute =
                        _minuteFromLocal(details.localPosition.dx, trackWidth, maxMinute);
                    AddEventSheet.show(
                      context,
                      initialMinute: minute,
                      matchId: widget.matchId,
                    );
                  },
                  onHorizontalDragUpdate: (details) {
                    final minute = _minuteFromLocal(
                      details.localPosition.dx.clamp(0, trackWidth),
                      trackWidth,
                      maxMinute,
                    );
                    controller.seek(minute);
                  },
                  onTapDown: (details) {
                    final minute =
                        _minuteFromLocal(details.localPosition.dx, trackWidth, maxMinute);
                    controller.seek(minute);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: trackHeight / 2,
                        child: Container(
                          height: 2,
                          color: AppColors.border,
                        ),
                      ),
                      if (maxMinute >= 45)
                        Positioned(
                          left: _xForMinute(45, trackWidth, maxMinute) - 1,
                          top: 8,
                          bottom: 8,
                          child: CustomPaint(
                            painter: _DashedLinePainter(
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      for (final event in timelineState.timeline.events)
                        Positioned(
                          left: _xForMinute(
                                event.timeInMinutes,
                                trackWidth,
                                maxMinute,
                              ) -
                              6,
                          top: trackHeight / 2 - 6,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedEvent = event),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: event.type.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: timelineState.highlightedEventId ==
                                          event.id
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  if (timelineState.highlightedEventId ==
                                      event.id)
                                    BoxShadow(
                                      color: event.type.color
                                          .withValues(alpha: 0.8),
                                      blurRadius: 8,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: _xForMinute(
                              timelineState.currentMinute,
                              trackWidth,
                              maxMinute,
                            ) -
                            8,
                        top: trackHeight / 2 - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreenLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                      if (_selectedEvent != null)
                        Positioned(
                          left: (_xForMinute(
                                    _selectedEvent!.timeInMinutes,
                                    trackWidth,
                                    maxMinute,
                                  ) -
                                  80)
                              .clamp(0.0, trackWidth - 160),
                          bottom: trackHeight + 8,
                          width: 160,
                          child: EventDetailCard(
                            event: _selectedEvent!,
                            onClose: () => setState(() => _selectedEvent = null),
                            onOpenBoard: _selectedEvent!.linkedTacticalBoardId ==
                                    null
                                ? null
                                : () async {
                                    final snapshot = await controller
                                        .loadLinkedBoard(
                                      _selectedEvent!
                                          .linkedTacticalBoardId!,
                                    );
                                    if (!context.mounted || snapshot == null) {
                                      return;
                                    }
                                    ref
                                        .read(tacticalBoardProvider.notifier)
                                        .loadTemplate(
                                          snapshot,
                                          recordHistory: false,
                                        );
                                    await controller.seek(
                                      _selectedEvent!.timeInMinutes,
                                    );
                                    setState(() => _selectedEvent = null);
                                  },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashHeight = 4.0;
    const gap = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        paint,
      );
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
