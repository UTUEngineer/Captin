import 'package:captain/features/scouting/application/scouting_providers.dart';
import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ClaudeApiKeyDialog extends ConsumerStatefulWidget {
  const ClaudeApiKeyDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ClaudeApiKeyDialog(),
    );
  }

  @override
  ConsumerState<ClaudeApiKeyDialog> createState() => _ClaudeApiKeyDialogState();
}

class _ClaudeApiKeyDialogState extends ConsumerState<ClaudeApiKeyDialog> {
  final _controller = TextEditingController();
  var _isTesting = false;
  String? _error;
  String? _testResponse;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAnthropicConsole() async {
    final uri = Uri.parse('https://console.anthropic.com/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveAndTest() async {
    final apiKey = _controller.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _error = 'الرجاء إدخال مفتاح API.');
      return;
    }

    setState(() {
      _isTesting = true;
      _error = null;
      _testResponse = null;
    });

    try {
      final repository = ref.read(scoutingReportRepositoryProvider);
      final response = await repository.testApiKey(apiKey);
      await ref.read(claudeApiKeyStoreProvider).saveApiKey(apiKey);
      ref.invalidate(claudeApiKeyConfiguredProvider);
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testResponse = response.trim();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'إعداد Claude API',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '1. احصل على مفتاح API من Anthropic',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openAnthropicConsole,
              icon: const Icon(Icons.open_in_new),
              label: const Text('فتح console.anthropic.com'),
            ),
            const SizedBox(height: 16),
            Text(
              '2. الصق المفتاح هنا',
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [AutofillHints.password],
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                hintText: 'sk-ant-...',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_testResponse != null) ...[
              const SizedBox(height: 8),
              Text(
                '3. الاختبار نجح: $_testResponse',
                style: GoogleFonts.cairo(),
                textDirection: TextDirection.rtl,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        if (_testResponse != null)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تم'),
          )
        else
          FilledButton(
            onPressed: _isTesting ? null : _saveAndTest,
            child: _isTesting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('اختبار وحفظ'),
          ),
      ],
    );
  }
}
