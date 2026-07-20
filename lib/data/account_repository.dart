import 'package:cloud_firestore/cloud_firestore.dart';

/// Hesap silme: `users/{uid}` altındaki TÜM alt koleksiyonları (sessions,
/// tags, tasks, taskLogs, ownedMushrooms) ve doğrudan users/{uid} dokümanını
/// kalıcı olarak siler. Auth kaydının silinmesi [AuthRepository]'de.
class AccountRepository {
  final _db = FirebaseFirestore.instance;

  static const _subcollections = ['sessions', 'tags', 'tasks', 'taskLogs', 'ownedMushrooms'];

  Future<void> deleteAllUserData(String uid) async {
    final userDoc = _db.collection('users').doc(uid);

    for (final name in _subcollections) {
      await _deleteCollection(userDoc.collection(name));
    }

    await userDoc.delete();
  }

  /// Firestore batch limiti 500 — büyük koleksiyonlar parça parça silinir.
  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> collection) async {
    while (true) {
      final snapshot = await collection.limit(500).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < 500) return;
    }
  }
}
