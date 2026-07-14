import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';

const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Bu haftanın günlük odak süresini (dakika) çubuk grafikte gösterir.
class DailyFocusChart extends ConsumerWidget {
  const DailyFocusChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatsProvider).value;
    final daily = stats?.dailyFocus ?? const [];
    final maxMinutes = daily.fold<int>(1, (m, d) => d.minutes > m ? d.minutes : m);
    final today = DateTime.now();

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
                'Günlük Odak Süresi',
                style: AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.taskTitle,
                ),
              ),
              const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.tabUnselectedText),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: AppSizes.chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < daily.length; i++)
                  _Bar(
                    heightFraction: daily[i].minutes / maxMinutes,
                    label: _dayLabels[i],
                    isToday: _isSameDay(daily[i].day, today),
                    minutes: daily[i].minutes,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Bar extends StatelessWidget {
  final double heightFraction;
  final String label;
  final bool isToday;
  final int minutes;

  const _Bar({
    required this.heightFraction,
    required this.label,
    required this.isToday,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    final barAreaHeight = AppSizes.chartHeight - 34; // Give space for top label and bottom label
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Exact Minutes Label
        Text(
          minutes > 0 ? '$minutes' : '0',
          style: TextStyle(
            fontSize: 9,
            fontWeight: minutes > 0 ? FontWeight.bold : FontWeight.normal,
            color: minutes > 0
                ? (isToday ? AppColors.chartBarActive : AppColors.tabSelectedBg)
                : AppColors.tabUnselectedText.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: AppSizes.barWidth,
          height: (barAreaHeight * heightFraction).clamp(4.0, barAreaHeight),
          decoration: BoxDecoration(
            color: isToday ? AppColors.chartBarActive : AppColors.chartBarBg,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              if (isToday && minutes > 0)
                BoxShadow(
                  color: AppColors.chartBarActive.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.legend.copyWith(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppColors.taskTitle : AppColors.tabUnselectedText,
          ),
        ),
      ],
    );
  }
}
