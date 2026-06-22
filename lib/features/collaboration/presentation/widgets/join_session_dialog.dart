import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinSessionDialog extends ConsumerStatefulWidget {
  const JoinSessionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const JoinSessionDialog(),
    );
  }

  @override
  ConsumerState<JoinSessionDialog> createState() => _JoinSessionDialogState();
}

class _JoinSessionDialogState extends ConsumerState<JoinSessionDialog> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController(text: 'Coach');
  var _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await ref.read(collaborationProvider.notifier).joinSession(
          code: _codeController.text,
          displayName: _nameController.text,
        );

    if (!mounted) return;
    final error = ref.read(collaborationProvider).errorMessage;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Session code',
              hintText: 'ABC-123',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Join'),
        ),
      ],
    );
  }
}
