import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _sessionEndNotificationId = 1;
  static const _dailyReminderNotificationId = 2;

  /// Bildirim izni reddedilse veya platform eklentisi kullanılamasa bile
  /// uygulamanın geri kalanı çalışmaya devam etmeli; bu yüzden hata yutulur.
  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _initialized = true;
    } catch (_) {
      // Bildirim olmadan da devam et.
    }
  }

  Future<void> scheduleSessionEnd(DateTime endTime) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.zonedSchedule(
      id: _sessionEndNotificationId,
      title: 'Mantar olgunlaştı',
      body: 'Odak seansın bitti, mantarını haritanda gör.',
      scheduledDate: tz.TZDateTime.from(endTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_end',
          'Seans bitişi',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelSessionEnd() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _sessionEndNotificationId);
  }

  /// Her gün [hour]:[minute]'de tekrar eden seri (streak) hatırlatması kurar.
  /// `matchDateTimeComponents: time` sayesinde tek kurulum yeterli — plugin
  /// kendisi her gün aynı saatte yeniden tetikler, gün gün elle kurmaya
  /// gerek yok. Aynı id ile tekrar çağrılması önceki kurulumun üzerine yazar.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    bool skipToday = false,
  }) async {
    if (kIsWeb || !_initialized) return;

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (skipToday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderNotificationId,
      title: 'Serini kaybetme!',
      body: 'Bugün henüz odaklanmadın. Kısa bir seansla mantarını büyütmeye devam et.',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Günlük hatırlatma',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _dailyReminderNotificationId);
  }
}
