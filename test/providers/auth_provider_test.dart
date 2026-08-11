import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:mantar_odak/data/auth_repository.dart';
import 'package:mantar_odak/providers/auth_provider.dart';

void main() {
  group('validatePasswordStrength', () {
    test('8 karakterden kısa şifreyi reddeder', () {
      expect(validatePasswordStrength('Ab1'), isNotNull);
    });

    test('büyük harf, küçük harf veya rakam eksikse reddeder', () {
      expect(validatePasswordStrength('abcdefgh'), isNotNull); // büyük harf yok
      expect(validatePasswordStrength('ABCDEFGH'), isNotNull); // küçük harf yok
      expect(validatePasswordStrength('Abcdefgh'), isNotNull); // rakam yok
    });

    test('kuralı sağlayan şifreyi kabul eder', () {
      expect(validatePasswordStrength('Abcdef12'), isNull);
    });
  });

  group('validateRegistrationFields', () {
    test('boş veya null ad reddedilir', () {
      expect(validateRegistrationFields('', 'kullanici'), isNotNull);
      expect(validateRegistrationFields('   ', 'kullanici'), isNotNull);
      expect(validateRegistrationFields(null, 'kullanici'), isNotNull);
    });

    test('boş veya null kullanıcı adı reddedilir', () {
      expect(validateRegistrationFields('Ad Soyad', ''), isNotNull);
      expect(validateRegistrationFields('Ad Soyad', '   '), isNotNull);
      expect(validateRegistrationFields('Ad Soyad', null), isNotNull);
    });

    test('her iki alan doluysa kabul eder', () {
      expect(validateRegistrationFields('Ad Soyad', 'kullanici'), isNull);
    });
  });

  group('AuthFormNotifier.sendPasswordReset', () {
    test('user-not-found hatasını gizleyip null döner (enumeration koruması)', () async {
      final mockAuth = MockFirebaseAuth();
      whenCalling(Invocation.method(#sendPasswordResetEmail, null))
          .on(mockAuth)
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(auth: mockAuth)),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(authFormNotifierProvider.notifier).sendPasswordReset('yok@yok.com');

      expect(result, isNull);
    });

    test('başka bir hata kodunda mesajı olduğu gibi döner', () async {
      final mockAuth = MockFirebaseAuth();
      whenCalling(Invocation.method(#sendPasswordResetEmail, null))
          .on(mockAuth)
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(auth: mockAuth)),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(authFormNotifierProvider.notifier)
          .sendPasswordReset('birisi@ornek.com');

      expect(result, 'İnternet bağlantısı yok. Bağlantını kontrol et.');
    });
  });
}
