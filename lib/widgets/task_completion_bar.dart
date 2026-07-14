import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';

/// Bu hafta tamamlanan görevlerin oranını gösteren ilerleme çubuğu.
class TaskCompletionBar extends ConsumerWidget {
  const TaskCompletionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = ref.watch(weeklyStatsProvider).value?.taskCompletionPercent ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: AppColors.chipUnselectedBorder.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Görev Tamamlama',
                style: AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.taskTitle,
                ),
              ),
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.taskCheckedBg),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.progressBarHeight / 2),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: AppSizes.progressBarHeight + 2,
              backgroundColor: AppColors.progressTrackBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.taskCheckedBg),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tamamlanan görevler',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tabUnselectedText.withOpacity(0.8),
                ),
              ),
              Text(
                '%${percent.round()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.taskCheckedBg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
