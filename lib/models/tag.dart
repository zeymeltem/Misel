import 'package:isar_plus/isar_plus.dart';

part 'tag.g.dart';

@collection
class Tag {
  int id = 0;

  @Index(unique: true)
  late String name;

  late int colorIndex;
}
