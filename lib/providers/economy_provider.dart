import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

import '../models/mushroom_type.dart';
import '../models/session.dart';
import '../models/user_stats.dart';
import '../services/economy_service.dart';
import 'isar_provider.dart';

/// Kullanıcının coin bakiyesi vb. istatistikleri; ilgili kayıt her
/// değiştiğinde otomatik günceller.
final userStatsProvider = StreamProvider<UserStats>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield EconomyService.getUserStats(isar);
  await for (final stats in isar.userStats.watchObject(0)) {
    yield stats ?? UserStats();
  }
});

/// Mağazadaki mantar türleri; satın alma sonrası otomatik günceller.
final shopMushroomsProvider = StreamProvider<List<MushroomType>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield EconomyService.getShopMushrooms(isar);
  await for (final _ in isar.mushroomTypes.watchLazy()) {
    yield EconomyService.getShopMushrooms(isar);
  }
});

/// Kullanıcının sahip olduğu mantar türleri (seans için seçilebilir).
final ownedMushroomsProvider = StreamProvider<List<MushroomType>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield EconomyService.getOwnedMushrooms(isar);
  await for (final _ in isar.mushroomTypes.watchLazy()) {
    yield EconomyService.getOwnedMushrooms(isar);
  }
});

/// Bahçedeki parsel ilerlemesi; başarılı seans tamamlandıkça otomatik günceller.
final gardenProgressProvider = StreamProvider<GardenProgress>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield EconomyService.getGardenProgress(isar);
  await for (final _ in isar.sessions.watchLazy()) {
    yield EconomyService.getGardenProgress(isar);
  }
});

/// Mağazadan mantar satın alma eylemini yürütür.
final shopNotifierProvider =
    NotifierProvider<ShopNotifier, PurchaseResult?>(ShopNotifier.new);

class ShopNotifier extends Notifier<PurchaseResult?> {
  @override
  PurchaseResult? build() => null;

  Future<void> buy(int mushroomTypeId) async {
    final isar = await ref.read(isarProvider.future);
    state = EconomyService.buyMushroom(isar, mushroomTypeId);
  }
}

/// Başarılı seansların listesi; yeni başarılı seans eklendikçe güncellenir.
final successfulSessionsProvider = StreamProvider<List<Session>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield isar.sessions.where().findAll().where((s) => s.status == SessionStatus.success).toList();
  await for (final _ in isar.sessions.watchLazy()) {
    yield isar.sessions.where().findAll().where((s) => s.status == SessionStatus.success).toList();
  }
});

