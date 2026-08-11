import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum GrowthStage { spor, filiz, tamBoy }

extension GrowthStageX on GrowthStage {
  static GrowthStage fromProgress(double progress) {
    if (progress < 1 / 3) return GrowthStage.spor;
    if (progress < 2 / 3) return GrowthStage.filiz;
    return GrowthStage.tamBoy;
  }

  String get label => switch (this) {
        GrowthStage.spor => 'Spor',
        GrowthStage.filiz => 'Filiz',
        GrowthStage.tamBoy => 'Tam Boy',
      };

  double get scale => switch (this) {
        GrowthStage.spor => 0.45,
        GrowthStage.filiz => 0.72,
        GrowthStage.tamBoy => 1.0,
      };

  int get index => switch (this) {
        GrowthStage.spor => 0,
        GrowthStage.filiz => 1,
        GrowthStage.tamBoy => 2,
      };
}

class MushroomGrowthRing extends StatelessWidget {
  final double progress;

  /// 4 büyüme evresinin sprite yolları: [spor, filiz, yarımBoy, tamBoy].
  /// bkz. [MushroomCatalogItem.growthSprites]. null ise emoji fallback.
  final List<String>? growthSprites;

  const MushroomGrowthRing({
    super.key,
    required this.progress,
    this.growthSprites,
  });

  @override
  Widget build(BuildContext context) {
    final stage = GrowthStageX.fromProgress(progress);
    final currentSprite = growthSprites != null ? growthSprites![stage.index] : null;
    return SizedBox(
      width: AppSizes.ringSize,
      height: AppSizes.ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Square backdrop for the sprite (frame matches sprite's own square shape)
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.progressFill.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
          // Center Mushroom & Time
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Growing Mushroom
              SizedBox(
                width: 190,
                height: 190,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: currentSprite != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              currentSprite,
                              key: ValueKey(currentSprite),
                              width: 190,
                              height: 190,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (context, error, stack) => const Text(
                                '🍄',
                                key: ValueKey('fallback'),
                                style: TextStyle(fontSize: 140),
                              ),
                            ),
                          )
                        : const Text(
                            '🍄',
                            key: ValueKey('fallback'),
                            style: TextStyle(fontSize: 140),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Growth stage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gardenBanner,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stage.label,
                  style: AppTextStyles.bannerText.copyWith(fontSize: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
