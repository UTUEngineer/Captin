import 'dart:math' as math;
import 'dart:typed_data';

import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/application/board_export_service.dart';
import 'package:captain/features/training/application/training_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

const gifMaxFrames = 50;
const gifFrameDelayCentiseconds = 10;

class GifExportService {
  const GifExportService(this._boardExportService);

  final BoardExportService _boardExportService;

  Future<Uint8List> buildBoardGif({
    required BuildContext context,
    required TacticalBoardState boardState,
    required Size canvasSize,
    TrainingState? trainingState,
    void Function(int completed, int total)? onProgress,
  }) async {
    final encoder = img.GifEncoder(repeat: 0, delay: gifFrameDelayCentiseconds);

    for (var frame = 0; frame < gifMaxFrames; frame++) {
      final phase = frame / gifMaxFrames;
      final animated = _animatedBoardState(boardState, phase);
      final pngBytes = await _boardExportService.captureBoardImage(
        context: context,
        boardState: animated,
        canvasSize: canvasSize,
        trainingState: trainingState,
        pixelRatio: 2,
      );

      final decoded = img.decodePng(pngBytes);
      if (decoded != null) {
        encoder.addFrame(decoded, duration: gifFrameDelayCentiseconds);
      }
      onProgress?.call(frame + 1, gifMaxFrames);
    }

    final gifBytes = encoder.finish();
    if (gifBytes == null) {
      throw StateError('Failed to encode GIF.');
    }
    return Uint8List.fromList(gifBytes);
  }

  TacticalBoardState _animatedBoardState(
    TacticalBoardState state,
    double phase,
  ) {
    final wave = math.sin(phase * math.pi * 2) * 0.035;
    final players = state.players.map((player) {
      if (player.locked) return player;
      final direction = player.isHomeTeam ? -1.0 : 0.5;
      return player.copyWith(
        y: (player.y + wave * direction).clamp(0.05, 0.95),
      );
    }).toList();

    return state.copyWith(
      players: players,
      skipNextAnimation: true,
    );
  }
}
