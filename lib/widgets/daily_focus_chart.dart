import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import 'pixel_number.dart';

const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Bu haftanın günlük odak süresini (dakika) çubuk grafikte gösterir.
class DailyFocusChart extends ConsumerWidget {
  const DailyFocusChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatsProvider);
    final daily = stats.dailyFocus;
    final maxMinutes = daily.fold<int>(1, (m, d) => d.minutes > m ? d.minutes : m);
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: AppColors.chipUnselectedBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu Hafta (dk)',
            style: AppTextStyles.fieldLabel.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.taskTitle,
            ),
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Exact Minutes Label
        NumberText(
          minutes > 0 ? '$minutes' : '0',
          style: TextStyle(
            fontSize: 8,
            fontWeight: minutes > 0 ? FontWeight.bold : FontWeight.normal,
            color: minutes > 0
                ? (isToday ? AppColors.chartBarActive : AppColors.tabSelectedBg)
                : AppColors.tabUnselectedText.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        // Kalan yüksekliği (metin etiketlerinden arta kalan) Expanded alır;
        // böylece etiketlerin gerçek satır yüksekliği platforma göre değişse
        // bile RenderFlex taşması olmaz.
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFraction.clamp(0.05, 1.0),
              child: Container(
                width: AppSizes.barWidth,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.chartBarActive : AppColors.chartBarBg,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    if (isToday && minutes > 0)
                      BoxShadow(
                        color: AppColors.chartBarActive.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                  ],
                ),
              ),
            ),
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
