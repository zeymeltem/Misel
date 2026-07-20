import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';

/// Bu hafta etiketlere göre harcanan zamanın oransal dağılımı.
class TagDistributionBar extends ConsumerWidget {
  const TagDistributionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shares = ref.watch(weeklyStatsProvider).tagShares;

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
                'Etiket Dağılımı',
                style: AppTextStyles.fieldLabel.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.taskTitle,
                ),
              ),
              const Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.tabUnselectedText),
            ],
          ),
          const SizedBox(height: 16),
          if (shares.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Bu hafta etiketli seans yok.',
                style: TextStyle(fontSize: 12, color: AppColors.tabUnselectedText),
              ),
            )
          else ...[
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (final share in shares)
                      Expanded(
                        flex: (share.percent * 10).round().clamp(1, 1000),
                        child: Container(
                          color: AppColors.tagPalette[share.colorIndex % AppColors.tagPalette.length],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legends Grid/Wrap
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: shares.map((share) {
                final color = AppColors.tagPalette[share.colorIndex % AppColors.tagPalette.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      share.tagName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.taskTitle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '%${share.percent.round()}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.tabUnselectedText,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
