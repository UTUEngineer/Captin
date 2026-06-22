import 'package:captain/features/formations/domain/tactic_board_template.dart';

abstract class TacticBoardRepository {
  Future<List<TacticBoardTemplate>> getSavedTemplates();

  Future<void> saveTemplate(TacticBoardTemplate template);

  Future<void> deleteTemplate(String id);

  Future<void> renameTemplate({
    required String id,
    required String name,
    String? description,
  });
}
