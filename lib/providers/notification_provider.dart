import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import 'economy_provider.dart';

final notificationInitProvider = FutureProvider<void>((ref) {
  return NotificationService.instance.init();
});

/// Kullanıcının ayarlar ekranında belirlediği günlük hatırlatma tercihini
/// dinler ve her değişiklikte bildirimi kurar/iptal eder. `_LoggedInApp`'te
/// `ref.watch` edilerek canlı tutulur — kendi başına bir arayüz üretmez.
final dailyReminderSyncProvider = Provider<void>((ref) {
  ref.listen(userStatsProvider, (previous, next) {
    final stats = next.value;
    if (stats == null) return;
    if (stats.dailyReminderEnabled) {
      NotificationService.instance.scheduleDailyReminder(
        hour: stats.dailyReminderHour,
        minute: stats.dailyReminderMinute,
      );
    } else {
      NotificationService.instance.cancelDailyReminder();
    }
  }, fireImmediately: true);
});
