import 'package:isar_plus/isar_plus.dart';

part 'user_stats.g.dart';

@collection
class UserStats {
  int id = 0;

  int totalCoins = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastSuccessDate;
  DateTime? lastOpenDate;
  int? selectedMushroomTypeId;
  String? displayName;
}
