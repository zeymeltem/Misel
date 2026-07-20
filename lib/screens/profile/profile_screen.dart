import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/economy_provider.dart';
import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_section.dart';
import '../../widgets/daily_focus_chart.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/tag_distribution_bar.dart';
import '../../widgets/task_completion_ring.dart';

/// Profil ve rapor: kullanıcı bilgisi, seri, haftalık odak/etiket/görev
/// istatistikleri. Widget yalnızca provider'lardan okur.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalFocusTime = ref.watch(totalFocusTimeProvider);
    final currentStreak = ref.watch(userStatsProvider).value?.currentStreak ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileHeader(),
          const SizedBox(height: 24),
          Text('Çalışma İstatistikleri', style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            children: [
              StatCard(
                label: 'Toplam Süre',
                value:
                    '${totalFocusTime.inHours}sa ${totalFocusTime.inMinutes.remainder(60)}dk',
                icon: Icons.access_time_filled_rounded,
                iconColor: AppColors.taskTitle,
              ),
              const SizedBox(width: AppSizes.gap),
              StatCard(
                label: 'Seri',
                value: '$currentStreak gün',
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.streakText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const DailyFocusChart(),
          const SizedBox(height: 16),
          const TagDistributionBar(),
          const SizedBox(height: 16),
          const TaskCompletionRing(),
          const SizedBox(height: 24),
          const AccountSection(),
        ],
      ),
    );
  }
}
