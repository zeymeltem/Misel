import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../models/task_log.dart';
import '../services/task_service.dart';
import 'isar_provider.dart';

/// Bugünün görev listesi; görev eklenip tamamlandıkça otomatik günceller.
/// Task ve TaskLog koleksiyonlarından biri değişince yeniden hesaplanır.
final todayTasksProvider = StreamProvider<List<TaskItem>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield TaskService.getTodayTasks(isar);

  final changes = StreamController<void>();
  final subs = [
    isar.tasks.watchLazy().listen(changes.add),
    isar.taskLogs.watchLazy().listen(changes.add),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    changes.close();
  });

  await for (final _ in changes.stream) {
    yield TaskService.getTodayTasks(isar);
  }
});

final taskNotifierProvider = NotifierProvider<TaskNotifier, void>(TaskNotifier.new);

class TaskNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(int taskId) async {
    final isar = await ref.read(isarProvider.future);
    TaskService.toggleToday(isar, taskId);
  }

  Future<void> add(String title, {required bool isRoutine}) async {
    final isar = await ref.read(isarProvider.future);
    TaskService.addTask(isar, title, isRoutine: isRoutine);
  }
}
