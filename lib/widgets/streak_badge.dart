import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/economy_provider.dart';
import '../theme/app_theme.dart';

/// Kullanıcının güncel seri (streak) bilgisini gösterir. Sadece
/// [userStatsProvider]'ı okur.
class StreakBadge extends ConsumerWidget {
  final String suffix;
  const StreakBadge({super.key, this.suffix = 'gün'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(userStatsProvider).value?.currentStreak ?? 0;
    return Text('🔥 $streak $suffix', style: AppTextStyles.streak);
  }
}
