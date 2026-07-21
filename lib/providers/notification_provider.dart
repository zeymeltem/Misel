import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_stats.dart';
import '../services/notification_service.dart';

final notificationInitProvider = FutureProvider<void>((ref) {
  return NotificationService.instance.init();
});

/// Kullanıcının ayarlar ekranında belirlediği günlük hatırlatma tercihine
/// göre bildirimi kurar/iptal eder. `_LoggedInApp`'in build'i içinde
/// `ref.listen(userStatsProvider, (_, next) => syncDailyReminder(next.value))`
/// ile çağrılır — bir provider'ın create fonksiyonu içine sarılıp
/// `ref.watch` edilirse Riverpod'un build-sırası zamanlamasıyla çakışıp
/// "setState() called during build" hatası verir, o yüzden düz fonksiyon.
void syncDailyReminder(UserStats? stats) {
  if (stats == null) return;
  if (stats.dailyReminderEnabled) {
    NotificationService.instance.scheduleDailyReminder(
      hour: stats.dailyReminderHour,
      minute: stats.dailyReminderMinute,
    );
  } else {
    NotificationService.instance.cancelDailyReminder();
  }
}
