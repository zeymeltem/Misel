# Mimari kurallar

- Katmanlar: `data` (Firestore modelleri, repository'ler) → `logic` (Riverpod provider'ları, servisler) → `ui` (ekranlar, widget'lar)
- Veri tamamen Firestore'da (`users/{uid}/...`), Isar yok. UI hiçbir zaman Firestore'a doğrudan dokunmaz, hep `lib/data/`'daki repository'lerden geçer. Giriş zorunlu (bkz. `lib/providers/auth_provider.dart`).
- UI katmanı ilerde tamamen değişecek. Widget'lar sadece provider'lardan veri okur, hiçbir iş mantığı içermez.
- Tüm renkler, fontlar, boyutlar tek bir theme dosyasında toplanır.
- Görseller `assets/images/` altında, sabit dosya adlarıyla referans edilir. Şimdilik placeholder kullan; gerçek pixel art sonra aynı adlarla eklenecek.
