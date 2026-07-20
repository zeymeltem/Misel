import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/session.dart';
import '../data/models/user_stats.dart';
import '../data/mushroom_catalog.dart';
import '../data/user_repository.dart';
import 'auth_provider.dart';
import 'session_provider.dart';

/// Bahçede yeni parsel açmak için gereken başarılı seans sayısı.
const int sessionsPerGardenPlot = 25;

class GardenProgress {
  final int unlockedPlots;
  final int sessionsUntilNextPlot;

  const GardenProgress({required this.unlockedPlots, required this.sessionsUntilNextPlot});
}

/// Kullanıcının coin bakiyesi vb. istatistikleri.
final userStatsProvider = StreamProvider<UserStats>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return UserRepository().watchUserStats(uid);
});

/// Mağazadaki mantar türleri — statik katalog, Firestore'a hiç gitmez.
final shopMushroomsProvider = Provider<List<MushroomCatalogItem>>((ref) => MushroomCatalog.all);

/// Kullanıcının sahip olduğu mantar türü ID'leri.
final ownedMushroomIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return UserRepository().watchOwnedMushroomIds(uid);
});

/// Kullanıcının sahip olduğu mantar türleri (seans için seçilebilir).
final ownedMushroomsProvider = Provider<List<MushroomCatalogItem>>((ref) {
  final ownedIds = ref.watch(ownedMushroomIdsProvider).value ?? const [];
  return MushroomCatalog.all.where((m) => ownedIds.contains(m.id)).toList();
});

/// Bahçedeki parsel ilerlemesi; sessions akışından türetilir.
final gardenProgressProvider = Provider<GardenProgress>((ref) {
  final sessions = ref.watch(sessionsProvider).value ?? const <Session>[];
  final successCount = sessions.where((s) => s.status == SessionStatus.success).length;
  final unlockedPlots = successCount ~/ sessionsPerGardenPlot;
  final intoCurrentPlot = successCount % sessionsPerGardenPlot;
  return GardenProgress(
    unlockedPlots: unlockedPlots,
    sessionsUntilNextPlot: sessionsPerGardenPlot - intoCurrentPlot,
  );
});

/// Ayarlar ekranındaki tercihleri yazar (bildirim aç/kapa, varsayılan süre).
final settingsNotifierProvider = NotifierProvider<SettingsNotifier, void>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateSettings({
    required bool notificationsEnabled,
    required int defaultSessionMinutes,
    required bool dailyReminderEnabled,
    required int dailyReminderHour,
    required int dailyReminderMinute,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await UserRepository().updateSettings(
      uid,
      notificationsEnabled: notificationsEnabled,
      defaultSessionMinutes: defaultSessionMinutes,
      dailyReminderEnabled: dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute,
    );
  }
}

/// İlk açılış tanıtım ekranını (bkz. OnboardingScreen) tekrar gösterilmeyecek
/// şekilde işaretler.
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, void>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> markSeen() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await UserRepository().markOnboardingSeen(uid);
  }
}

/// Mağazadan mantar satın alma eylemini yürütür.
final shopNotifierProvider =
    NotifierProvider<ShopNotifier, PurchaseResult?>(ShopNotifier.new);

class ShopNotifier extends Notifier<PurchaseResult?> {
  @override
  PurchaseResult? build() => null;

  Future<void> buy(String mushroomTypeId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    state = await UserRepository().buyMushroom(uid, mushroomTypeId);
  }
}
