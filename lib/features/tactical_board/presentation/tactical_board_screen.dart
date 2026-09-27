import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/application/tactic_library_providers.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/formations/presentation/widgets/save_board_dialog.dart';
import 'package:captain/features/presentation_mode/application/presentation_mode_notifier.dart';
import 'package:captain/features/presentation_mode/presentation/presentation_pitch_view.dart';
import 'package:captain/features/tactical_board/application/board_autosave_controller.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:captain/features/tactical_board/presentation/widgets/drawing_toolbar.dart';
import 'package:captain/features/export/presentation/export_hub_sheet.dart';
import 'package:captain/features/tactical_board/presentation/widgets/formation_picker_sheet.dart';
import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/features/collaboration/application/pending_collab_join_provider.dart';
import 'package:captain/features/collaboration/presentation/collaboration_bar.dart';
import 'package:captain/features/collaboration/presentation/widgets/join_session_dialog.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_providers.dart';
import 'package:captain/features/shape_simulation/presentation/simulation_mode_panel.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:captain/features/training/presentation/training_toolbar.dart';
import 'package:captain/features/training/presentation/widgets/training_mode_bar.dart';
import 'package:captain/features/timeline/presentation/widgets/collapsible_timeline_panel.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TacticalBoardScreen extends ConsumerStatefulWidget {
  const TacticalBoardScreen({
    super.key,
    this.initialTemplate,
  });

  final TacticBoardTemplate? initialTemplate;

  @override
  ConsumerState<TacticalBoardScreen> createState() =>
      _TacticalBoardScreenState();
}

class _TacticalBoardScreenState extends ConsumerState<TacticalBoardScreen> {
  var _orientationInitialized = false;
  var _templateLoaded = false;
  String? _savedTemplateId;
  String? _savedTemplateName;
  String? _savedTemplateDescription;
  var _isPresentationMode = false;
  var _autosaveRestored = false;
  var _collaborationBootstrapDone = false;
  Size _canvasSize = Size.zero;

  void _openExportSheet() {
    if (_canvasSize == Size.zero) return;
    ExportHubSheet.show(
      context,
      boardState: ref.read(tacticalBoardProvider),
      canvasSize: _canvasSize,
      title: _savedTemplateName ?? boardStateFormationLabel(),
    );
  }

  void _enterPresentationMode() {
    ref.read(presentationModeProvider.notifier).reset();
    setState(() => _isPresentationMode = true);
  }

  void _exitPresentationMode() {
    ref.read(presentationModeProvider.notifier).reset();
    setState(() => _isPresentationMode = false);
  }

  @override
  void initState() {
    super.initState();
    final template = widget.initialTemplate;
    if (template != null) {
      _savedTemplateId = template.isPreset ? null : template.id;
      _savedTemplateName = template.name;
      _savedTemplateDescription = template.description;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_autosaveRestored && widget.initialTemplate == null) {
      _autosaveRestored = true;
      ref.read(boardAutosaveControllerProvider).restoreIfAvailable(
            hasInitialTemplate: false,
          );
    }

    if (!_templateLoaded && widget.initialTemplate != null) {
      _templateLoaded = true;
      ref
          .read(tacticalBoardProvider.notifier)
          .loadTemplate(widget.initialTemplate!);
    }

    if (_orientationInitialized) return;
    _orientationInitialized = true;

    final size = MediaQuery.sizeOf(context);
    ref.read(tacticalBoardProvider.notifier).syncOrientationWithViewport(
          width: size.width,
          height: size.height,
        );

    if (!_collaborationBootstrapDone) {
      _collaborationBootstrapDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePendingCollabJoin();
        _maybeAutoJoinLastSession();
      });
    }
  }

  Future<void> _handlePendingCollabJoin() async {
    if (!mounted) return;
    final pendingCode = ref.read(pendingCollabJoinCodeProvider);
    if (pendingCode == null || pendingCode.trim().isEmpty) return;

    ref.read(pendingCollabJoinCodeProvider.notifier).state = null;
    await JoinSessionDialog.show(context, initialCode: pendingCode);
  }

  Future<void> _maybeAutoJoinLastSession() async {
    if (!mounted) return;
    final prefs = ref.read(appPreferencesProvider).value;
    if (prefs == null || !prefs.autoJoinLastSession) return;
    if (ref.read(collaborationProvider).isInSession) return;

    final code = prefs.lastCollaborationSessionCode.trim();
    if (code.isEmpty) return;

    final displayName = prefs.displayName.trim().isNotEmpty
        ? prefs.displayName.trim()
        : 'Coach';

    await ref.read(collaborationProvider.notifier).joinSession(
          code: code,
          displayName: displayName,
        );
  }

  Future<void> _saveBoard() async {
    final result = await SaveBoardDialog.show(
      context,
      initialName: _savedTemplateName ?? boardStateFormationLabel(),
      initialDescription: _savedTemplateDescription ?? '',
    );
    if (result == null || !mounted) return;

    final template = ref.read(tacticalBoardProvider.notifier).toTemplate(
          id: _savedTemplateId,
          name: result.name,
          description: result.description,
        );

    final saved =
        await ref.read(tacticLibraryProvider.notifier).saveTemplate(template);
    if (!saved || !mounted) return;

    setState(() {
      _savedTemplateId = template.id;
      _savedTemplateName = template.name;
      _savedTemplateDescription = template.description;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved "${template.name}"')),
    );
  }

  String boardStateFormationLabel() {
    return ref.read(tacticalBoardProvider).selectedFormation?.label ??
        'Tactical Board';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(tacticalBoardProvider.select((s) => s.selectedFormation), (
      previous,
      next,
    ) {
      if (previous == next) return;
      ref.read(shapeSimulationProvider.notifier).syncBasePositions(
            ref.read(tacticalBoardProvider).players,
          );
    });

    final boardState = ref.watch(tacticalBoardProvider);
    final training = ref.watch(trainingProvider);

    if (_isPresentationMode) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return PresentationPitchView(
              boardState: boardState,
              constraints: constraints.biggest,
              onExit: _exitPresentationMode,
            );
          },
        ),
      );
    }

    final formationLabel = boardState.selectedFormation?.label ?? 'Formation';

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            () => ref.read(tacticalBoardProvider.notifier).undo(),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
            () => ref.read(tacticalBoardProvider.notifier).undo(),
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): () => ref.read(tacticalBoardProvider.notifier).redo(),
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          meta: true,
          shift: true,
        ): () => ref.read(tacticalBoardProvider.notifier).redo(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Tactical Board'),
            actions: [
              IconButton(
                tooltip: 'Undo',
                onPressed: boardState.canUndo
                    ? () => ref.read(tacticalBoardProvider.notifier).undo()
                    : null,
                icon: const Icon(Icons.undo_outlined),
              ),
              IconButton(
                tooltip: 'Redo',
                onPressed: boardState.canRedo
                    ? () => ref.read(tacticalBoardProvider.notifier).redo()
                    : null,
                icon: const Icon(Icons.redo_outlined),
              ),
              IconButton(
                tooltip: 'Export board',
                onPressed: _openExportSheet,
                icon: const Icon(Icons.ios_share_outlined),
              ),
          IconButton(
            tooltip: 'Presentation mode',
            onPressed: _enterPresentationMode,
            icon: const Icon(Icons.slideshow_outlined),
          ),
          IconButton(
            tooltip: 'Save board',
            onPressed: _saveBoard,
            icon: const Icon(Icons.save_outlined),
          ),
          PopupMenuButton<_BoardMenuAction>(
            tooltip: 'Board settings',
            onSelected: (action) {
              switch (action) {
                case _BoardMenuAction.snapToGrid:
                  ref.read(tacticalBoardProvider.notifier).toggleSnapToGrid();
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: _BoardMenuAction.snapToGrid,
                checked: boardState.snapToGrid,
                child: const Text('Snap to grid (5%)'),
              ),
            ],
          ),
          IconButton(
            tooltip: boardState.pitchStyle.isStriped
                ? 'Solid pitch'
                : 'Striped pitch',
            onPressed: () =>
                ref.read(tacticalBoardProvider.notifier).togglePitchStyle(),
            icon: Icon(
              boardState.pitchStyle.isStriped
                  ? Icons.texture_outlined
                  : Icons.crop_square_outlined,
            ),
          ),
          IconButton(
            tooltip: boardState.orientation.isVertical
                ? 'Horizontal pitch'
                : 'Vertical pitch',
            onPressed: () =>
                ref.read(tacticalBoardProvider.notifier).toggleOrientation(),
            icon: Icon(
              boardState.orientation.isVertical
                  ? Icons.stay_current_landscape
                  : Icons.stay_current_portrait,
            ),
          ),
            ],
          ),
          body: Column(
            children: [
              const CollaborationBar(),
              const TrainingModeBar(),
              if (!training.isTrainingMode) const DrawingToolbar(),
              if (!training.isTrainingMode) const SimulationModePanel(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          _canvasSize = constraints.biggest;
                          return PitchCanvas(
                            boardState: boardState,
                            constraints: constraints.biggest,
                          );
                        },
                      ),
                    ),
                    if (training.isTrainingMode) const TrainingToolbar(),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => FormationPickerSheet.show(context),
                          icon: const Icon(Icons.grid_view_rounded),
                          label: Text(formationLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TeamLegendDot(color: AppColors.pitchGreenLight),
                            const SizedBox(width: 6),
                            const Text('Home'),
                            const SizedBox(width: 12),
                            _TeamLegendDot(color: AppColors.accentRed),
                            const SizedBox(width: 6),
                            const Text('Away'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const CollapsibleTimelinePanel(),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BoardMenuAction {
  snapToGrid,
}

class _TeamLegendDot extends StatelessWidget {
  const _TeamLegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
