import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/tag.dart';

class TagRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tags(String uid) =>
      _db.collection('users').doc(uid).collection('tags');

  Stream<List<Tag>> watchTags(String uid) {
    return _tags(uid).snapshots().map((s) {
      final tags = s.docs.map(Tag.fromFirestore).toList();
      tags.sort((a, b) => a.name.compareTo(b.name));
      return tags;
    });
  }

  Future<Tag> createIfAbsent(String uid, String name, {required int currentTagCount}) async {
    final trimmed = name.trim();
    final existing = await _tags(uid).where('name', isEqualTo: trimmed).limit(1).get();
    if (existing.docs.isNotEmpty) return Tag.fromFirestore(existing.docs.first);

    final colorIndex = currentTagCount % 6;
    final ref = await _tags(uid).add({'name': trimmed, 'colorIndex': colorIndex});
    return Tag(id: ref.id, name: trimmed, colorIndex: colorIndex);
  }

  /// Etiketi siler. Bu etikete referans veren seanslar etiketsiz (Genel)
  /// görünmeye devam eder, silme onları bozmaz.
  Future<void> deleteTag(String uid, String tagId) async {
    await _tags(uid).doc(tagId).delete();
  }
}
