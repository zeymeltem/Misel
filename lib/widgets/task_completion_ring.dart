import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../screens/profile/task_history_screen.dart';
import '../theme/app_theme.dart';
import 'percent_ring.dart';

/// Bu hafta tamamlanan görevlerin oranını donut grafikte gösterir; altında
/// [TaskHistoryScreen]'e giden gömülü bir "Görev Geçmişi" satırı bulunur.
class TaskCompletionRing extends ConsumerWidget {
  const TaskCompletionRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatsProvider);
    final percent = stats.taskCompletionPercent;
    final completed = stats.completedTaskCount;
    final total = stats.totalTaskCount;

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Görev Tamamlama',
                  style: AppTextStyles.fieldLabel.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.taskTitle,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PercentRing(
                      size: AppSizes.taskRingSize,
                      percent: percent,
                      centerText: '%${percent.round()}',
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tamamlanan görevler', style: AppTextStyles.statLabel),
                          const SizedBox(height: 6),
                          Text('$completed / $total', style: AppTextStyles.statValue),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSizes.statCardRadius)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TaskHistoryScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.chipUnselectedBorder.withOpacity(0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 16, color: AppColors.taskTitle),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Görev Geçmişi', style: AppTextStyles.taskTitle),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.tabUnselectedText),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
