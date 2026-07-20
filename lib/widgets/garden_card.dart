import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/economy_provider.dart';
import '../providers/garden_provider.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';
import 'garden_map.dart';

/// Ana sayfanın üst kısmı: bahçe başlığı, coin rozeti, parsel ilerleme
/// banner'ı ve bahçe haritası ([GardenMap]). Harita tamamen Session
/// kayıtlarından türetilir, ayrı bir yerde saklanmaz.
class GardenCard extends ConsumerWidget {
  const GardenCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(gardenProgressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bahçen', style: AppTextStyles.sectionTitle),
            const CoinBadge(),
          ],
        ),
        const SizedBox(height: AppSizes.gap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gardenBanner,
            borderRadius: BorderRadius.circular(AppSizes.bannerRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'yeni parsel: ${progress.sessionsUntilNextPlot} seans',
                style: AppTextStyles.bannerText,
              ),
              if (kDebugMode) const _DevAddFakeSessionsButton(),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gap),
        const GardenMap(),
      ],
    );
  }
}

/// Sadece debug modda görünür: haritayı 500 sahte seansla doldurup
/// performansı denemek için (bkz. [GardenDevNotifier]).
class _DevAddFakeSessionsButton extends ConsumerWidget {
  const _DevAddFakeSessionsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(gardenDevNotifierProvider.notifier).addFakeSessions(500),
      child: const Text(
        '+500 test seansı',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.gardenBannerText,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
