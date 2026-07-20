import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/session.dart';
import '../data/session_repository.dart';
import 'auth_provider.dart';

/// Tüm seanslar (bugün dahil, tüm zamanlar), başlangıç zamanına göre artan
/// sırada. Haftalık istatistik, toplam odak süresi ve bahçe haritası HEPSİ
/// bu tek akıştan türetilir.
final sessionsProvider = StreamProvider<List<Session>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return SessionRepository().watchSessions(uid);
});
