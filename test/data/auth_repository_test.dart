import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mantar_odak/data/auth_repository.dart';

FirebaseAuthException _authError(String code) => FirebaseAuthException(code: code);

void main() {
  group('mapAuthErrorToTurkish', () {
    test('FirebaseAuthException olmayan hatalar için genel mesaj döner', () {
      expect(mapAuthErrorToTurkish(Exception('boom')), 'Bir şeyler ters gitti. Tekrar dene.');
    });

    test('wrong-password, invalid-credential ve user-not-found aynı mesajı verir', () {
      // Enumeration koruması: kayıtlı olmayan bir e-posta ile giriş
      // denemesi, yanlış şifre denemesinden ayırt edilemez olmalı.
      final wrongPassword = mapAuthErrorToTurkish(_authError('wrong-password'));
      final invalidCredential = mapAuthErrorToTurkish(_authError('invalid-credential'));
      final userNotFound = mapAuthErrorToTurkish(_authError('user-not-found'));

      expect(wrongPassword, 'E-posta veya şifre hatalı.');
      expect(invalidCredential, wrongPassword);
      expect(userNotFound, wrongPassword);
    });

    test('bilinen diğer kodlar kendi mesajını verir', () {
      expect(mapAuthErrorToTurkish(_authError('weak-password')),
          'Şifre çok zayıf. En az 6 karakter kullan.');
      expect(mapAuthErrorToTurkish(_authError('email-already-in-use')),
          'Bu e-posta zaten kayıtlı. Giriş yapmayı dene.');
    });

    test('bilinmeyen kod ham mesajı içeren fallback döner', () {
      final result = mapAuthErrorToTurkish(_authError('some-unmapped-code'));
      expect(result, contains('some-unmapped-code'));
    });
  });
}
