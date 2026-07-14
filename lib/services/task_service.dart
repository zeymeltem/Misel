import 'package:isar_plus/isar_plus.dart';

import '../models/task.dart';
import '../models/task_log.dart';

class TaskItem {
  final int id;
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

DateTime _todayKey() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class TaskService {
  /// Bugün listede görünecek görevler: rutinler her gün kalıcı, tek seferlik
  /// görevler tamamlanıp arşivlenene kadar görünür.
  static List<TaskItem> getTodayTasks(Isar isar) {
    final tasks = isar.tasks.where().archivedAtIsNull().findAll();
    final today = _todayKey();

    final items = tasks.map((task) {
      final log = isar.taskLogs
          .where()
          .taskIdEqualTo(task.id)
          .dateEqualTo(today)
          .findFirst();
      return TaskItem(
        id: task.id,
        title: task.title,
        isRoutine: task.isRoutine,
        completedToday: log?.wasCompleted ?? false,
      );
    }).toList();

    items.sort((a, b) {
      if (a.isRoutine != b.isRoutine) return a.isRoutine ? -1 : 1;
      return a.id.compareTo(b.id);
    });
    return items;
  }

  static void toggleToday(Isar isar, int taskId) {
    final task = isar.tasks.get(taskId);
    if (task == null) return;

    final today = _todayKey();
    final existingLog =
        isar.taskLogs.where().taskIdEqualTo(taskId).dateEqualTo(today).findFirst();
    final newCompleted = !(existingLog?.wasCompleted ?? false);

    isar.write((isar) {
      final log = existingLog ?? TaskLog();
      log
        ..date = today
        ..taskId = taskId
        ..wasCompleted = newCompleted;
      if (existingLog == null) {
        log.id = isar.taskLogs.autoIncrement();
      }
      isar.taskLogs.put(log);

      if (!task.isRoutine) {
        task.isDone = newCompleted;
        task.archivedAt = newCompleted ? DateTime.now() : null;
        isar.tasks.put(task);
      }
    });
  }

  static void addTask(Isar isar, String title, {required bool isRoutine}) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final task = Task()
      ..title = trimmed
      ..isRoutine = isRoutine
      ..isDone = false
      ..createdAt = DateTime.now()
      ..archivedAt = null;

    isar.write((isar) {
      task.id = isar.tasks.autoIncrement();
      isar.tasks.put(task);
    });
  }
}
