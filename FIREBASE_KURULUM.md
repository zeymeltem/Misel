# Firebase Kurulum Rehberi

Uygulama Firebase olmadan açılmıyor (giriş zorunlu, veri Firestore'da).
Aşağıdaki adımlar bir kez yapılır; sonrasında herkes çalışan uygulamayı alır.

## 1. Firebase projesi oluştur

1. https://console.firebase.google.com → **Add project**.
2. Proje adı: `mantar-odak` (istediğin adı verebilirsin).
3. Google Analytics sorusuna **istersen hayır** de — bu proje kullanmıyor.

## 2. FlutterFire CLI ile yapılandır (önerilen yol)

`lib/firebase_options.dart` dosyasını elle doldurmak yerine CLI otomatik üretir:

```
# bir kez kurulum:
npm install -g firebase-tools        # veya: https://firebase.google.com/docs/cli
dart pub global activate flutterfire_cli

# proje kökünde:
firebase login
flutterfire configure
```

`flutterfire configure` sorularında:
- Firebase projesi olarak 1. adımda açtığını seç.
- Platform olarak **android** ve **web** (iOS build ortamın yoksa şart değil) seç.
- `lib/firebase_options.dart`'ın üzerine yazmasına izin ver (içindeki TODO
  placeholder'ların yerine gerçek anahtarlar gelir).
- Android için `android/app/google-services.json` dosyasını da indirir;
  bu dosya `.gitignore`'da, commit edilmez — herkes kendisi üretir.

## 3. Authentication'ı aç

Console → **Build → Authentication → Get started → Sign-in method**:

1. **Email/Password** → Enable.
2. **Google** → Enable (destek e-postası olarak kendi adresini seç).

### Google girişi için SHA-1 (sadece Android)

Google girişi Android'de uygulamanın imza parmak izini ister:

```
cd android
./gradlew signingReport
```

Çıktıdaki `Variant: debug` bölümünden **SHA1** değerini kopyala →
Console → Project settings (⚙) → senin Android uygulaman → **Add fingerprint**.
Sonra `google-services.json`'u yeniden indir (`flutterfire configure` tekrar
çalıştırmak da yeterli).

## 4. Firestore'u aç ve kuralları yayınla

1. Console → **Build → Firestore Database → Create database**.
2. Konum: `europe-west1` (ya da sana yakın bir bölge) — sonradan değişmez.
3. **Production mode** ile başlat (test mode herkese açık olur).
4. **Rules** sekmesi → proje kökündeki `firestore.rules` içeriğini yapıştır →
   **Publish**. (Kural: herkes yalnızca `users/{kendi uid}` altını okur/yazar.)

## 5. Doğrula

```
flutter run
```

- Uygulama hata ekranı yerine giriş ekranını açmalı.
- E-posta ile kayıt ol → ana ekran gelmeli.
- Console → Firestore → `users/{uid}` dokümanı oluşmuş olmalı.

## Sorun giderme

| Belirti | Sebep |
|---|---|
| Açılışta "Firebase yapılandırması eksik" ekranı | `flutterfire configure` çalıştırılmamış / `firebase_options.dart` hâlâ TODO |
| Google girişi `DEVELOPER_ERROR` / anında iptal | SHA-1 eklenmemiş veya `google-services.json` eski |
| Giriş oluyor ama veri gelmiyor / permission-denied | Firestore rules yayınlanmamış (adım 4) |
| Web'de Google girişi popup açılmıyor | Tarayıcı popup engelleyici; ya da Auth → Settings → Authorized domains'e domain eklenmemiş |
