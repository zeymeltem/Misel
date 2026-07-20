import 'package:cloud_firestore/cloud_firestore.dart';

class TaskLog {
  final String id;
  final DateTime date;
  final String taskId;
  final bool wasCompleted;

  const TaskLog({
    required this.id,
    required this.date,
    required this.taskId,
    required this.wasCompleted,
  });

  factory TaskLog.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskLog(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      taskId: data['taskId'] as String,
      wasCompleted: data['wasCompleted'] as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'taskId': taskId,
        'wasCompleted': wasCompleted,
      };
}
