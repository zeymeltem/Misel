import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Yüzdelik donut halka: dıştan renkli ilerleme, ortada metin. Görev
/// Tamamlama kartında, görev geçmişi liste öğelerinde ve gün detayı
/// başlığında farklı boyutlarda tekrar kullanılır.
class PercentRing extends StatelessWidget {
  final double size;
  final double percent;
  final String centerText;
  final double centerFontSize;
  final double strokeWidth;

  const PercentRing({
    super.key,
    required this.size,
    required this.percent,
    required this.centerText,
    this.centerFontSize = 18,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: AppColors.progressTrackBg,
            valueColor: const AlwaysStoppedAnimation(AppColors.streakText),
            strokeCap: StrokeCap.round,
          ),
          Text(
            centerText,
            style: AppTextStyles.statValue.copyWith(fontSize: centerFontSize),
          ),
        ],
      ),
    );
  }
}
