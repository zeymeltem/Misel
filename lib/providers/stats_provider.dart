import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import '../services/stats_service.dart';
import 'auth_provider.dart';
import 'session_provider.dart';
import 'tag_provider.dart';
import 'task_provider.dart';

/// Haftalık odak/başarı/etiket/görev istatistikleri; sessions/tags/taskLogs
/// akışlarından saf fonksiyonla türetilir, elle invalidate gerekmez.
final weeklyStatsProvider = Provider<WeeklyStats>((ref) {
  final sessions = ref.watch(sessionsProvider).value ?? [];
  final tags = ref.watch(tagsProvider).value ?? [];
  final taskLogs = ref.watch(taskLogsProvider).value ?? [];
  return StatsService.getWeeklyStats(sessions, tags, taskLogs);
});

/// Tüm zamanların toplam odak süresi.
final totalFocusTimeProvider = Provider<Duration>((ref) {
  final sessions = ref.watch(sessionsProvider).value ?? [];
  return StatsService.getTotalFocusTime(sessions);
});

/// Geçmişte belirli bir günün toplam odak süresi (gün detayı ekranı için).
final focusMinutesForDateProvider = Provider.family<Duration, DateTime>((ref, date) {
  final sessions = ref.watch(sessionsProvider).value ?? [];
  return StatsService.getFocusMinutesForDate(sessions, date);
});

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, void>(ProfileNotifier.new);

class ProfileNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateProfile(String name, String username, int dailyGoalMinutes) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await UserRepository().updateProfile(
      uid,
      name: name,
      username: username,
      dailyGoalMinutes: dailyGoalMinutes,
    );
  }

  /// Fotoğraf ayrı bir yazım — seçilir seçilmez hemen kaydedilir, isim/kullanıcı
  /// adı/hedef için "Kaydet"e basılmasını beklemez.
  Future<void> updatePhoto(String photoBase64) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await UserRepository().updateProfilePhoto(uid, photoBase64);
  }
}
