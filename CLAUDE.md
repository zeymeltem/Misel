# Mimari kurallar

- Katmanlar: `data` (Isar şemaları, repository'ler) → `logic` (Riverpod provider'ları, servisler) → `ui` (ekranlar, widget'lar)
- UI katmanı ilerde tamamen değişecek. Widget'lar sadece provider'lardan veri okur, hiçbir iş mantığı içermez.
- Tüm renkler, fontlar, boyutlar tek bir theme dosyasında toplanır.
- Görseller `assets/images/` altında, sabit dosya adlarıyla referans edilir. Şimdilik placeholder kullan; gerçek pixel art sonra aynı adlarla eklenecek.
