import 'package:isar_plus/isar_plus.dart';

part 'task.g.dart';

@collection
class Task {
  int id = 0;

  late String title;
  late bool isRoutine;
  late bool isDone;
  late DateTime createdAt;
  DateTime? archivedAt;
}
