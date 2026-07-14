import 'package:isar_plus/isar_plus.dart';

import '../models/mushroom_type.dart';

class SeedService {
  static MushroomType ensureStarterMushroom(Isar isar) {
    final existing = isar.mushroomTypes
        .where()
        .tierEqualTo(MushroomTier.starter)
        .findFirst();
    if (existing != null) return existing;

    final starter = MushroomType()
      ..name = 'Kültür mantarı'
      ..tier = MushroomTier.starter
      ..price = 0
      ..spriteAsset = 'assets/images/mushroom_starter.png'
      ..isOwned = true;

    isar.write((isar) {
      starter.id = isar.mushroomTypes.autoIncrement();
      isar.mushroomTypes.put(starter);
    });
    return starter;
  }

  /// Mağazada satılan mantar türlerini ilk açılışta bir kez oluşturur.
  static void ensureShopMushrooms(Isar isar) {
    ensureStarterMushroom(isar);

    const shopMushrooms = [
      (
        name: 'Orman mantarı',
        tier: MushroomTier.common,
        price: 450,
        sprite: 'assets/images/mushroom_common.png',
      ),
      (
        name: 'Pembe şapka',
        tier: MushroomTier.rare,
        price: 1200,
        sprite: 'assets/images/mushroom_rare.png',
      ),
      (
        name: 'Lacivert nadide',
        tier: MushroomTier.legendary,
        price: 3000,
        sprite: 'assets/images/mushroom_legendary.png',
      ),
    ];

    for (final m in shopMushrooms) {
      final existing =
          isar.mushroomTypes.where().tierEqualTo(m.tier).findFirst();
      if (existing != null) continue;

      final type = MushroomType()
        ..name = m.name
        ..tier = m.tier
        ..price = m.price
        ..spriteAsset = m.sprite
        ..isOwned = false;

      isar.write((isar) {
        type.id = isar.mushroomTypes.autoIncrement();
        isar.mushroomTypes.put(type);
      });
    }
  }
}
