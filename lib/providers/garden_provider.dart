import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mushroom_catalog.dart';
import '../services/dev/fake_session_service.dart';
import '../services/garden_layout_service.dart';
import 'auth_provider.dart';
import 'session_provider.dart';

/// Bahçe haritasındaki tüm yerleşmiş mantarlar (koordinat + sprite dahil);
/// sessions akışından saf fonksiyonla türetilir.
final gardenCellsProvider = Provider<List<GardenCell>>((ref) {
  final sessions = ref.watch(sessionsProvider).value ?? [];
  return layoutGarden(sessions);
});

/// Sadece geliştirme/performans testi için: haritayı sahte seanslarla
/// doldurur (bkz. [FakeSessionService]).
final gardenDevNotifierProvider =
    NotifierProvider<GardenDevNotifier, void>(GardenDevNotifier.new);

class GardenDevNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addFakeSessions(int count) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await FakeSessionService.generate(uid, count, mushroomTypeId: MushroomCatalog.starterId);
  }
}
