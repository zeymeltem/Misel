import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/session.dart';

/// Sadece geliştirme/performans testi amaçlı: bahçe haritasını gerçekçi
/// (başarı/başarısız/iptal karışık) sahte seanslarla doldurur. Üretime
/// gitmez — [GardenCard]'daki debug-only butondan çağrılır. Firestore batch
/// limiti 500 olduğu için `count` bunu aşmamalı.
class FakeSessionService {
  static Future<void> generate(String uid, int count, {required String mushroomTypeId}) async {
    final random = Random();
    final now = DateTime.now();
    final sessionsRef =
        FirebaseFirestore.instance.collection('users').doc(uid).collection('sessions');
    final batch = FirebaseFirestore.instance.batch();

    for (var i = 0; i < count; i++) {
      final roll = random.nextDouble();
      final status = roll < 0.75
          ? SessionStatus.success
          : roll < 0.9
              ? SessionStatus.failed
              : SessionStatus.cancelled;
      final targetMinutes = 15 + random.nextInt(90);

      final session = Session(
        id: '',
        startTime: now.subtract(Duration(hours: (count - i) * 3)),
        targetMinutes: targetMinutes,
        actualMinutes: status == SessionStatus.success ? targetMinutes : random.nextInt(targetMinutes),
        status: status,
        tagId: null,
        mushroomTypeId: mushroomTypeId,
        coinsEarned: status == SessionStatus.success ? (targetMinutes * 0.3).round() : 0,
      );

      batch.set(sessionsRef.doc(), session.toMap());
    }

    await batch.commit();
  }
}
