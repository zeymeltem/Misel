import 'package:isar_plus/isar_plus.dart';

part 'task_log.g.dart';

@collection
class TaskLog {
  int id = 0;

  @Index()
  late DateTime date;

  late int taskId;
  late bool wasCompleted;
}
