import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/timeline/application/timeline_providers.dart';
import 'package:captain/features/timeline/domain/timeline_event_type.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  const AddEventSheet({
    super.key,
    required this.initialMinute,
    this.matchId = defaultMatchId,
  });

  final double initialMinute;
  final String matchId;

  static Future<void> show(
    BuildContext context, {
    required double initialMinute,
    String matchId = defaultMatchId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AddEventSheet(
          initialMinute: initialMinute,
          matchId: matchId,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  late final TextEditingController _minuteController;
  late final TextEditingController _secondController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _playerController;
  TimelineEventType _selectedType = TimelineEventType.keyMoment;
  var _linkCurrentBoard = false;

  @override
  void initState() {
    super.initState();
    final minute = widget.initialMinute.floor();
    final second = ((widget.initialMinute - minute) * 60).round().clamp(0, 59);
    _minuteController = TextEditingController(text: '$minute');
    _secondController = TextEditingController(text: '$second');
    _descriptionController = TextEditingController();
    _playerController = TextEditingController();
  }

  @override
  void dispose() {
    _minuteController.dispose();
    _secondController.dispose();
    _descriptionController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final minute = int.tryParse(_minuteController.text.trim()) ?? 0;
    final second = int.tryParse(_secondController.text.trim()) ?? 0;
    final controller =
        ref.read(timelineControllerProvider(widget.matchId).notifier);

    final linkedSnapshot = _linkCurrentBoard
        ? controller.buildBoardSnapshotFrom(ref.read(tacticalBoardProvider))
        : null;

    await controller.addEvent(
      minute: minute,
      second: second.clamp(0, 59),
      type: _selectedType,
      description: _descriptionController.text.trim(),
      playerName: _playerController.text.trim().isEmpty
          ? null
          : _playerController.text.trim(),
      linkedSnapshot: linkedSnapshot,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'إضافة حدث',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minuteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minute',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _secondController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Second',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Event type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimelineEventType.values.map((type) {
                final selected = _selectedType == type;
                return ChoiceChip(
                  avatar: Icon(type.icon, size: 16, color: type.color),
                  label: Text(
                    type.arabicLabel,
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'ملاحظة تكتيكية...',
                border: const OutlineInputBorder(),
                labelStyle: GoogleFonts.cairo(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _playerController,
              decoration: const InputDecoration(
                labelText: 'Player (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Link to current board'),
              subtitle: const Text('Save a snapshot of the tactical board'),
              value: _linkCurrentBoard,
              onChanged: (value) => setState(() => _linkCurrentBoard = value),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submit,
              child: Text('Save event', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}
