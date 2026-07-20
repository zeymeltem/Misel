import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/economy_provider.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../theme/app_theme.dart';
import 'profile_photo_placeholder.dart';

/// Profil başlığı: fotoğraf yer tutucusu, isim, kullanıcı adı ve günlük
/// hedef. Tüm düzenleme [EditProfileScreen]'de yapılır; buradaki "Düzenle"
/// pili oraya yönlendirir.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider).value;
    final name = (stats?.displayName?.trim().isNotEmpty ?? false)
        ? stats!.displayName!
        : 'İsimsiz Kaşif';
    final username = stats?.username?.trim();
    final dailyGoal = stats?.dailyGoalMinutes ?? 120;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const ProfilePhotoPlaceholder(),
              const SizedBox(height: 12),
              Text(name, style: AppTextStyles.profileName.copyWith(fontSize: 19)),
              if (username != null && username.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('@$username', style: AppTextStyles.legend.copyWith(fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Günlük hedef  ', style: AppTextStyles.legend.copyWith(fontWeight: FontWeight.w600)),
                    Text('$dailyGoal dk', style: AppTextStyles.streak),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardBackground,
              foregroundColor: AppColors.taskTitle,
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.cardBackground,
              foregroundColor: AppColors.streakText,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.pillRadius),
              ),
            ),
            child: const Text('Düzenle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
