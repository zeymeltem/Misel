import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/user_stats.dart';
import 'mushroom_catalog.dart';

/// `users/{uid}` dokümanı ve `ownedMushrooms` alt koleksiyonu için tek geçiş
/// noktası. UI hiçbir zaman Firestore'a doğrudan dokunmaz.
class UserRepository {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _ownedMushrooms(String uid) =>
      _userDoc(uid).collection('ownedMushrooms');

  Stream<UserStats> watchUserStats(String uid) {
    return _userDoc(uid).snapshots().map(UserStats.fromFirestore);
  }

  Stream<List<String>> watchOwnedMushroomIds(String uid) {
    return _ownedMushrooms(uid).snapshots().map((s) => s.docs.map((d) => d.id).toList());
  }

  /// İlk girişte/kayıtta çağrılır: kullanıcı dokümanı yoksa oluşturur ve
  /// başlangıç mantarını sahiplendirir.
  Future<void> ensureUserDocument(String uid, {String? displayName}) async {
    final doc = await _userDoc(uid).get();
    if (doc.exists) return;

    await _userDoc(uid).set(UserStats(displayName: displayName).toMap());
    await _ownedMushrooms(uid).doc(MushroomCatalog.starterId).set({'ownedAt': Timestamp.now()});
  }

  Future<void> updateProfile(
    String uid, {
    required String name,
    required String username,
    required int dailyGoalMinutes,
  }) async {
    await _userDoc(uid).set({
      'displayName': name.trim(),
      'username': username.trim(),
      'dailyGoalMinutes': dailyGoalMinutes,
    }, SetOptions(merge: true));
  }

  /// Başarılı seans sonrası coin ekler ve günlük seriyi günceller — tek
  /// yazımda (bkz. proje kuralı: sık güncellenen alanları tek yazımda topla).
  /// Aynı gün içindeki ikinci başarı seriyi artırmaz; bir gün atlanırsa seri
  /// sıfırlanır.
  Future<void> recordSuccessfulSession(String uid, {required int coins}) async {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc(uid));
      final stats = UserStats.fromFirestore(snap);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final last = stats.lastSuccessDate;

      int newStreak;
      if (last == null) {
        newStreak = 1;
      } else {
        final lastDay = DateTime(last.year, last.month, last.day);
        final dayGap = today.difference(lastDay).inDays;
        if (dayGap == 1) {
          newStreak = stats.currentStreak + 1;
        } else if (dayGap > 1) {
          newStreak = 1;
        } else {
          newStreak = stats.currentStreak; // dayGap == 0: bugün zaten sayıldı.
        }
      }

      tx.set(
        _userDoc(uid),
        {
          'totalCoins': stats.totalCoins + coins,
          'currentStreak': newStreak,
          'longestStreak': newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
          'lastSuccessDate': Timestamp.fromDate(today),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> updateSettings(
    String uid, {
    required bool notificationsEnabled,
    required int defaultSessionMinutes,
    required bool dailyReminderEnabled,
    required int dailyReminderHour,
    required int dailyReminderMinute,
  }) async {
    await _userDoc(uid).set({
      'notificationsEnabled': notificationsEnabled,
      'defaultSessionMinutes': defaultSessionMinutes,
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderHour': dailyReminderHour,
      'dailyReminderMinute': dailyReminderMinute,
    }, SetOptions(merge: true));
  }

  Future<void> markOnboardingSeen(String uid) async {
    await _userDoc(uid).set({'hasSeenOnboarding': true}, SetOptions(merge: true));
  }

  Future<void> setSelectedMushroomType(String uid, String mushroomTypeId) async {
    await _userDoc(uid).set({'selectedMushroomTypeId': mushroomTypeId}, SetOptions(merge: true));
  }

  /// Mağazadan mantar satın alma: coin düşümü + sahiplik işaretlemesi tek
  /// transaction'da (yarış koşuluna karşı).
  Future<PurchaseResult> buyMushroom(String uid, String mushroomTypeId) async {
    final catalogItem = MushroomCatalog.byId(mushroomTypeId);
    if (catalogItem == null) return PurchaseResult.notFound;

    final ownedDoc = _ownedMushrooms(uid).doc(mushroomTypeId);
    return _db.runTransaction((tx) async {
      final ownedSnap = await tx.get(ownedDoc);
      if (ownedSnap.exists) return PurchaseResult.alreadyOwned;

      final userSnap = await tx.get(_userDoc(uid));
      final stats = UserStats.fromFirestore(userSnap);
      if (stats.totalCoins < catalogItem.price) return PurchaseResult.insufficientCoins;

      tx.set(_userDoc(uid), {'totalCoins': stats.totalCoins - catalogItem.price},
          SetOptions(merge: true));
      tx.set(ownedDoc, {'ownedAt': Timestamp.now()});
      return PurchaseResult.success;
    });
  }
}

enum PurchaseResult { success, alreadyOwned, insufficientCoins, notFound }
