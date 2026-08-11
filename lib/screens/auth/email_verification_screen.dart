import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

/// E-posta/şifre ile kayıt olan kullanıcı doğrulama linkine tıklamadan
/// uygulamanın geri kalanına giremez (bkz. main.dart'taki
/// `needsEmailVerification` kontrolü). Google girişi bu ekrandan hiç geçmez.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _checking = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    await ref.read(authRepositoryProvider).sendEmailVerification();
    if (!mounted) return;
    _startCooldown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Doğrulama e-postası tekrar gönderildi.')),
    );
  }

  Future<void> _checkVerified() async {
    setState(() => _checking = true);
    final verified = await ref.read(authRepositoryProvider).reloadAndCheckEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (verified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingGate()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Henüz doğrulanmamış görünüyor. E-postanı kontrol et.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(authRepositoryProvider).currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('📧', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'E-postanı doğrula',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$email adresine bir doğrulama bağlantısı gönderdik. '
                    'Gelen kutunu (ve spam klasörünü) kontrol edip bağlantıya tıkla.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.legend,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _checking ? null : _checkVerified,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.tabSelectedBg,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                    ),
                    child: _checking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Doğruladım, devam et'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _resendCooldown > 0 ? null : _resend,
                    child: Text(
                      _resendCooldown > 0
                          ? 'Tekrar gönder ($_resendCooldown sn)'
                          : 'Tekrar gönder',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    child: const Text('Çıkış yap', style: TextStyle(color: AppColors.tabUnselectedText)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
