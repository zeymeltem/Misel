import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mushroom_catalog.dart';
import '../../data/user_repository.dart' show PurchaseResult;
import '../../providers/economy_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pixel_number.dart';
import '../../widgets/shop_item_card.dart';

/// Ana sayfanın alt kısmı: mağazadaki mantar türleri, satın alma burada tetiklenir.
class ShopSection extends ConsumerWidget {
  const ShopSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mushrooms = ref.watch(shopMushroomsProvider);
    final ownedIds = ref.watch(ownedMushroomIdsProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mağaza', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSizes.gap),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: mushrooms
                .map((m) => Padding(
                      padding: const EdgeInsets.only(right: AppSizes.gap),
                      child: ShopItemCard(
                        mushroom: m,
                        isOwned: ownedIds.contains(m.id),
                        onTap: () => _onBuy(context, ref, m, ownedIds.contains(m.id)),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _onBuy(
    BuildContext context,
    WidgetRef ref,
    MushroomCatalogItem mushroom,
    bool isOwned,
  ) async {
    if (isOwned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mushroom.name} zaten sizin bahçenizde büyüyebilir!')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satın Alma Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              mushroom.spriteAsset,
              width: 64,
              height: 64,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(height: 12),
            Text(
              '${mushroom.name} mantarını satın almak istiyor musunuz?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.coinBadge.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, size: 20, color: AppColors.coinBadgeText),
                  const SizedBox(width: 6),
                  NumberText(
                    '${mushroom.price} Coin',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coinBadgeText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(shopNotifierProvider.notifier).buy(mushroom.id);
    final result = ref.read(shopNotifierProvider);
    if (!context.mounted || result == null) return;

    final message = switch (result) {
      PurchaseResult.success => '${mushroom.name} satın alındı! Bahçene ekebilirsin.',
      PurchaseResult.alreadyOwned => 'Bu mantar zaten sende var.',
      PurchaseResult.insufficientCoins => 'Yetersiz coin. Daha fazla odaklanmalısın!',
      PurchaseResult.notFound => 'Mantar bulunamadı.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
