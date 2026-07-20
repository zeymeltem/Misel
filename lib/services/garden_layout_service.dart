import '../data/models/session.dart';
import '../data/mushroom_catalog.dart';

/// Bahçe ızgarasında bir hücrenin koordinatı. (0,0) merkezdir; x sağa, y
/// yukarı doğru artar.
class GridCoord {
  final int x;
  final int y;
  const GridCoord(this.x, this.y);

  @override
  bool operator ==(Object other) => other is GridCoord && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'GridCoord($x, $y)';
}

/// Bahçe haritasında yerleştirilmiş tek bir mantar: hangi seansa ait olduğu,
/// hücresi ve gösterilecek sprite yolu.
class GardenCell {
  final Session session;
  final GridCoord coord;
  final String spriteAsset;

  const GardenCell({required this.session, required this.coord, required this.spriteAsset});
}

/// Rotten/gray placeholder — gerçek pixel art eklenene kadar aynı isimle
/// referans edilir (bkz. CLAUDE.md: "Şimdilik placeholder kullan").
const String rottenMushroomSprite = 'assets/images/mushroom_rotten.png';

/// Seans sırasını (index: 0, 1, 2, ...) merkezden dışa sarmal (spiral) bir
/// ızgara hücresine çevirir. SAF fonksiyon: aynı index her zaman aynı
/// koordinatı verir, hiçbir yere kaydedilmez — harita her zaman bu
/// fonksiyondan yeniden türetilir.
///
/// Yön sırası sağ → yukarı → sol → aşağı; her yön çiftinde segment uzunluğu
/// bir artar (1,1,2,2,3,3,...), böylece merkezden dışa genişleyen kare
/// halkalar oluşur (halka r'de 8r hücre).
GridCoord sessionIndexToGridCoord(int index) {
  if (index < 0) {
    throw ArgumentError.value(index, 'index', 'negatif olamaz');
  }
  if (index == 0) return const GridCoord(0, 0);

  const dx = [1, 0, -1, 0]; // sağ, yukarı, sol, aşağı
  const dy = [0, 1, 0, -1];

  var x = 0;
  var y = 0;
  var remaining = index;
  var segmentLength = 1;
  var direction = 0;

  while (true) {
    for (var rep = 0; rep < 2; rep++) {
      for (var step = 0; step < segmentLength; step++) {
        x += dx[direction];
        y += dy[direction];
        remaining--;
        if (remaining == 0) return GridCoord(x, y);
      }
      direction = (direction + 1) % 4;
    }
    segmentLength++;
  }
}

/// Seans sayısına göre bahçenin kaç halka (merkezden itibaren yarıçap)
/// göstermesi gerektiğini hesaplar. Her 25 seansta bir halka daha eklenir;
/// 0 seansla bile en az 1 halka gösterilir (boş bahçe tek nokta olmasın).
int gardenRadius(int sessionCount) {
  if (sessionCount < 0) return 1;
  return (sessionCount ~/ 25) + 1;
}

/// Bir seansın durumuna ve mantar türüne göre gösterilecek sprite yolunu
/// döndürür. Tüm sprite seçimi bu tek noktadan geçer.
String resolveMushroomSprite(SessionStatus status, MushroomCatalogItem? mushroomType) {
  if (status == SessionStatus.failed) return rottenMushroomSprite;
  return mushroomType?.spriteAsset ?? rottenMushroomSprite;
}

/// Bahçe haritasını kurar: cancelled seanslar atlanır (haritada boşluk
/// bırakmamak için index'lemeye hiç girmezler), kalanlar başlangıç zamanına
/// göre sıralanıp sırayla ızgaraya yerleştirilir.
List<GardenCell> layoutGarden(List<Session> sessions) {
  final placedSessions = sessions.where((s) => s.status != SessionStatus.cancelled).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  return [
    for (var i = 0; i < placedSessions.length; i++)
      GardenCell(
        session: placedSessions[i],
        coord: sessionIndexToGridCoord(i),
        spriteAsset: resolveMushroomSprite(
          placedSessions[i].status,
          MushroomCatalog.byId(placedSessions[i].mushroomTypeId),
        ),
      ),
  ];
}
