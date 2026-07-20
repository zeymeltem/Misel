// `flutterfire configure` ile misel-25ca6 Firebase projesinden otomatik
// üretildi. Elle düzenleme gerekirse `flutterfire configure` tekrar
// çalıştırılıp üzerine yazdırılabilir.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          '${defaultTargetPlatform.name} platformu için Firebase yapılandırması '
          'henüz eklenmedi. `flutterfire configure` ile ekleyebilirsin.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDczlVSn42zFtxT6IMuPZN4GQQ0-YNKZUg',
    appId: '1:98647374254:web:3c06bb713d229943c5b03f',
    messagingSenderId: '98647374254',
    projectId: 'misel-25ca6',
    authDomain: 'misel-25ca6.firebaseapp.com',
    storageBucket: 'misel-25ca6.firebasestorage.app',
    measurementId: 'G-Z98LDZ4DLG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1XZTt8ohLlIRcDYsB4NgBqs_w7bwGKBg',
    appId: '1:98647374254:android:afd813fb2c317497c5b03f',
    messagingSenderId: '98647374254',
    projectId: 'misel-25ca6',
    storageBucket: 'misel-25ca6.firebasestorage.app',
  );
}
