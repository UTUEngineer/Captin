import 'package:captain/features/export/data/board_state_codec.dart';
import 'package:captain/features/export/data/export_hub_service.dart';
import 'package:captain/features/export/data/gif_export_service.dart';
import 'package:captain/features/tactical_board/application/board_export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boardStateCodecProvider = Provider<BoardStateCodec>((ref) {
  return const BoardStateCodec();
});

final boardExportServiceProvider = Provider<BoardExportService>((ref) {
  return BoardExportService();
});

final exportHubServiceProvider = Provider<ExportHubService>((ref) {
  return ExportHubService(
    boardExportService: ref.watch(boardExportServiceProvider),
  );
});

final gifExportServiceProvider = Provider<GifExportService>((ref) {
  return GifExportService(ref.watch(boardExportServiceProvider));
});
