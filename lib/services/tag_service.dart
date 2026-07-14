import 'package:isar_plus/isar_plus.dart';

import '../models/tag.dart';

class TagService {
  static List<Tag> getAll(Isar isar) {
    final tags = isar.tags.where().findAll();
    tags.sort((a, b) => a.name.compareTo(b.name));
    return tags;
  }

  static Tag createIfAbsent(Isar isar, String name) {
    final trimmed = name.trim();
    final existing = isar.tags.where().nameEqualTo(trimmed).findFirst();
    if (existing != null) return existing;

    final tag = Tag()
      ..name = trimmed
      ..colorIndex = isar.tags.where().count() % 6;

    isar.write((isar) {
      tag.id = isar.tags.autoIncrement();
      isar.tags.put(tag);
    });
    return tag;
  }
}
