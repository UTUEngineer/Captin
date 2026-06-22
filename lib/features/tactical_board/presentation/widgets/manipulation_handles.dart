import 'dart:math' as math;

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

enum ZoneCorner { topLeft, topRight, bottomLeft, bottomRight }

class ZoneResizeHandles extends StatefulWidget {
  const ZoneResizeHandles({
    super.key,
    required this.zone,
    required this.layout,
    required this.enabled,
    required this.onResize,
  });

  final Zone zone;
  final PitchLayout layout;
  final bool enabled;
  final void Function({
    required double x,
    required double y,
    required double width,
    required double height,
    required bool commit,
  }) onResize;

  @override
  State<ZoneResizeHandles> createState() => _ZoneResizeHandlesState();
}

class _ZoneResizeHandlesState extends State<ZoneResizeHandles> {
  ({double x, double y, double width, double height})? _latestBounds;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    final zone = widget.zone;
    final layout = widget.layout;
    final handles = <ZoneCorner, Offset>{
      ZoneCorner.topLeft: layout.positionFor(zone.x, zone.y),
      ZoneCorner.topRight: layout.positionFor(zone.x + zone.width, zone.y),
      ZoneCorner.bottomLeft: layout.positionFor(zone.x, zone.y + zone.height),
      ZoneCorner.bottomRight: layout.positionFor(
        zone.x + zone.width,
        zone.y + zone.height,
      ),
    };

    return Stack(
      clipBehavior: Clip.none,
      children: handles.entries.map((entry) {
        return Positioned(
          left: entry.value.dx - 8,
          top: entry.value.dy - 8,
          child: GestureDetector(
            onPanUpdate: (details) {
              final relative = layout.relativeFor(
                entry.value + details.delta,
              );
              final next = _resizeFromCorner(
                zone: zone,
                corner: entry.key,
                x: relative.x,
                y: relative.y,
              );
              _latestBounds = next;
              widget.onResize(
                x: next.x,
                y: next.y,
                width: next.width,
                height: next.height,
                commit: false,
              );
            },
            onPanEnd: (_) {
              final bounds = _latestBounds;
              if (bounds == null) return;
              widget.onResize(
                x: bounds.x,
                y: bounds.y,
                width: bounds.width,
                height: bounds.height,
                commit: true,
              );
              _latestBounds = null;
            },
            child: _handleDot(),
          ),
        );
      }).toList(),
    );
  }

  ({double x, double y, double width, double height}) _resizeFromCorner({
    required Zone zone,
    required ZoneCorner corner,
    required double x,
    required double y,
  }) {
    var left = zone.x;
    var top = zone.y;
    var right = zone.x + zone.width;
    var bottom = zone.y + zone.height;

    switch (corner) {
      case ZoneCorner.topLeft:
        left = x;
        top = y;
      case ZoneCorner.topRight:
        right = x;
        top = y;
      case ZoneCorner.bottomLeft:
        left = x;
        bottom = y;
      case ZoneCorner.bottomRight:
        right = x;
        bottom = y;
    }

    final normalizedLeft = math.min(left, right);
    final normalizedTop = math.min(top, bottom);
    final width = (right - left).abs().clamp(0.02, 1.0);
    final height = (bottom - top).abs().clamp(0.02, 1.0);

    return (
      x: normalizedLeft.clamp(0.0, 1.0),
      y: normalizedTop.clamp(0.0, 1.0),
      width: width,
      height: height,
    );
  }

  Widget _handleDot() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentOrange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class ArrowEndpointHandles extends StatelessWidget {
  const ArrowEndpointHandles({
    super.key,
    required this.arrow,
    required this.layout,
    required this.enabled,
    required this.onEndpointMoved,
  });

  final Arrow arrow;
  final PitchLayout layout;
  final bool enabled;
  final void Function({
    required bool isStart,
    required double x,
    required double y,
    required bool commit,
  }) onEndpointMoved;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    final start = layout.positionFor(arrow.startX, arrow.startY);
    final end = layout.positionFor(arrow.endX, arrow.endY);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _EndpointHandle(
          position: start,
          layout: layout,
          onMoved: (x, y, {required commit}) =>
              onEndpointMoved(isStart: true, x: x, y: y, commit: commit),
        ),
        _EndpointHandle(
          position: end,
          layout: layout,
          onMoved: (x, y, {required commit}) =>
              onEndpointMoved(isStart: false, x: x, y: y, commit: commit),
        ),
      ],
    );
  }
}

class _EndpointHandle extends StatefulWidget {
  const _EndpointHandle({
    required this.position,
    required this.layout,
    required this.onMoved,
  });

  final Offset position;
  final PitchLayout layout;
  final void Function(double x, double y, {required bool commit}) onMoved;

  @override
  State<_EndpointHandle> createState() => _EndpointHandleState();
}

class _EndpointHandleState extends State<_EndpointHandle> {
  Offset _accumulated = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final current = widget.position + _accumulated;

    return Positioned(
      left: current.dx - 8,
      top: current.dy - 8,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() => _accumulated += details.delta);
          final relative =
              widget.layout.relativeFor(widget.position + _accumulated);
          widget.onMoved(relative.x, relative.y, commit: false);
        },
        onPanEnd: (_) {
          final relative =
              widget.layout.relativeFor(widget.position + _accumulated);
          widget.onMoved(relative.x, relative.y, commit: true);
          setState(() => _accumulated = Offset.zero);
        },
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textPrimary, width: 2),
          ),
        ),
      ),
    );
  }
}

class RotationHandle extends StatefulWidget {
  const RotationHandle({
    super.key,
    required this.center,
    required this.layout,
    required this.elementKey,
    required this.currentRotation,
    required this.enabled,
    required this.onRotate,
  });

  final Offset center;
  final PitchLayout layout;
  final BoardElementKey elementKey;
  final double currentRotation;
  final bool enabled;
  final void Function(double rotation, {required bool commit}) onRotate;

  @override
  State<RotationHandle> createState() => _RotationHandleState();
}

class _RotationHandleState extends State<RotationHandle> {
  double? _lastAngle;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    final handleCenter = Offset(widget.center.dx, widget.center.dy - 28);

    return Positioned(
      left: handleCenter.dx - 10,
      top: handleCenter.dy - 10,
      child: GestureDetector(
        onPanUpdate: (details) {
          final current =
              widget.layout.relativeFor(handleCenter + details.delta);
          final centerRelative = widget.layout.relativeFor(widget.center);
          final angle = math.atan2(
            current.y - centerRelative.y,
            current.x - centerRelative.x,
          );
          _lastAngle = angle;
          widget.onRotate(angle, commit: false);
        },
        onPanEnd: (_) {
          if (_lastAngle == null) return;
          widget.onRotate(_lastAngle!, commit: true);
          _lastAngle = null;
        },
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentOrange, width: 2),
          ),
          child: Transform.rotate(
            angle: widget.currentRotation,
            child: const Icon(
              Icons.rotate_right,
              size: 12,
              color: AppColors.accentOrange,
            ),
          ),
        ),
      ),
    );
  }
}
