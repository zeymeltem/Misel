import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

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

  Future<void> submitEmail(String email, String password) async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (state.mode == AuthMode.login) {
        await repo.signInWithEmail(email, password);
      } else {
        await repo.registerWithEmail(email, password);
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
