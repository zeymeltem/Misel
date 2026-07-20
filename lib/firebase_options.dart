// GEÇİCİ PLACEHOLDER — gerçek Firebase Console değerleriyle değiştirilecek.
//
// Bu dosya normalde `flutterfire configure` ile otomatik üretilir. CLI bu
// makinede kurulu/giriş yapılmış olmadığı için elle yazıldı. Firebase Console'da
// proje kurulup Web app + Android app eklendiğinde, oradan alınan gerçek
// değerlerle aşağıdaki `web`/`android` bloklarını güncelle.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS için firebase_options henüz eklenmedi.');
      default:
        throw UnsupportedError(
          '${defaultTargetPlatform.name} platformu Firebase tarafından desteklenmiyor '
          '(bkz. CLAUDE.md / plan: Windows masaüstü resmi olarak desteklenmiyor).',
        );
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDczlVSn42zFtxT6IMuPZN4GQQ0-YNKZUg',
    appId: '1:98647374254:web:3c06bb713d229943c5b03f',
    messagingSenderId: '98647374254',
    projectId: 'misel-25ca6',
    authDomain: 'misel-25ca6.firebaseapp.com',
    storageBucket: 'misel-25ca6.firebasestorage.app',
    measurementId: 'G-Z98LDZ4DLG',
  );

  // TODO: Firebase Console → Project settings → Android app'ten (google-services.json) gerçek değerlerle değiştir.
  static const android = FirebaseOptions(
    apiKey: 'TODO-apiKey',
    appId: 'TODO-appId',
    messagingSenderId: 'TODO-messagingSenderId',
    projectId: 'TODO-projectId',
    storageBucket: 'TODO-projectId.appspot.com',
  );
}
