import 'package:isar_plus/isar_plus.dart';

import '../models/mushroom_type.dart';
import '../models/session.dart';
import '../models/user_stats.dart';

/// Bahçede yeni parsel açmak için gereken başarılı seans sayısı.
const int sessionsPerGardenPlot = 25;

class GardenProgress {
  final int unlockedPlots;
  final int sessionsUntilNextPlot;

  const GardenProgress({
    required this.unlockedPlots,
    required this.sessionsUntilNextPlot,
  });
}

enum PurchaseResult { success, alreadyOwned, insufficientCoins, notFound }

class EconomyService {
  static UserStats getUserStats(Isar isar) {
    return isar.userStats.get(0) ?? UserStats();
  }

  static List<MushroomType> getShopMushrooms(Isar isar) {
    return isar.mushroomTypes.where().findAll();
  }

  static List<MushroomType> getOwnedMushrooms(Isar isar) {
    return isar.mushroomTypes.where().isOwnedEqualTo(true).findAll();
  }

  /// Hedef süreye göre kazanılacak coin miktarı (seans başarıyla bitince
  /// gerçekte kazanılan miktarla aynı formül; kurulum ekranında önizleme için).
  static int estimateCoins(int targetMinutes) {
    return (targetMinutes * (0.25 + targetMinutes / 160)).round();
  }

  static GardenProgress getGardenProgress(Isar isar) {
    final successCount =
        isar.sessions.where().statusEqualTo(SessionStatus.success).count();
    final unlockedPlots = successCount ~/ sessionsPerGardenPlot;
    final intoCurrentPlot = successCount % sessionsPerGardenPlot;
    return GardenProgress(
      unlockedPlots: unlockedPlots,
      sessionsUntilNextPlot: sessionsPerGardenPlot - intoCurrentPlot,
    );
  }

  /// Başarılı seans sonrası coin ekler ve günlük seriyi günceller. Aynı gün
  /// içindeki ikinci başarı seriyi artırmaz; bir gün atlanırsa seri sıfırlanır.
  static void recordSuccessfulSession(Isar isar, {required int coins}) {
    final stats = getUserStats(isar);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = stats.lastSuccessDate;

    if (last == null) {
      stats.currentStreak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final dayGap = today.difference(lastDay).inDays;
      if (dayGap == 1) {
        stats.currentStreak += 1;
      } else if (dayGap > 1) {
        stats.currentStreak = 1;
      }
      // dayGap == 0: bugün zaten sayıldı, seri değişmez.
    }
    if (stats.currentStreak > stats.longestStreak) {
      stats.longestStreak = stats.currentStreak;
    }
    stats.lastSuccessDate = today;
    stats.totalCoins += coins;

    isar.write((isar) => isar.userStats.put(stats));
  }

  static void setDisplayName(Isar isar, String name) {
    final stats = getUserStats(isar);
    stats.displayName = name.trim();
    isar.write((isar) => isar.userStats.put(stats));
  }

  static PurchaseResult buyMushroom(Isar isar, int mushroomTypeId) {
    final mushroom = isar.mushroomTypes.get(mushroomTypeId);
    if (mushroom == null) return PurchaseResult.notFound;
    if (mushroom.isOwned) return PurchaseResult.alreadyOwned;

    final stats = getUserStats(isar);
    if (stats.totalCoins < mushroom.price) {
      return PurchaseResult.insufficientCoins;
    }

    isar.write((isar) {
      stats.totalCoins -= mushroom.price;
      isar.userStats.put(stats);

      mushroom.isOwned = true;
      isar.mushroomTypes.put(mushroom);
    });
    return PurchaseResult.success;
  }
}
