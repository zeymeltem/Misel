import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fotoğraf yükleme henüz uygulanmadı; `assets/images` altına gerçek görsel
/// eklendiğinde bu alan bir Image.asset ile değiştirilecek.
class ProfilePhotoPlaceholder extends StatelessWidget {
  final double size;

  const ProfilePhotoPlaceholder({super.key, this.size = AppSizes.avatarSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.statCardBg,
        border: Border.all(color: AppColors.streakText, width: 3),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, color: AppColors.streakText, size: size * 0.23),
          const SizedBox(height: 4),
          Text(
            'Fotoğraf ekle',
            textAlign: TextAlign.center,
            style: AppTextStyles.legend.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
