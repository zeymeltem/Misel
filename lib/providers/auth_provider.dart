import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

/// Uygulamanın giriş kapısı: null ise giriş yapılmamış demektir.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Giriş yapılmış kullanıcının uid'si. Veri provider'ları bunu izleyerek
/// hesap değişince/çıkışta doğru şekilde yeniden kurulur.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

enum AuthMode { login, register }

class AuthFormState {
  final AuthMode mode;
  final bool loading;
  final String? errorMessage;

  const AuthFormState({this.mode = AuthMode.login, this.loading = false, this.errorMessage});

  AuthFormState copyWith({AuthMode? mode, bool? loading, String? errorMessage}) {
    return AuthFormState(
      mode: mode ?? this.mode,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}

final authFormNotifierProvider =
    NotifierProvider<AuthFormNotifier, AuthFormState>(AuthFormNotifier.new);

/// Login ekranının durumu: yükleniyor mu, hata var mı, giriş mi kayıt modu mu.
class AuthFormNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setMode(AuthMode mode) => state = state.copyWith(mode: mode, errorMessage: null);

  Future<void> submitEmail(
    String email,
    String password, {
    String? name,
    String? username,
  }) async {
    if (state.mode == AuthMode.register) {
      final passwordError = validatePasswordStrength(password);
      if (passwordError != null) {
        state = state.copyWith(errorMessage: passwordError);
        return;
      }
    }

    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (state.mode == AuthMode.login) {
        await repo.signInWithEmail(email, password);
      } else {
        await repo.registerWithEmail(email, password);
        final uid = repo.currentUser?.uid;
        if (uid != null && ((name?.trim().isNotEmpty ?? false) || (username?.trim().isNotEmpty ?? false))) {
          await UserRepository().updateProfile(
            uid,
            name: name ?? '',
            username: username ?? '',
            dailyGoalMinutes: 120,
          );
        }
      }
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, errorMessage: mapAuthErrorToTurkish(e));
    }
  }

  Future<void> submitGoogle() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, errorMessage: mapAuthErrorToTurkish(e));
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      return null;
    } catch (e) {
      return mapAuthErrorToTurkish(e);
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}

/// Kayıt sırasında uygulanan şifre kuralı. Giriş (login) modunda kontrol
/// edilmez — eski/zayıf şifreyle açılmış hesaplar giriş yapabilmeye devam
/// etmeli, kural sadece yeni kayıtlara uygulanır.
String? validatePasswordStrength(String password) {
  if (password.length < 8) return 'Şifre en az 8 karakter olmalı.';
  if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Şifre en az bir büyük harf içermeli.';
  if (!RegExp(r'[a-z]').hasMatch(password)) return 'Şifre en az bir küçük harf içermeli.';
  if (!RegExp(r'[0-9]').hasMatch(password)) return 'Şifre en az bir rakam içermeli.';
  return null;
}
