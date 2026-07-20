import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/task.dart';
import 'models/task_log.dart';

DateTime _todayKey() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

class TaskRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _db.collection('users').doc(uid).collection('tasks');

  CollectionReference<Map<String, dynamic>> _taskLogs(String uid) =>
      _db.collection('users').doc(uid).collection('taskLogs');

  Stream<List<Task>> watchTasks(String uid) {
    return _tasks(uid).snapshots().map((s) => s.docs.map(Task.fromFirestore).toList());
  }

  /// Tüm tamamlanma kayıtları — günlük/haftalık/aylık geçmiş bu tek akıştan
  /// bellekte hesaplanır (bkz. [TaskService]), her ekran açılışında ayrı
  /// sorgu atılmaz.
  Stream<List<TaskLog>> watchTaskLogs(String uid) {
    return _taskLogs(uid).snapshots().map((s) => s.docs.map(TaskLog.fromFirestore).toList());
  }

  Future<void> addTask(String uid, String title, {required bool isRoutine}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _tasks(uid).add({
      'title': trimmed,
      'isRoutine': isRoutine,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> editTask(String uid, String taskId, {required String title, required bool isRoutine}) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _tasks(uid).doc(taskId).update({'title': trimmed, 'isRoutine': isRoutine});
  }

  /// Görevi ve o göreve ait tüm tamamlanma kayıtlarını kalıcı olarak siler.
  Future<void> deleteTask(String uid, String taskId) async {
    final logs = await _taskLogs(uid).where('taskId', isEqualTo: taskId).get();
    final batch = _db.batch();
    for (final doc in logs.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_tasks(uid).doc(taskId));
    await batch.commit();
  }

  Future<void> toggleToday(String uid, String taskId) async {
    final today = _todayKey();
    final existing = await _taskLogs(uid)
        .where('taskId', isEqualTo: taskId)
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .limit(1)
        .get();

    final wasCompleted = existing.docs.isEmpty ? false : existing.docs.first.data()['wasCompleted'] as bool;
    final data = {
      'taskId': taskId,
      'date': Timestamp.fromDate(today),
      'wasCompleted': !wasCompleted,
    };

    if (existing.docs.isEmpty) {
      await _taskLogs(uid).add(data);
    } else {
      await existing.docs.first.reference.update(data);
    }
  }
}
