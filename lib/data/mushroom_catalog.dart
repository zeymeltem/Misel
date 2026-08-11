/// Mağazadaki mantar türlerinin sabit kataloğu. Statik uygulama verisi —
/// kullanıcıya özgü değil, Firestore'da saklanmaz. Kullanıcının hangi
/// katalog ID'lerine sahip olduğu `users/{uid}/ownedMushrooms` alt
/// koleksiyonunda işaretlenir.
enum MushroomTier { starter, common, rare, legendary }

/// Her mantar türü için tam olarak 4 görsel dosyası olur, hepsi aynı sabit
/// desende: `assets/images/mushroom_<id>_<evre>.png`. Dosya adı tek başına
/// hangi evrede/nerede kullanıldığını söyler:
///
/// - `_kucuk`  → büyüme halkasının 1. evresi (spor)
/// - `_orta`   → büyüme halkasının 2. evresi (filiz)
/// - `_olgun`  → tam boy: büyüme halkasının son evresi + mağaza ikonu
/// - `_harita` → bahçe haritasında gösterilen, altı toprağa gömülü hali
///
/// Katalogda dosya yolu elle yazılmaz; hepsi [id]'den türetilir — yeni bir
/// mantar eklerken tek yapılacak iş bu 4 dosyayı doğru adla eklemek.
class MushroomCatalogItem {
  final String id;
  final String name;
  final MushroomTier tier;
  final int price;

  const MushroomCatalogItem({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
  });

  String get kucukSprite => 'assets/images/mushroom_${id}_kucuk.png';
  String get ortaSprite => 'assets/images/mushroom_${id}_orta.png';
  String get spriteAsset => 'assets/images/mushroom_${id}_olgun.png';
  String get mapSpriteAsset => 'assets/images/mushroom_${id}_harita.png';

  /// Seans sırasında büyüme halkasında gösterilen 3 evre: [küçük, orta, olgun].
  List<String> get growthSprites => [kucukSprite, ortaSprite, spriteAsset];
}

abstract final class MushroomCatalog {
  static const String starterId = 'starter';

  static const List<MushroomCatalogItem> all = [
    MushroomCatalogItem(
      id: starterId,
      name: 'Kültür mantarı',
      tier: MushroomTier.starter,
      price: 0,
    ),
    MushroomCatalogItem(
      id: 'common',
      name: 'Orman mantarı',
      tier: MushroomTier.common,
      price: 450,
    ),
    MushroomCatalogItem(
      id: 'rare',
      name: 'Pembe şapka',
      tier: MushroomTier.rare,
      price: 1200,
    ),
    MushroomCatalogItem(
      id: 'legendary',
      name: 'Lacivert nadide',
      tier: MushroomTier.legendary,
      price: 3000,
    ),
  ];

  static MushroomCatalogItem? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
