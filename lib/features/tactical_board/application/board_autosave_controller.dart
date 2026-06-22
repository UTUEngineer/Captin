import 'dart:async';

import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/data/local_board_autosave_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const boardAutosaveDebounce = Duration(seconds: 30);

class BoardAutosaveController {
  BoardAutosaveController(this._ref);

  final Ref _ref;
  Timer? _debounce;
  LocalBoardAutosaveStore? _store;
  var _restored = false;

  Future<LocalBoardAutosaveStore> _ensureStore() async {
    return _store ??= await LocalBoardAutosaveStore.create();
  }

  void scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(boardAutosaveDebounce, () async {
      final notifier = _ref.read(tacticalBoardProvider.notifier);
      final template = notifier.toTemplate(name: 'autosave');
      final store = await _ensureStore();
      await store.save(template);
    });
  }

  Future<void> restoreIfAvailable({required bool hasInitialTemplate}) async {
    if (_restored || hasInitialTemplate) return;
    _restored = true;

    final store = await _ensureStore();
    final template = await store.load();
    if (template == null) return;

    _ref.read(tacticalBoardProvider.notifier).loadTemplate(
          template,
          recordHistory: false,
        );
  }

  void dispose() {
    _debounce?.cancel();
  }
}

final boardAutosaveControllerProvider = Provider<BoardAutosaveController>((ref) {
  final controller = BoardAutosaveController(ref);
  ref.onDispose(controller.dispose);

  ref.listen<TacticalBoardState>(tacticalBoardProvider, (previous, next) {
    if (previous == null || identical(previous, next)) return;
    controller.scheduleSave();
  });

  return controller;
});

final boardAutosaveBootstrapProvider = Provider<void>((ref) {
  ref.watch(boardAutosaveControllerProvider);
});
