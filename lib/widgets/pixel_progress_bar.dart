import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pixel-art tarzı ilerleme çubuğu: köşeleri keskin, tek tek kareler halinde
/// dolan bir bar. Dairesel [CircularProgressIndicator] yerine mantarın
/// altında kullanılır (bkz. [MushroomGrowthRing]).
class PixelProgressBar extends StatelessWidget {
  final double progress;
  final int segmentCount;
  final double blockSize;
  final double gap;

  const PixelProgressBar({
    super.key,
    required this.progress,
    this.segmentCount = 12,
    this.blockSize = 12,
    this.gap = 3,
  });

  @override
  Widget build(BuildContext context) {
    final filled = (progress.clamp(0.0, 1.0) * segmentCount).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(segmentCount, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: EdgeInsets.only(right: i == segmentCount - 1 ? 0 : gap),
          child: Container(
            width: blockSize,
            height: blockSize,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.progressFill : AppColors.progressTrackBg,
              border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
            ),
          ),
        );
      }),
    );
  }
}
