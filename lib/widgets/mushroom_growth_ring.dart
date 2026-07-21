import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum GrowthStage { spor, filiz, yarimBoy, tamBoy }

extension GrowthStageX on GrowthStage {
  static GrowthStage fromProgress(double progress) {
    if (progress < 0.25) return GrowthStage.spor;
    if (progress < 0.5) return GrowthStage.filiz;
    if (progress < 0.75) return GrowthStage.yarimBoy;
    return GrowthStage.tamBoy;
  }

  String get label => switch (this) {
        GrowthStage.spor => 'Spor',
        GrowthStage.filiz => 'Filiz',
        GrowthStage.yarimBoy => 'Yarım Boy',
        GrowthStage.tamBoy => 'Tam Boy',
      };

  double get scale => switch (this) {
        GrowthStage.spor => 0.35,
        GrowthStage.filiz => 0.60,
        GrowthStage.yarimBoy => 0.82,
        GrowthStage.tamBoy => 1.0,
      };
}

class MushroomGrowthRing extends StatelessWidget {
  final double progress;
  final String? mushroomSprite;
  final Duration? remaining;

  const MushroomGrowthRing({
    super.key,
    required this.progress,
    this.mushroomSprite,
    this.remaining,
  });

  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final stage = GrowthStageX.fromProgress(progress);
    return SizedBox(
      width: AppSizes.ringSize,
      height: AppSizes.ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow / Ring Shadow
          Container(
            width: AppSizes.ringSize - 10,
            height: AppSizes.ringSize - 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.progressFill.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
          // Circular Progress Indicator
          SizedBox(
            width: AppSizes.ringSize,
            height: AppSizes.ringSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: AppColors.progressTrackBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressFill),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center Mushroom & Time
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Growing Mushroom
              SizedBox(
                height: 72,
                child: Center(
                  child: AnimatedScale(
                    scale: stage.scale,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    child: mushroomSprite != null
                        ? Image.asset(
                            mushroomSprite!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                          )
                        : const Text(
                            '🍄',
                            style: TextStyle(fontSize: 48),
                          ),
                  ),
                ),
              ),
              if (remaining != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDuration(remaining!),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: AppColors.taskTitle,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Growth stage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gardenBanner,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stage.label,
                  style: AppTextStyles.bannerText.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
