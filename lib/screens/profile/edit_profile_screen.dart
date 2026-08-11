import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/economy_provider.dart';
import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile_photo_placeholder.dart';

/// İsim, kullanıcı adı, günlük hedef ve fotoğraf düzenleme ekranı. Kaydet'e
/// basınca [ProfileNotifier.updateProfile] çağrılır ve önceki ekrana dönülür.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _goalController;
  bool _initialized = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _goalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  /// Galeriden seçtirir, 400x400'e küçültüp %70 kaliteyle sıkıştırır (image_picker
  /// bunu seçim sırasında yapar), sonucu base64'e çevirip anında kaydeder.
  /// Firebase Storage yerine Firestore'da metin olarak tutuluyor — bkz.
  /// UserRepository.updateProfilePhoto.
  Future<void> _pickAndUploadPhoto() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final Uint8List bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);
      await ref.read(profileNotifierProvider.notifier).updatePhoto(base64String);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    final goal = int.tryParse(_goalController.text) ?? 120;
    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(_nameController.text, _usernameController.text, goal);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(userStatsProvider).value;

    if (!_initialized && stats != null) {
      _nameController.text = stats.displayName ?? '';
      _usernameController.text = stats.username ?? '';
      _goalController.text = stats.dailyGoalMinutes.toString();
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('İptal', style: AppTextStyles.legend.copyWith(fontWeight: FontWeight.w600)),
        ),
        leadingWidth: 72,
        title: const Text('Profili Düzenle', style: AppTextStyles.profileName),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Kaydet',
              style: TextStyle(color: AppColors.streakText, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding, vertical: 24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
              child: Stack(
                children: [
                  ProfilePhotoPlaceholder(photoBase64: stats?.photoBase64),
                  if (_uploadingPhoto)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.streakText,
                        border: Border.all(color: AppColors.background, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _EditCard(
              label: 'Ad Soyad',
              controller: _nameController,
              hintText: 'Ad Soyad',
              valueStyle: AppTextStyles.profileName,
            ),
            const SizedBox(height: 14),
            _EditCard(
              label: 'Kullanıcı Adı',
              controller: _usernameController,
              hintText: '@kullaniciadi',
              valueStyle: AppTextStyles.taskTitle,
            ),
            const SizedBox(height: 14),
            _EditCard(
              label: 'Günlük Hedef (dk)',
              controller: _goalController,
              keyboardType: TextInputType.number,
              valueStyle: AppTextStyles.streak,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextStyle valueStyle;

  const _EditCard({
    required this.label,
    required this.controller,
    required this.valueStyle,
    this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.statCardRadius - 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.statLabel),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: valueStyle,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: valueStyle.copyWith(color: AppColors.tabUnselectedText, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
