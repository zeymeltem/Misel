import 'dart:math';
import 'dart:ui' show Offset;

import '../data/models/session.dart';
import '../data/mushroom_catalog.dart';
import '../theme/app_theme.dart' show AppSizes;

/// Bir parselin (harita sayfasının) tutabileceği mantar slotu sayısı; aynı
/// zamanda yeni parsel açmak için gereken başarılı seans sayısı (bkz.
/// `economy_provider.dart`'taki `gardenProgressProvider`, bu sabiti buradan
/// kullanır — tek kaynak burası).
const int sessionsPerGardenPlot = 25;

/// Çürümüş mantar: tip'ten bağımsız, katalogdaki mantarlar gibi aynı iki
/// dosyalı desene uyar — `_olgun` kullanıcıya gösterilen (timer ekranı vb.),
/// `_harita` bahçe haritasındaki topraklı hali.
const String rottenMushroomSprite = 'assets/images/mushroom_rotten_olgun.png';
const String rottenMushroomMapSprite = 'assets/images/mushroom_rotten_harita.png';

/// Bahçe haritasında yerleştirilmiş tek bir mantar: hangi seansa ait olduğu,
/// hangi parselde (sayfada) olduğu, o parsel içindeki konumu ve gösterilecek
/// sprite yolu.
class GardenCell {
  final Session session;
  final int plotIndex;
  final Offset position;
  final String spriteAsset;

  const GardenCell({
    required this.session,
    required this.plotIndex,
    required this.position,
    required this.spriteAsset,
  });
}

/// Bir seansın durumuna ve mantar türüne göre haritada gösterilecek sprite
/// yolunu döndürür (her zaman haritaya özel topraklı varyant). Tüm sprite
/// seçimi bu tek noktadan geçer.
String resolveMushroomSprite(SessionStatus status, MushroomCatalogItem? mushroomType) {
  if (status == SessionStatus.failed) return rottenMushroomMapSprite;
  return mushroomType?.mapSpriteAsset ?? rottenMushroomMapSprite;
}

/// Bir parseldeki tüm ızgara hücrelerinin (7x8) piksel konumlarını üretir —
/// her konum, sprite'ın hücre içinde yatayda ortalanmış, alttan
/// [AppSizes.gardenMushroomBottomGap] boşluklu köşesidir (mantar zeminden
/// büyüyormuş gibi dursun diye). Sırası [plotIndex] seed'iyle karıştırılır:
/// SAF fonksiyon, aynı parsel her zaman aynı karışık sırayı verir — hiçbir
/// yere kaydedilmez, harita her açılışta buradan yeniden türetilir.
List<Offset> _shuffledPlotCellPositions(int plotIndex) {
  final positions = <Offset>[
    for (var row = 0; row < AppSizes.gardenGridRows; row++)
      for (var col = 0; col < AppSizes.gardenGridCols; col++)
        Offset(
          AppSizes.gardenMapBorder +
              col * AppSizes.gardenCellSize +
              (AppSizes.gardenCellSize - AppSizes.gardenMushroomSize) / 2,
          AppSizes.gardenMapBorder +
              row * AppSizes.gardenCellSize +
              AppSizes.gardenCellSize -
              AppSizes.gardenMushroomBottomGap -
              AppSizes.gardenMushroomSize,
        ),
  ];
  positions.shuffle(Random(plotIndex));
  return positions;
}

/// Bahçe haritasını kurar: cancelled seanslar atlanır, kalanlar başlangıç
/// zamanına göre sıralanıp sırayla parsellere (her biri [sessionsPerGardenPlot]
/// slotluk) dağıtılır.
List<GardenCell> layoutGarden(List<Session> sessions) {
  final placedSessions = sessions.where((s) => s.status != SessionStatus.cancelled).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  final cells = <GardenCell>[];
  final positionsByPlot = <int, List<Offset>>{};

  for (var i = 0; i < placedSessions.length; i++) {
    final plotIndex = i ~/ sessionsPerGardenPlot;
    final slotIndex = i % sessionsPerGardenPlot;
    final positions = positionsByPlot.putIfAbsent(plotIndex, () => _shuffledPlotCellPositions(plotIndex));
    final position = positions[slotIndex];

    cells.add(GardenCell(
      session: placedSessions[i],
      plotIndex: plotIndex,
      position: position,
      spriteAsset: resolveMushroomSprite(
        placedSessions[i].status,
        MushroomCatalog.byId(placedSessions[i].mushroomTypeId),
      ),
    ));
  }
  return cells;
}
