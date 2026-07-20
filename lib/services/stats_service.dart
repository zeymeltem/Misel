import '../data/models/session.dart';
import '../data/models/tag.dart';
import '../data/models/task_log.dart';

class DailyFocus {
  final DateTime day;
  final int minutes;
  const DailyFocus({required this.day, required this.minutes});
}

class TagShare {
  final String tagName;
  final int colorIndex;
  final double percent;
  const TagShare({required this.tagName, required this.colorIndex, required this.percent});
}

class WeeklyStats {
  final Duration focusTime;
  final double successRatePercent;
  final double taskCompletionPercent;
  final int completedTaskCount;
  final int totalTaskCount;
  final List<DailyFocus> dailyFocus;
  final List<TagShare> tagShares;

  const WeeklyStats({
    required this.focusTime,
    required this.successRatePercent,
    required this.taskCompletionPercent,
    required this.completedTaskCount,
    required this.totalTaskCount,
    required this.dailyFocus,
    required this.tagShares,
  });
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Saf istatistik hesaplamaları — Firestore'a dokunmaz. Girdi listeleri
/// [SessionRepository]/[TagRepository]/[TaskRepository]'nin tek akışlarından
/// gelir (her ekran açılışında yeniden sorgu atılmaz).
class StatsService {
  /// Haftanın başlangıcı (Pazartesi, 00:00).
  static DateTime weekStart([DateTime? now]) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static WeeklyStats getWeeklyStats(
    List<Session> allSessions,
    List<Tag> allTags,
    List<TaskLog> allTaskLogs,
  ) {
    final start = weekStart();
    final sessions = allSessions.where((s) => !s.startTime.isBefore(start)).toList();
    final successSessions = sessions.where((s) => s.status == SessionStatus.success).toList();

    final totalCount = sessions.length;
    final successRate = totalCount == 0 ? 0.0 : successSessions.length / totalCount * 100;

    final focusMinutes = successSessions.fold<int>(0, (sum, s) => sum + s.actualMinutes);

    final dailyFocus = List.generate(7, (i) {
      final day = start.add(Duration(days: i));
      final minutes = successSessions
          .where((s) => _isSameDay(s.startTime, day))
          .fold<int>(0, (sum, s) => sum + s.actualMinutes);
      return DailyFocus(day: day, minutes: minutes);
    });

    final byTagMinutes = <String, int>{};
    for (final s in successSessions) {
      final tagId = s.tagId;
      if (tagId == null) continue;
      byTagMinutes[tagId] = (byTagMinutes[tagId] ?? 0) + s.actualMinutes;
    }
    final totalTaggedMinutes = byTagMinutes.values.fold<int>(0, (a, b) => a + b);

    final tagShares = <TagShare>[];
    if (totalTaggedMinutes > 0) {
      final tagsById = {for (final t in allTags) t.id: t};
      final sorted = byTagMinutes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sorted) {
        final tag = tagsById[entry.key];
        if (tag == null) continue;
        tagShares.add(TagShare(
          tagName: tag.name,
          colorIndex: tag.colorIndex,
          percent: entry.value / totalTaggedMinutes * 100,
        ));
      }
    }

    final logs = allTaskLogs.where((l) => !l.date.isBefore(start)).toList();
    final completedTaskCount = logs.where((l) => l.wasCompleted).length;
    final completionRate = logs.isEmpty ? 0.0 : completedTaskCount / logs.length * 100;

    return WeeklyStats(
      focusTime: Duration(minutes: focusMinutes),
      successRatePercent: successRate,
      taskCompletionPercent: completionRate,
      completedTaskCount: completedTaskCount,
      totalTaskCount: logs.length,
      dailyFocus: dailyFocus,
      tagShares: tagShares,
    );
  }

  /// Tüm zamanların toplam odak süresi (başarılı seanslar).
  static Duration getTotalFocusTime(List<Session> allSessions) {
    final minutes = allSessions
        .where((s) => s.status == SessionStatus.success)
        .fold<int>(0, (sum, s) => sum + s.actualMinutes);
    return Duration(minutes: minutes);
  }

  /// Belirli bir günün toplam odak süresi (başarılı seanslar). Görev geçmişi
  /// gün detayında kullanılır.
  static Duration getFocusMinutesForDate(List<Session> allSessions, DateTime date) {
    final minutes = allSessions
        .where((s) => s.status == SessionStatus.success && _isSameDay(s.startTime, date))
        .fold<int>(0, (sum, s) => sum + s.actualMinutes);
    return Duration(minutes: minutes);
  }
}
