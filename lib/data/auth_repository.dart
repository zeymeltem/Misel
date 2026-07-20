import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Kimlik doğrulama işlemleri tek bu noktadan geçer. UI doğrudan
/// [FirebaseAuth]'a dokunmaz.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Web'de Firebase'in kendi popup akışı kullanılır (google_sign_in
  /// paketinin web SDK'sı özel butonla değil kendi render ettiği butonla
  /// çalışmayı zorunlu kılıyor). Mobilde google_sign_in v7 API'si kullanılır.
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final account = await googleSignIn.authenticate();
    final authorization = await account.authorizationClient.authorizationForScopes(['email']);
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
      accessToken: authorization?.accessToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
  }

  /// Hassas işlemler (hesap silme) öncesi Firebase'in istediği "yakın zamanda
  /// giriş yapılmış olma" şartını e-posta/şifre kullanıcıları için sağlar.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) return;
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (kIsWeb) {
      await user.reauthenticateWithPopup(GoogleAuthProvider());
      return;
    }
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final account = await googleSignIn.authenticate();
    final authorization = await account.authorizationClient.authorizationForScopes(['email']);
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
      accessToken: authorization?.accessToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }

  bool get signedInWithGoogle =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;
}

/// [FirebaseAuthException.code] değerini kullanıcı dostu Türkçe mesaja çevirir.
String mapAuthErrorToTurkish(Object error) {
  if (error is! FirebaseAuthException) return 'Bir şeyler ters gitti. Tekrar dene.';

  return switch (error.code) {
    'wrong-password' || 'invalid-credential' => 'E-posta veya şifre hatalı.',
    'user-not-found' => 'Bu e-posta ile kayıtlı bir kullanıcı bulunamadı.',
    'invalid-email' => 'Geçersiz e-posta adresi.',
    'weak-password' => 'Şifre çok zayıf. En az 6 karakter kullan.',
    'email-already-in-use' => 'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.',
    'too-many-requests' => 'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.',
    'network-request-failed' => 'İnternet bağlantısı yok. Bağlantını kontrol et.',
    'user-disabled' => 'Bu hesap devre dışı bırakılmış.',
    'requires-recent-login' => 'Bu işlem için tekrar giriş yapman gerekiyor.',
    'operation-not-allowed' => 'Bu giriş yöntemi şu anda kullanılamıyor.',
    'popup-closed-by-user' || 'canceled' => 'Giriş penceresi kapatıldı.',
    _ => 'Bir hata oluştu: ${error.message ?? error.code}',
  };
}
