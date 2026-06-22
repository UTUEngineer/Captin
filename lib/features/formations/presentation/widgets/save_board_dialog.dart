import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:flutter/material.dart';

class SaveBoardDialog extends StatefulWidget {
  const SaveBoardDialog({
    super.key,
    this.initialName = '',
    this.initialDescription = '',
    this.title = 'Save tactical board',
  });

  final String initialName;
  final String initialDescription;
  final String title;

  static Future<({String name, String? description})?> show(
    BuildContext context, {
    String initialName = '',
    String initialDescription = '',
    String title = 'Save tactical board',
  }) {
    return showDialog<({String name, String? description})>(
      context: context,
      builder: (context) => SaveBoardDialog(
        initialName: initialName,
        initialDescription: initialDescription,
        title: title,
      ),
    );
  }

  @override
  State<SaveBoardDialog> createState() => _SaveBoardDialogState();
}

class _SaveBoardDialogState extends State<SaveBoardDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Template name',
              hintText: '4-3-3 High Press',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            final description = _descriptionController.text.trim();
            Navigator.of(context).pop((
              name: name,
              description: description.isEmpty ? null : description,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<TacticBoardTemplate?> showRenameBoardDialog(
  BuildContext context,
  TacticBoardTemplate template,
) async {
  final result = await SaveBoardDialog.show(
    context,
    initialName: template.name,
    initialDescription: template.description ?? '',
    title: 'Rename template',
  );
  if (result == null) return null;
  return template.copyWith(
    name: result.name,
    description: result.description,
    updatedAt: DateTime.now(),
  );
}
