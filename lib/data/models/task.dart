import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final bool isRoutine;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.isRoutine,
    required this.createdAt,
  });

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] as String,
      isRoutine: data['isRoutine'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'isRoutine': isRoutine,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
