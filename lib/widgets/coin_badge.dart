import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/economy_provider.dart';
import '../theme/app_theme.dart';

/// Sağ üstte coin bakiyesini gösteren rozet. Sadece [userStatsProvider]'ı okur.
class CoinBadge extends ConsumerWidget {
  const CoinBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final coins = stats.value?.totalCoins ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.coinBadge,
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, size: 16, color: AppColors.coinBadgeText),
          const SizedBox(width: 6),
          Text('$coins', style: AppTextStyles.coinValue),
        ],
      ),
    );
  }
}
