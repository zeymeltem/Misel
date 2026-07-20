import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/user_repository.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/economy_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? firebaseError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Offline persistence: odak uygulaması internetsiz çalışmalı, bağlantı
    // gelince Firestore otomatik senkronlar. Başka bir Firestore çağrısından
    // önce, ilk iş olarak ayarlanmalı.
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  } catch (e) {
    // Firebase Console'da proje henüz kurulmamışsa (bkz. firebase_options.dart
    // içindeki TODO placeholder'lar) burada düşer — beyaz ekranda takılmak
    // yerine kullanıcıya ne yapması gerektiğini söylüyoruz.
    firebaseError = e.toString();
  }

  runApp(ProviderScope(child: MantarOdakApp(firebaseError: firebaseError)));
}

class MantarOdakApp extends ConsumerWidget {
  final String? firebaseError;
  const MantarOdakApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (firebaseError != null) {
      return MaterialApp(
        title: 'Mantar Odak',
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text(
                    'Firebase yapılandırması eksik veya hatalı.\n'
                    'lib/firebase_options.dart içindeki değerleri Firebase Console\'dan '
                    'aldığın gerçek proje bilgileriyle güncelle.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    firebaseError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.tabUnselectedText),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Mantar Odak',
      theme: buildAppTheme(),
      home: authState.when(
        data: (user) => user == null ? const AuthScreen() : const _LoggedInApp(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Hata: $error'))),
      ),
    );
  }
}

/// Giriş yapılmış kullanıcı için uygulama gövdesi. İlk girişte kullanıcı
/// dokümanı yoksa oluşturur, bildirimleri başlatır, sonra ana uygulamayı açar.
class _LoggedInApp extends ConsumerWidget {
  const _LoggedInApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value!;
    final notifications = ref.watch(notificationInitProvider);
    ref.watch(dailyReminderSyncProvider);

    return FutureBuilder<void>(
      future: UserRepository().ensureUserDocument(user.uid, displayName: user.displayName),
      builder: (context, ensureSnapshot) {
        if (ensureSnapshot.connectionState != ConnectionState.done || notifications.error != null) {
          if (notifications.error != null) {
            return Scaffold(body: Center(child: Text('Hata: ${notifications.error}')));
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!notifications.hasValue) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return const _OnboardingGate();
      },
    );
  }
}

/// `ensureUserDocument` bittikten sonra `hasSeenOnboarding`i kontrol eder.
/// Doküman az önce oluşturulmuş olabileceğinden akış burada ayrı tutulur —
/// `userStatsProvider`in stream'i henüz ilk değerini yaymamışsa varsayılan
/// (`false`) döner, bu da güvenli taraf: onboarding'i yanlışlıkla atlamaz.
class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    return stats.when(
      data: (value) => value.hasSeenOnboarding ? const RootShell() : const OnboardingScreen(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Hata: $error'))),
    );
  }
}
