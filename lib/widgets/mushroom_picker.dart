import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/economy_provider.dart';
import '../theme/app_theme.dart';

/// Seans boyunca büyütülecek mantarı seçmek için sahip olunan mantarları
/// gösterir. Seçim [onChanged] ile üst widget'a bildirilir.
class MushroomPicker extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String> onChanged;

  const MushroomPicker({super.key, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownedMushroomsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final mushroom in owned)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.gap),
              child: GestureDetector(
                onTap: () => onChanged(mushroom.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: AppSizes.swatchSize + 8,
                  height: AppSizes.swatchSize + 22,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: mushroom.id == selectedId
                        ? AppColors.gardenBanner.withValues(alpha: 0.5)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.swatchRadius),
                    border: Border.all(
                      color: mushroom.id == selectedId
                          ? AppColors.swatchBorderSelected
                          : AppColors.swatchBorderIdle,
                      width: mushroom.id == selectedId ? 2 : 1,
                    ),
                    boxShadow: [
                      if (mushroom.id == selectedId)
                        BoxShadow(
                          color: AppColors.swatchBorderSelected.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SizedBox.expand(
                            child: Image.asset(
                              mushroom.spriteAsset,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mushroom.name.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: mushroom.id == selectedId
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: mushroom.id == selectedId
                              ? AppColors.gardenBannerText
                              : AppColors.tabUnselectedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
