import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task.dart';
import '../data/models/task_log.dart';
import '../data/task_repository.dart';
import '../services/task_service.dart';
import 'auth_provider.dart';

/// Ham görev listesi (Firestore akışı).
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return TaskRepository().watchTasks(uid);
});

/// Ham tamamlanma kayıtları (Firestore akışı) — günlük/haftalık/aylık geçmiş
/// bundan bellekte hesaplanır, ayrı sorgu atılmaz.
final taskLogsProvider = StreamProvider<List<TaskLog>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return TaskRepository().watchTaskLogs(uid);
});

/// Bugünün görev listesi; `tasksProvider`/`taskLogsProvider` akışlarından
/// saf fonksiyonla türetilir.
final todayTasksProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final logs = ref.watch(taskLogsProvider).value ?? [];
  return TaskService.getTodayTasks(tasks, logs);
});

/// Bugün dahil, günlük görev tamamlanma özeti (Görev Geçmişi ekranının
/// "Günlük" sekmesi).
final dailyTaskHistoryProvider = Provider<List<DayTaskSummary>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final logs = ref.watch(taskLogsProvider).value ?? [];
  return TaskService.getTaskHistory(tasks, logs);
});

/// Haftalık görev tamamlanma özeti ("Haftalık" sekmesi).
final weeklyTaskHistoryProvider = Provider<List<WeekTaskSummary>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final logs = ref.watch(taskLogsProvider).value ?? [];
  return TaskService.getWeeklyTaskHistory(tasks, logs);
});

/// Aylık görev tamamlanma özeti ("Aylık" sekmesi).
final monthlyTaskHistoryProvider = Provider<List<MonthTaskSummary>>((ref) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final logs = ref.watch(taskLogsProvider).value ?? [];
  return TaskService.getMonthlyTaskHistory(tasks, logs);
});

/// Geçmişte belirli bir günün görev listesi (gün detayı ekranı için).
final taskHistoryDetailProvider = Provider.family<List<TaskItem>, DateTime>((ref, date) {
  final tasks = ref.watch(tasksProvider).value ?? [];
  final logs = ref.watch(taskLogsProvider).value ?? [];
  return TaskService.getTasksForDate(tasks, logs, date);
});

final taskNotifierProvider = NotifierProvider<TaskNotifier, void>(TaskNotifier.new);

class TaskNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(String taskId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await TaskRepository().toggleToday(uid, taskId);
  }

  Future<void> add(String title, {required bool isRoutine}) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await TaskRepository().addTask(uid, title, isRoutine: isRoutine);
  }

  Future<void> edit(String taskId, String title, {required bool isRoutine}) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await TaskRepository().editTask(uid, taskId, title: title, isRoutine: isRoutine);
  }

  Future<void> delete(String taskId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await TaskRepository().deleteTask(uid, taskId);
  }
}
