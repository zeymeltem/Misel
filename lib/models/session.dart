import 'package:isar_plus/isar_plus.dart';

part 'session.g.dart';

enum SessionStatus {
  success,
  failed,
  cancelled;

  @enumValue
  String get value => name;
}

@collection
class Session {
  int id = 0;

  late DateTime startTime;
  late int targetMinutes;
  late int actualMinutes;

  late SessionStatus status;

  int? tagId;
  late int mushroomTypeId;
  late int coinsEarned;
}
