/// Mağazadaki mantar türlerinin sabit kataloğu. Statik uygulama verisi —
/// kullanıcıya özgü değil, Firestore'da saklanmaz. Kullanıcının hangi
/// katalog ID'lerine sahip olduğu `users/{uid}/ownedMushrooms` alt
/// koleksiyonunda işaretlenir.
enum MushroomTier { starter, common, rare, legendary }

class MushroomCatalogItem {
  final String id;
  final String name;
  final MushroomTier tier;
  final int price;
  final String spriteAsset;

  const MushroomCatalogItem({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    required this.spriteAsset,
  });
}

abstract final class MushroomCatalog {
  static const String starterId = 'starter';

  static const List<MushroomCatalogItem> all = [
    MushroomCatalogItem(
      id: starterId,
      name: 'Kültür mantarı',
      tier: MushroomTier.starter,
      price: 0,
      spriteAsset: 'assets/images/mushroom_starter.png',
    ),
    MushroomCatalogItem(
      id: 'common',
      name: 'Orman mantarı',
      tier: MushroomTier.common,
      price: 450,
      spriteAsset: 'assets/images/mushroom_common.png',
    ),
    MushroomCatalogItem(
      id: 'rare',
      name: 'Pembe şapka',
      tier: MushroomTier.rare,
      price: 1200,
      spriteAsset: 'assets/images/mushroom_rare.png',
    ),
    MushroomCatalogItem(
      id: 'legendary',
      name: 'Lacivert nadide',
      tier: MushroomTier.legendary,
      price: 3000,
      spriteAsset: 'assets/images/mushroom_legendary.png',
    ),
  ];

  static MushroomCatalogItem? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
