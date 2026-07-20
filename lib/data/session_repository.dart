import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/session.dart';

class SessionRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _db.collection('users').doc(uid).collection('sessions');

  /// Tüm seanslar, başlangıç zamanına göre artan sırada. Haftalık istatistik,
  /// toplam süre ve bahçe haritası HEPSİ bu tek akıştan türetilir — ayrı ayrı
  /// sorgu yapıp okuma maliyetini artırmamak için.
  Stream<List<Session>> watchSessions(String uid) {
    return _sessions(uid).orderBy('startTime').snapshots().map(
          (snap) => snap.docs.map(Session.fromFirestore).toList(),
        );
  }

  Future<void> addSession(String uid, Session session) async {
    await _sessions(uid).add(session.toMap());
  }

  /// Çalışan seansın kalıcı izi. Uygulama seans ortasında kapanırsa (OS
  /// öldürür, kullanıcı görevden atar) bir sonraki açılışta bu doküman
  /// bulunur ve seans başarısız olarak tarihe işlenir.
  DocumentReference<Map<String, dynamic>> _activeSessionDoc(String uid) =>
      _db.collection('users').doc(uid).collection('state').doc('activeSession');

  Future<void> setActiveSession(String uid, Session session) async {
    await _activeSessionDoc(uid).set(session.toMap());
  }

  Future<Session?> getActiveSession(String uid) async {
    final doc = await _activeSessionDoc(uid).get();
    if (!doc.exists) return null;
    return Session.fromFirestore(doc);
  }

  Future<void> clearActiveSession(String uid) async {
    await _activeSessionDoc(uid).delete();
  }
}
