import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/percent_ring.dart';
import 'task_history_screen.dart' show formatHistoryDay;

/// Geçmişte belirli bir günün görev listesi ve odaklanma süresi. Salt-okunur
/// — [TaskHistoryScreen]'deki günlük sekmeden açılır.
class DayDetailScreen extends ConsumerWidget {
  final DateTime date;
  const DayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskHistoryDetailProvider(date));
    final focusTime = ref.watch(focusMinutesForDateProvider(date));

    final completed = tasks.where((t) => t.completedToday).length;
    final total = tasks.length;
    final percent = total == 0 ? 0.0 : completed / total * 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(formatHistoryDay(date)),
      ),
      body: ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
                    border: Border.all(color: AppColors.chipUnselectedBorder.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      PercentRing(
                        size: 56,
                        percent: percent,
                        centerText: '%${percent.round()}',
                        centerFontSize: 12,
                        strokeWidth: 6,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completed / $total görev tamamlandı',
                            style: AppTextStyles.taskTitle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Odaklanma süresi: ${focusTime.inMinutes} dk',
                            style: AppTextStyles.statLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (final task in tasks) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.chipUnselectedBorder.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.completedToday ? AppColors.streakText : Colors.transparent,
                            border: Border.all(
                              color: task.completedToday
                                  ? AppColors.streakText
                                  : AppColors.taskCheckBorder,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: task.completedToday
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: task.completedToday
                                  ? AppColors.tabUnselectedText
                                  : AppColors.taskTitle,
                              decoration: task.completedToday ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}
