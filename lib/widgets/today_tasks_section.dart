import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_provider.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';

/// "Bugün görevleri": günlük rutinler + tek seferlik görevler, işaretlenebilir.
class TodayTasksSection extends ConsumerWidget {
  const TodayTasksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bugünün Görevleri', style: AppTextStyles.sectionTitle),
            if (tasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gardenBanner,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tasks.where((t) => t.completedToday).length}/${tasks.length} tamamlandı',
                  style: AppTextStyles.bannerText.copyWith(fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.gap),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.taskCardRadius),
                border: Border.all(color: AppColors.chipUnselectedBorder.withOpacity(0.5)),
              ),
              child: const Text(
                'Bugün için planlanmış bir görev yok. Yeni bir görev ekleyerek başlayabilirsin!',
                style: TextStyle(fontSize: 12, color: AppColors.tabUnselectedText, height: 1.4),
              ),
            ),
          ),
        for (final task in tasks) ...[
          _TaskRow(task: task),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        _AddTaskButton(),
      ],
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final TaskItem task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(taskNotifierProvider.notifier).toggle(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.taskCardBg,
          borderRadius: BorderRadius.circular(AppSizes.taskCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: task.completedToday
                ? AppColors.chipUnselectedBorder.withOpacity(0.3)
                : AppColors.chipUnselectedBorder.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _Checkbox(checked: task.completedToday),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.taskTitle.copyWith(
                  color: task.completedToday ? AppColors.taskTitleDone : AppColors.taskTitle,
                  decoration: task.completedToday ? TextDecoration.lineThrough : null,
                  fontSize: 14,
                ),
                child: Text(task.title),
              ),
            ),
            if (task.isRoutine) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.routineBadgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('rutin', style: AppTextStyles.routineBadge),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool checked;
  const _Checkbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: checked ? AppColors.taskCheckedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked ? AppColors.taskCheckedBg : AppColors.taskCheckBorder,
          width: 2.0,
        ),
        boxShadow: [
          if (checked)
            BoxShadow(
              color: AppColors.taskCheckedBg.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _AddTaskButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _showAddTaskDialog(context, ref),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: AppColors.chipAddBorder, width: 1.2),
        foregroundColor: AppColors.tabUnselectedText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
      ),
      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
      label: const Text(
        'Görev Ekle',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    var isRoutine = false;

    final result = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Yeni Görev Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Örn. Matematik ödevi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: isRoutine,
                onChanged: (v) => setState(() => isRoutine = v ?? false),
                title: const Text('Her gün tekrarlansın (Rutin)', style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop((controller.text, isRoutine)),
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );

    if (result == null || result.$1.trim().isEmpty) return;
    await ref.read(taskNotifierProvider.notifier).add(result.$1, isRoutine: result.$2);
  }
}
