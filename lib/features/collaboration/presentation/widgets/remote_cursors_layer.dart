import 'package:captain/features/collaboration/application/collaboration_notifier.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class RemoteCursorsLayer extends StatelessWidget {
  const RemoteCursorsLayer({
    super.key,
    required this.remoteCursors,
    required this.layout,
  });

  final Map<String, RemoteCursor> remoteCursors;
  final PitchLayout layout;

  @override
  Widget build(BuildContext context) {
    if (remoteCursors.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final cursor in remoteCursors.values) _RemoteCursorMarker(
          cursor: cursor,
          layout: layout,
        ),
      ],
    );
  }
}

class _RemoteCursorMarker extends StatelessWidget {
  const _RemoteCursorMarker({
    required this.cursor,
    required this.layout,
  });

  final RemoteCursor cursor;
  final PitchLayout layout;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(cursor.displayed.dx, cursor.displayed.dy);

    return Positioned(
      left: anchor.dx,
      top: anchor.dy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: cursor.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: cursor.color.withValues(alpha: 0.45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: cursor.color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cursor.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
