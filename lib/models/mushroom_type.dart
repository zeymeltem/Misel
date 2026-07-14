import 'package:isar_plus/isar_plus.dart';

part 'mushroom_type.g.dart';

enum MushroomTier {
  starter,
  common,
  rare,
  epic,
  legendary;

  @enumValue
  String get value => name;
}

@collection
class MushroomType {
  int id = 0;

  late String name;

  late MushroomTier tier;

  late int price;
  late String spriteAsset;
  late bool isOwned;
}
