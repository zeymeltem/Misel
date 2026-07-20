import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repository.dart';
import 'auth_provider.dart';

final accountNotifierProvider =
    NotifierProvider<AccountNotifier, void>(AccountNotifier.new);

class AccountNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  /// Hesabı ve tüm verisini siler. `requires-recent-login` hatası alırsa
  /// (Firebase hassas işlemler için yakın zamanda giriş şartı koşar) ilgili
  /// yeniden doğrulamayı [reauthenticate] ile tamamlayıp tekrar dener.
  Future<void> deleteAccount() async {
    final authRepo = ref.read(authRepositoryProvider);
    final uid = authRepo.currentUser?.uid;
    if (uid == null) return;

    await AccountRepository().deleteAllUserData(uid);
    await authRepo.deleteCurrentUser();
  }

  Future<void> reauthenticateWithPassword(String password) async {
    await ref.read(authRepositoryProvider).reauthenticateWithPassword(password);
  }

  Future<void> reauthenticateWithGoogle() async {
    await ref.read(authRepositoryProvider).reauthenticateWithGoogle();
  }

  bool get signedInWithGoogle => ref.read(authRepositoryProvider).signedInWithGoogle;
}

/// [FirebaseAuthException.code] 'requires-recent-login' mu diye bakmak için
/// küçük yardımcı — hesap silme akışında reauth diyaloğu açıp açmayacağımıza
/// karar vermek için kullanılır.
bool isRequiresRecentLogin(Object error) =>
    error is FirebaseAuthException && error.code == 'requires-recent-login';
