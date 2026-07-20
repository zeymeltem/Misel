import '../data/models/task.dart';
import '../data/models/task_log.dart';

class TaskItem {
  final String id;
  final String title;
  final bool isRoutine;
  final bool completedToday;

  const TaskItem({
    required this.id,
    required this.title,
    required this.isRoutine,
    required this.completedToday,
  });
}

/// Geçmiş bir günün özeti: o gün listede olan görev sayısı ve kaçının
/// tamamlandığı.
class DayTaskSummary {
  final DateTime date;
  final int completedCount;
  final int totalCount;

  const DayTaskSummary({
    required this.date,
    required this.completedCount,
    required this.totalCount,
  });

  double get completionPercent =>
      totalCount == 0 ? 0.0 : completedCount / totalCount * 100;
}

/// Bir haftanın (Pazartesi başlangıçlı) özeti.
class WeekTaskSummary {
  final DateTime weekStart;
  final int weeksAgo;
  final int completedCount;
  final int totalCount;

  const WeekTaskSummary({
    required this.weekStart,
    required this.weeksAgo,
    required this.completedCount,
    required this.totalCount,
  });

  double get completionPercent =>
      totalCount == 0 ? 0.0 : completedCount / totalCount * 100;
}

/// Bir takvim ayının özeti.
class MonthTaskSummary {
  final int year;
  final int month;
  final int completedCount;
  final int totalCount;

  const MonthTaskSummary({
    required this.year,
    required this.month,
    required this.completedCount,
    required this.totalCount,
  });

  double get completionPercent =>
      totalCount == 0 ? 0.0 : completedCount / totalCount * 100;
}

DateTime _todayKey() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _mondayOf(DateTime day) => day.subtract(Duration(days: day.weekday - 1));

class _DayTally {
  final int completed;
  final int total;
  const _DayTally(this.completed, this.total);
}

/// Görev geçmişi/bugünkü liste hesaplamaları — saf fonksiyonlar, Firestore'a
/// dokunmaz. [TaskRepository]'den gelen tüm task+taskLog listeleri üzerinde
/// bellekte çalışır (her ekran açılışında yeniden sorgu atılmaz).
class TaskService {
  static List<TaskItem> getTodayTasks(List<Task> allTasks, List<TaskLog> allLogs) {
    return _tasksForDay(allTasks, allLogs, _todayKey());
  }

  static List<TaskItem> _tasksForDay(List<Task> allTasks, List<TaskLog> allLogs, DateTime day) {
    final tasks = _tasksActiveOn(allTasks, day);
    return tasks.map((task) {
      final log = allLogs
          .where((l) => l.taskId == task.id && _isSameDay(l.date, day))
          .firstOrNull;
      return TaskItem(
        id: task.id,
        title: task.title,
        isRoutine: task.isRoutine,
        completedToday: log?.wasCompleted ?? false,
      );
    }).toList()
      ..sort((a, b) {
        if (a.isRoutine != b.isRoutine) return a.isRoutine ? -1 : 1;
        return a.id.compareTo(b.id);
      });
  }

  static List<Task> _tasksActiveOn(List<Task> allTasks, DateTime day) {
    return allTasks
        .where((t) => t.isRoutine ? !_dateOnly(t.createdAt).isAfter(day) : _isSameDay(t.createdAt, day))
        .toList();
  }

  /// Belirli bir geçmiş günde listede olan görevler ve o günkü tamamlanma
  /// durumları.
  static List<TaskItem> getTasksForDate(List<Task> allTasks, List<TaskLog> allLogs, DateTime date) {
    return _tasksForDay(allTasks, allLogs, DateTime(date.year, date.month, date.day));
  }

  static DateTime? _earliestTaskDate(List<Task> tasks) {
    if (tasks.isEmpty) return null;
    return tasks.map((t) => _dateOnly(t.createdAt)).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static Map<String, bool> _logIndex(List<TaskLog> logs) => {
        for (final l in logs) '${l.taskId}|${_dateOnly(l.date).toIso8601String()}': l.wasCompleted,
      };

  /// Bugünden geriye, tüm günlerin (görev listesi boş olmayan) tamamlanma
  /// özeti. En yeni gün ("Bugün") ilk sırada.
  static List<DayTaskSummary> getTaskHistory(List<Task> allTasks, List<TaskLog> allLogs) {
    final earliest = _earliestTaskDate(allTasks);
    if (earliest == null) return [];

    final logIndex = _logIndex(allLogs);
    final today = _todayKey();
    final summaries = <DayTaskSummary>[];
    for (var day = today; !day.isBefore(earliest); day = day.subtract(const Duration(days: 1))) {
      final tally = _tally(allTasks, logIndex, day);
      if (tally.total == 0) continue;
      summaries.add(DayTaskSummary(date: day, completedCount: tally.completed, totalCount: tally.total));
    }
    return summaries;
  }

  /// Bu haftadan geriye, görev bulunan tüm haftaların özeti.
  static List<WeekTaskSummary> getWeeklyTaskHistory(List<Task> allTasks, List<TaskLog> allLogs) {
    final earliest = _earliestTaskDate(allTasks);
    if (earliest == null) return [];

    final logIndex = _logIndex(allLogs);
    final today = _todayKey();
    final currentWeekStart = _mondayOf(today);
    final earliestWeekStart = _mondayOf(earliest);

    final summaries = <WeekTaskSummary>[];
    var weeksAgo = 0;
    for (var weekStart = currentWeekStart;
        !weekStart.isBefore(earliestWeekStart);
        weekStart = weekStart.subtract(const Duration(days: 7)), weeksAgo++) {
      var completed = 0;
      var total = 0;
      for (var i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        if (day.isAfter(today)) break;
        final tally = _tally(allTasks, logIndex, day);
        completed += tally.completed;
        total += tally.total;
      }
      if (total == 0) continue;
      summaries.add(WeekTaskSummary(
        weekStart: weekStart,
        weeksAgo: weeksAgo,
        completedCount: completed,
        totalCount: total,
      ));
    }
    return summaries;
  }

  /// Bu aydan geriye, görev bulunan tüm ayların özeti.
  static List<MonthTaskSummary> getMonthlyTaskHistory(List<Task> allTasks, List<TaskLog> allLogs) {
    final earliest = _earliestTaskDate(allTasks);
    if (earliest == null) return [];

    final logIndex = _logIndex(allLogs);
    final today = _todayKey();
    final summaries = <MonthTaskSummary>[];
    var cursor = DateTime(today.year, today.month, 1);
    final earliestMonth = DateTime(earliest.year, earliest.month, 1);
    while (!cursor.isBefore(earliestMonth)) {
      var completed = 0;
      var total = 0;
      final daysInMonth = DateTime(cursor.year, cursor.month + 1, 0).day;
      for (var d = 1; d <= daysInMonth; d++) {
        final day = DateTime(cursor.year, cursor.month, d);
        if (day.isAfter(today)) break;
        final tally = _tally(allTasks, logIndex, day);
        completed += tally.completed;
        total += tally.total;
      }
      if (total > 0) {
        summaries.add(MonthTaskSummary(
          year: cursor.year,
          month: cursor.month,
          completedCount: completed,
          totalCount: total,
        ));
      }
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }
    return summaries;
  }

  static _DayTally _tally(List<Task> allTasks, Map<String, bool> logIndex, DateTime day) {
    final tasks = _tasksActiveOn(allTasks, day);
    if (tasks.isEmpty) return const _DayTally(0, 0);
    var completed = 0;
    for (final t in tasks) {
      final done = logIndex['${t.id}|${day.toIso8601String()}'] ?? false;
      if (done) completed++;
    }
    return _DayTally(completed, tasks.length);
  }
}
