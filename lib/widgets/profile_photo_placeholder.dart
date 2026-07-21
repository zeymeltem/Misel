import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Salt görüntüleme amaçlı avatar: [photoBase64] varsa gösterir, yoksa nötr
/// bir kişi ikonu. "Fotoğraf ekle" daveti kasıtlı olarak burada değil —
/// düzenleme eylemi sadece [EditProfileScreen]'de yaşar (bkz. o dosyadaki
/// `_EditablePhotoAvatar`).
class ProfilePhotoPlaceholder extends StatelessWidget {
  final double size;
  final String? photoBase64;

  const ProfilePhotoPlaceholder({super.key, this.size = AppSizes.avatarSize, this.photoBase64});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBase64 != null && photoBase64!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.statCardBg,
        border: Border.all(color: AppColors.streakText, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasPhoto
          ? Image.memory(
              base64Decode(photoBase64!),
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Icon(Icons.person_outline, color: AppColors.streakText, size: size * 0.45),
    );
  }
}
