import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/leagues/presentation/widgets/football_api_key_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FootballApiKeyDialog extends ConsumerStatefulWidget {
  const FootballApiKeyDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const FootballApiKeyDialog(),
    );
  }

  @override
  ConsumerState<FootballApiKeyDialog> createState() => _FootballApiKeyDialogState();
}

class _FootballApiKeyDialogState extends ConsumerState<FootballApiKeyDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final apiKey = _controller.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _error = 'الرجاء إدخال مفتاح API.');
      return;
    }

    await ref.read(footballApiKeyStoreProvider).saveApiKey(apiKey);
    ref.invalidate(footballApiKeyConfiguredProvider);
    ref.invalidate(footballApiKeyProvider);
    ref.invalidate(leaguesRepositoryProvider);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعداد API-Football'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'احصل على مفتاح مجاني من api-football.com ثم الصقه هنا.',
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            autofillHints: const [AutofillHints.password],
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(
              hintText: 'your-api-key',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
