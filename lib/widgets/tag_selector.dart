import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tag_provider.dart';
import '../theme/app_theme.dart';

/// Etiket seçici: mevcut etiketleri chip olarak listeler, seçileni işaretler
/// ve yeni etiket eklemeyi sağlar. Seçim [onChanged] ile üst widget'a bildirilir.
class TagSelector extends ConsumerWidget {
  final int? selectedTagId;
  final ValueChanged<int?> onChanged;

  const TagSelector({super.key, required this.selectedTagId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider).value ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          _TagChip(
            label: tag.name,
            selected: tag.id == selectedTagId,
            color: AppColors.tagPalette[tag.colorIndex % AppColors.tagPalette.length],
            onTap: () => onChanged(tag.id == selectedTagId ? null : tag.id),
          ),
        _AddTagChip(onCreated: (id) => onChanged(id)),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.chipRadius),
          border: Border.all(
            color: selected ? color : AppColors.chipUnselectedBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.chip.copyWith(
                color: selected ? color : AppColors.chipUnselectedText,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTagChip extends ConsumerWidget {
  final ValueChanged<int> onCreated;
  const _AddTagChip({required this.onCreated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final name = await _promptTagName(context);
        if (name == null) return;
        if (name.trim().isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Etiket adı boş olamaz')),
          );
          return;
        }
        try {
          final tag = await ref.read(tagNotifierProvider.notifier).create(name);
          onCreated(tag.id);
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Etiket eklenemedi: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.chipRadius),
          border: Border.all(color: AppColors.chipAddBorder, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 14, color: AppColors.chipUnselectedText),
            const SizedBox(width: 4),
            Text(
              'yeni',
              style: AppTextStyles.chip.copyWith(
                color: AppColors.chipUnselectedText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptTagName(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni etiket'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Örn. Ders Çalışma',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
