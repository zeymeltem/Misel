import 'package:flutter/material.dart';

import '../models/mushroom_type.dart';
import '../theme/app_theme.dart';

/// Tek bir mağaza kartı: mantar görseli + fiyat (veya "Sahip" rozeti).
/// Sadece verilen [mushroom] verisini gösterir, satın alma mantığı içermez.
class ShopItemCard extends StatelessWidget {
  final MushroomType mushroom;
  final VoidCallback onTap;

  const ShopItemCard({super.key, required this.mushroom, required this.onTap});

  Color _getTierColor(MushroomTier tier) {
    return switch (tier) {
      MushroomTier.starter => AppColors.tabUnselectedText,
      MushroomTier.common => AppColors.shopIconCommon,
      MushroomTier.rare => AppColors.shopIconRare,
      MushroomTier.epic => Colors.purple,
      MushroomTier.legendary => AppColors.shopIconLegendary,
    };
  }

  String _getTierLabel(MushroomTier tier) {
    return switch (tier) {
      MushroomTier.starter => 'Başlangıç',
      MushroomTier.common => 'Yaygın',
      MushroomTier.rare => 'Nadir',
      MushroomTier.epic => 'Destansı',
      MushroomTier.legendary => 'Efsanevi',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(mushroom.tier);
    final tierLabel = _getTierLabel(mushroom.tier);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: AppSizes.shopItemSize + 16,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.shopItemRadius),
          border: Border.all(
            color: mushroom.isOwned ? AppColors.chipUnselectedBorder : tierColor.withOpacity(0.5),
            width: mushroom.isOwned ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: tierColor.withOpacity(mushroom.isOwned ? 0.04 : 0.1),
              blurRadius: mushroom.isOwned ? 4 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tier Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tierLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: tierColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Mushroom Sprite
            Hero(
              tag: 'shop_mushroom_${mushroom.id}',
              child: Image.asset(mushroom.spriteAsset, width: 44, height: 44),
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              mushroom.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tab.copyWith(
                fontSize: 12,
                color: AppColors.taskTitle,
              ),
            ),
            const SizedBox(height: 6),
            // Pricing or Ownership status
            mushroom.isOwned
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: AppColors.shopIconCommon.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      const Text(
                        'Açık',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.shopIconCommon,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, size: 13, color: AppColors.coinBadgeText),
                      const SizedBox(width: 4),
                      Text(
                        '${mushroom.price}',
                        style: AppTextStyles.shopPrice.copyWith(
                          color: AppColors.coinBadgeText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
