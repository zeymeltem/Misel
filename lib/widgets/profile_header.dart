import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/economy_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import 'streak_badge.dart';

String _initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

/// Profil başlığı: avatar, isim, seri bilgisi ve isim düzenleme.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider).value;
    final name = (stats?.displayName?.trim().isNotEmpty ?? false)
        ? stats!.displayName!
        : 'İsimsiz Kaşif';
    final longest = stats?.longestStreak ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tabSelectedBg,
            AppColors.tabSelectedBg.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.tabSelectedBg.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          // Styled Avatar
          Container(
            width: AppSizes.avatarSize + 4,
            height: AppSizes.avatarSize + 4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.avatarBg, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              _initialsOf(name),
              style: AppTextStyles.avatarInitials.copyWith(
                color: AppColors.tabSelectedBg,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.profileName.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const StreakBadge(
                        suffix: 'gün',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'en uzun seri: $longest',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Edit Profile Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
              onPressed: () => _showRenameDialog(context, ref, name),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current == 'İsimsiz Kaşif' ? '' : current);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İsmini düzenle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Örn. Elif K.',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    await ref.read(profileNotifierProvider.notifier).rename(result);
  }
}
