import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/mushroom_type.dart';
import '../models/session.dart';
import '../models/tag.dart';
import '../models/task.dart';
import '../models/task_log.dart';
import '../models/user_stats.dart';

class IsarService {
  static Future<Isar> open() async {
    if (kIsWeb) {
      await Isar.initialize();
    }
    final dir = kIsWeb ? null : await getApplicationDocumentsDirectory();
    return Isar.open(
      schemas: [
        SessionSchema,
        TagSchema,
        TaskSchema,
        TaskLogSchema,
        MushroomTypeSchema,
        UserStatsSchema,
      ],
      directory: dir?.path ?? 'mantar_odak',
      engine: kIsWeb ? IsarEngine.sqlite : IsarEngine.isar,
    );
  }
}
