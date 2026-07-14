import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/daily_focus_chart.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/tag_distribution_bar.dart';
import '../../widgets/task_completion_bar.dart';

/// Profil ve rapor: kullanıcı bilgisi, seri, haftalık odak/başarı/etiket/
/// görev istatistikleri. Widget yalnızca provider'lardan okur.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(weeklyStatsProvider).value;
    final focusTime = stats?.focusTime ?? Duration.zero;
    final successRate = stats?.successRatePercent ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileHeader(),
          const SizedBox(height: 20),
          Row(
            children: [
              StatCard(
                label: 'Bu hafta',
                value: '${focusTime.inHours}s ${focusTime.inMinutes.remainder(60)}dk',
                icon: Icons.access_time_filled_rounded,
                iconColor: Colors.teal,
              ),
              const SizedBox(width: AppSizes.gap),
              StatCard(
                label: 'Başarı',
                value: '%${successRate.round()}',
                icon: Icons.emoji_events_rounded,
                iconColor: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const DailyFocusChart(),
          const SizedBox(height: 16),
          const TagDistributionBar(),
          const SizedBox(height: 16),
          const TaskCompletionBar(),
        ],
      ),
    );
  }
}
