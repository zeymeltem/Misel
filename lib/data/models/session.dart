import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { success, failed, cancelled }

class Session {
  final String id;
  final DateTime startTime;
  final int targetMinutes;
  final int actualMinutes;
  final SessionStatus status;
  final String? tagId;
  final String mushroomTypeId;
  final int coinsEarned;

  const Session({
    required this.id,
    required this.startTime,
    required this.targetMinutes,
    required this.actualMinutes,
    required this.status,
    required this.tagId,
    required this.mushroomTypeId,
    required this.coinsEarned,
  });

  factory Session.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Session(
      id: doc.id,
      startTime: (data['startTime'] as Timestamp).toDate(),
      targetMinutes: data['targetMinutes'] as int,
      actualMinutes: data['actualMinutes'] as int,
      status: SessionStatus.values.byName(data['status'] as String),
      tagId: data['tagId'] as String?,
      mushroomTypeId: data['mushroomTypeId'] as String,
      coinsEarned: data['coinsEarned'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': Timestamp.fromDate(startTime),
      'targetMinutes': targetMinutes,
      'actualMinutes': actualMinutes,
      'status': status.name,
      'tagId': tagId,
      'mushroomTypeId': mushroomTypeId,
      'coinsEarned': coinsEarned,
    };
  }
}
