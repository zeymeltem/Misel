import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

/// Zorunlu giriş ekranı: e-posta/şifre + Google. Kullanıcı giriş yapmadan
/// uygulamanın geri kalanına erişemez (bkz. main.dart'taki auth kapısı).
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormNotifierProvider);
    final notifier = ref.read(authFormNotifierProvider.notifier);
    final isLogin = formState.mode == AuthMode.login;

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
                  const Text('🍄', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    'Mantar Odak',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLogin ? 'Devam etmek için giriş yap' : 'Yeni hesap oluştur',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.legend,
                  ),
                  const SizedBox(height: 32),

                  if (formState.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        formState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!isLogin) ...[
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _usernameController,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı adı',
                        hintText: '@kullaniciadi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: 6),
                    Text(
                      'En az 8 karakter; büyük/küçük harf ve rakam içermeli.',
                      style: AppTextStyles.legend,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: formState.loading ? null : () => _showForgotPasswordDialog(notifier),
                      child: const Text('Şifremi unuttum', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  FilledButton(
                    onPressed: formState.loading ? null : () => _submitEmail(notifier),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.tabSelectedBg,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                    ),
                    child: formState.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isLogin ? 'Giriş yap' : 'Kayıt ol'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: formState.loading
                        ? null
                        : () => notifier.setMode(isLogin ? AuthMode.register : AuthMode.login),
                    child: Text(isLogin ? 'Hesabın yok mu? Kayıt ol' : 'Zaten hesabın var mı? Giriş yap'),
                  ),

                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('veya', style: AppTextStyles.legend),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: formState.loading ? null : () => notifier.submitGoogle(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.outlineButtonBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                    ),
                    icon: const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    label: const Text('Google ile devam et'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitEmail(AuthFormNotifier notifier) {
    notifier.submitEmail(
      _emailController.text,
      _passwordController.text,
      name: _nameController.text,
      username: _usernameController.text,
    );
  }

  Future<void> _showForgotPasswordDialog(AuthFormNotifier notifier) async {
    final controller = TextEditingController(text: _emailController.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifremi unuttum'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            hintText: 'kayitli@eposta.com',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
    if (email == null || email.trim().isEmpty || !mounted) return;

    final error = await notifier.sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Şifre sıfırlama bağlantısı e-postana gönderildi.'),
      ),
    );
  }
}
