import 'package:captain/core/theme/app_colors.dart';
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
          SnackBar(
            backgroundColor: AppColors.primary,
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
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('حفظ الخطة التكتيكية', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('عنوان الخطة / المباراة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _opponentController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('اسم الفريق الخصم (اختياري)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('ملاحظات المدرب وتوجيهات التبديل'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
              : Text('حفظ في السحابة', style: TextStyle(color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}
