import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String id;
  final String name;
  final int colorIndex;

  const Tag({required this.id, required this.name, required this.colorIndex});

  factory Tag.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Tag(id: doc.id, name: data['name'] as String, colorIndex: data['colorIndex'] as int);
  }

  Map<String, dynamic> toMap() => {'name': name, 'colorIndex': colorIndex};
}
