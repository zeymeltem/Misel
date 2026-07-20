import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';

/// Profil ekranındaki hesap yönetimi: çıkış yap + hesabı sil (Play Store
/// zorunluluğu). Silme onaylı; gerekirse yeniden kimlik doğrulama ister.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hesap', style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
            border: Border.all(color: AppColors.chipUnselectedBorder.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _AccountRow(
                icon: Icons.logout_rounded,
                label: 'Çıkış yap',
                onTap: () => _signOut(context, ref),
              ),
              Divider(height: 1, color: AppColors.chipUnselectedBorder.withOpacity(0.5)),
              _AccountRow(
                icon: Icons.delete_forever_rounded,
                label: 'Hesabımı sil',
                color: Colors.redAccent,
                onTap: () => _deleteAccount(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış yap?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Çıkış yap')),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(accountNotifierProvider.notifier).signOut();
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabını sil?'),
        content: const Text(
          'Bu işlem geri alınamaz. Tüm seansların, görevlerin, etiketlerin ve '
          'bahçen kalıcı olarak silinecek.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Evet, hesabımı sil'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    await _performDelete(context, ref);
  }

  Future<void> _performDelete(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(accountNotifierProvider.notifier);
    try {
      await notifier.deleteAccount();
    } catch (e) {
      if (!context.mounted) return;
      if (isRequiresRecentLogin(e)) {
        final reauthed = await _showReauthDialog(context, ref);
        if (reauthed && context.mounted) {
          await _performDelete(context, ref);
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hesap silinemedi: ${mapAuthErrorToTurkish(e)}')),
      );
    }
  }

  Future<bool> _showReauthDialog(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(accountNotifierProvider.notifier);
    if (notifier.signedInWithGoogle) {
      try {
        await notifier.reauthenticateWithGoogle();
        return true;
      } catch (e) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAuthErrorToTurkish(e))),
        );
        return false;
      }
    }

    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tekrar giriş yap'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Güvenlik için hesabını silmeden önce şifreni tekrar girmen gerekiyor.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Doğrula'),
          ),
        ],
      ),
    );
    if (password == null || password.isEmpty || !context.mounted) return false;

    try {
      await notifier.reauthenticateWithPassword(password);
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapAuthErrorToTurkish(e))),
      );
      return false;
    }
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _AccountRow({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.taskTitle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: effectiveColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.taskTitle.copyWith(color: effectiveColor),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.tabUnselectedText),
          ],
        ),
      ),
    );
  }
}
