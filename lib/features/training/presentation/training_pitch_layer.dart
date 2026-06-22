import 'package:captain/features/training/application/training_providers.dart';
import 'package:captain/features/training/presentation/drill_path_painter.dart';
import 'package:captain/features/training/presentation/training_prop_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrainingPitchLayer extends ConsumerStatefulWidget {
  const TrainingPitchLayer({
    super.key,
    required this.layout,
    required this.localLayout,
  });

  final PitchLayout layout;
  final PitchLayout localLayout;

  @override
  ConsumerState<TrainingPitchLayer> createState() =>
      _TrainingPitchLayerState();
}

class _TrainingPitchLayerState extends ConsumerState<TrainingPitchLayer> {
  Offset? _pathStartRelative;
  Offset? _pathEndRelative;

  ({double x, double y})? _relativeFromLocal(Offset local) {
    final global = widget.layout.rect.topLeft + local;
    return widget.layout.relativeFor(global);
  }

  @override
  Widget build(BuildContext context) {
    final training = ref.watch(trainingProvider);
    final notifier = ref.read(trainingProvider.notifier);

    return Stack(
      children: [
        CustomPaint(
          size: widget.layout.rect.size,
          painter: DrillPathPainter(
            layout: widget.localLayout,
            paths: training.paths,
            draftStart: _pathStartRelative == null
                ? null
                : widget.localLayout.positionFor(
                    _pathStartRelative!.dx,
                    _pathStartRelative!.dy,
                  ),
            draftEnd: _pathEndRelative == null
                ? null
                : widget.localLayout.positionFor(
                    _pathEndRelative!.dx,
                    _pathEndRelative!.dy,
                  ),
            draftStyle: training.selectedPathStyle,
          ),
        ),
        CustomPaint(
          size: widget.layout.rect.size,
          painter: TrainingPropPainter(
            layout: widget.localLayout,
            props: training.props,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) {
            final relative = _relativeFromLocal(details.localPosition);
            if (relative == null) return;

            if (training.pathToolActive) return;

            if (training.pendingPropType != null) {
              notifier.placeProp(x: relative.x, y: relative.y);
              return;
            }

            notifier.selectProp(null);
          },
          onPanStart: (details) {
            if (!training.pathToolActive) return;
            final relative = _relativeFromLocal(details.localPosition);
            if (relative == null) return;
            setState(() {
              _pathStartRelative = Offset(relative.x, relative.y);
              _pathEndRelative = Offset(relative.x, relative.y);
            });
          },
          onPanUpdate: (details) {
            if (!training.pathToolActive) return;
            final relative = _relativeFromLocal(details.localPosition);
            if (relative == null) return;
            setState(() {
              _pathEndRelative = Offset(relative.x, relative.y);
            });
          },
          onPanEnd: (_) {
            if (!training.pathToolActive ||
                _pathStartRelative == null ||
                _pathEndRelative == null) {
              setState(() {
                _pathStartRelative = null;
                _pathEndRelative = null;
              });
              return;
            }

            notifier.addPath(
              startX: _pathStartRelative!.dx,
              startY: _pathStartRelative!.dy,
              endX: _pathEndRelative!.dx,
              endY: _pathEndRelative!.dy,
            );
            setState(() {
              _pathStartRelative = null;
              _pathEndRelative = null;
            });
          },
          child: SizedBox(
            width: widget.layout.rect.width,
            height: widget.layout.rect.height,
          ),
        ),
        ...training.props.map((prop) {
          final anchor = widget.layout.positionFor(prop.x, prop.y);
          final isSelected = training.selectedPropId == prop.id;
          return Positioned(
            left: anchor.dx - 18,
            top: anchor.dy - 18,
            child: GestureDetector(
              onTap: () => notifier.selectProp(prop.id),
              onLongPress: () => _showPropMenu(context, prop.id),
              onPanUpdate: (details) {
                final relative = widget.layout.relativeFor(
                  anchor + details.delta,
                );
                notifier.moveProp(
                  propId: prop.id,
                  x: relative.x,
                  y: relative.y,
                );
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showPropMenu(BuildContext context, String propId) async {
    final notifier = ref.read(trainingProvider.notifier);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.rotate_right),
              title: const Text('Rotate'),
              onTap: () => Navigator.pop(context, 'rotate'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate'),
              onTap: () => Navigator.pop(context, 'duplicate'),
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Change color'),
              onTap: () => Navigator.pop(context, 'color'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    switch (action) {
      case 'rotate':
        notifier.rotateProp(propId);
      case 'duplicate':
        notifier.duplicateProp(propId);
      case 'color':
        notifier.cyclePropColor(propId);
      case 'delete':
        notifier.deleteProp(propId);
    }
  }
}
