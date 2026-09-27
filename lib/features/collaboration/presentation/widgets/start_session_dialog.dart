import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartSessionDialog extends ConsumerStatefulWidget {
  const StartSessionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const StartSessionDialog(),
    );
  }

  @override
  ConsumerState<StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends ConsumerState<StartSessionDialog> {
  late final TextEditingController _controller;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _defaultName());
  }

  String _defaultName() {
    final prefs = ref.read(appPreferencesProvider).value;
    if (prefs == null) return 'Coach';

    final displayName = prefs.displayName.trim();
    if (displayName.isNotEmpty) return displayName;

    final sessionName = prefs.defaultSessionName.trim();
    if (sessionName.isNotEmpty) return sessionName;

    return 'Coach';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await ref.read(collaborationProvider.notifier).createSession(
          hostName: _controller.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start collaboration session'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Your name',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _loading ? null : _submit(),
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
              : const Text('Create'),
        ),
      ],
    );
  }
}
