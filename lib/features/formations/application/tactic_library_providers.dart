import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/data/local_tactic_board_repository.dart';
import 'package:captain/features/formations/data/tactic_presets.dart';
import 'package:captain/features/formations/domain/tactic_board_repository.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tacticBoardRepositoryProvider =
    FutureProvider<TacticBoardRepository>((ref) async {
  return LocalTacticBoardRepository.create();
});

class TacticLibraryNotifier extends AsyncNotifier<List<TacticBoardTemplate>> {
  @override
  Future<List<TacticBoardTemplate>> build() async {
    return _loadAll();
  }

  Future<List<TacticBoardTemplate>> _loadAll() async {
    final repository = await ref.watch(tacticBoardRepositoryProvider.future);
    final saved = await repository.getSavedTemplates();
    return [...TacticPresets.all, ...saved];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadAll);
  }

  Future<void> deleteTemplate(String id) async {
    final repository = await ref.read(tacticBoardRepositoryProvider.future);
    await repository.deleteTemplate(id);
    await refresh();
  }

  Future<void> renameTemplate({
    required String id,
    required String name,
    String? description,
  }) async {
    final repository = await ref.read(tacticBoardRepositoryProvider.future);
    await repository.renameTemplate(
      id: id,
      name: name,
      description: description,
    );
    await refresh();
  }

  Future<bool> saveTemplate(TacticBoardTemplate template) async {
    final repository = await ref.read(tacticBoardRepositoryProvider.future);
    await repository.saveTemplate(template);
    await refresh();
    return true;
  }
}

final tacticLibraryProvider =
    AsyncNotifierProvider<TacticLibraryNotifier, List<TacticBoardTemplate>>(
  TacticLibraryNotifier.new,
);

extension TacticBoardTemplateUi on TacticBoardTemplate {
  String get formattedDate {
    final date = updatedAt.toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }

  String get badgeLabel => isPreset ? 'Preset' : 'Saved';

  Color get badgeColor =>
      isPreset ? AppColors.pitchGreenLight : AppColors.accentOrange;
}
