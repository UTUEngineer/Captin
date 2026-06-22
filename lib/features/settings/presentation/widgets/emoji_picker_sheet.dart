import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:flutter/material.dart';

class EmojiPickerSheet extends StatelessWidget {
  const EmojiPickerSheet({
    super.key,
    required this.selectedEmoji,
    required this.onSelected,
  });

  final String selectedEmoji;
  final ValueChanged<String> onSelected;

  static Future<void> show(
    BuildContext context, {
    required String selectedEmoji,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => EmojiPickerSheet(
        selectedEmoji: selectedEmoji,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: avatarEmojiOptions.length,
          itemBuilder: (context, index) {
            final emoji = avatarEmojiOptions[index];
            final isSelected = emoji == selectedEmoji;
            return InkWell(
              onTap: () {
                onSelected(emoji);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            );
          },
        ),
      ),
    );
  }
}
