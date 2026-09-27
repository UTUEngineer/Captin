import 'package:flutter/material.dart';
import '../repositories/tactical_board_repository.dart';
import '../services/tactical_session_service.dart';

class SaveTacticDialog extends StatefulWidget {
  final Map<String, dynamic>? aiReport;

  const SaveTacticDialog({super.key, this.aiReport});

  @override
  State<SaveTacticDialog> createState() => _SaveTacticDialogState();
}

class _SaveTacticDialogState extends State<SaveTacticDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _opponentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = TacticalSessionService.instance.activeMatchTitle ?? 'خطة المباراة القادمة';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _opponentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final savedId = await TacticalBoardRepository.instance.saveTactic(
      title: _titleController.text.trim(),
      formation: TacticalSessionService.instance.activeFormation ?? '4-3-3',
      opponentName: _opponentController.text.trim(),
      matchNotes: _notesController.text.trim(),
      players: TacticalSessionService.instance.activePlayers,
      aiReport: widget.aiReport,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (savedId != null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF10B981),
            content: Text('تم حفظ الخطة بنجاح في السحابة!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('فشل الحفظ. تأكد من تسجيل الدخول والاتصال بالإنترنت.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.cloud_upload_outlined, color: Color(0xFF10B981)),
          SizedBox(width: 8),
          Text('حفظ الخطة التكتيكية', style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('عنوان الخطة / المباراة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _opponentController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('اسم الفريق الخصم (اختياري)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('ملاحظات المدرب وتوجيهات التبديل'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('حفظ في السحابة', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}
