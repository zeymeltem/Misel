import 'package:flutter_test/flutter_test.dart';
import 'package:mantar_odak/data/models/session.dart';
import 'package:mantar_odak/services/garden_layout_service.dart';

Session _session(int i, {SessionStatus status = SessionStatus.success}) {
  return Session(
    id: 'session-$i',
    startTime: DateTime(2026, 1, 1).add(Duration(minutes: i)),
    targetMinutes: 25,
    actualMinutes: 25,
    status: status,
    tagId: null,
    mushroomTypeId: 'starter',
    coinsEarned: 10,
  );
}

void main() {
  group('layoutGarden', () {
    test('cancelled seanslar haritada hiç yer kaplamaz', () {
      final sessions = [
        _session(0),
        _session(1, status: SessionStatus.cancelled),
        _session(2),
      ];
      final cells = layoutGarden(sessions);
      expect(cells.length, 2);
      expect(cells.every((c) => c.session.status != SessionStatus.cancelled), isTrue);
    });

    test('deterministik: aynı seans listesi her zaman aynı konumları verir', () {
      final sessions = List.generate(40, (i) => _session(i));
      final first = layoutGarden(sessions);
      final second = layoutGarden(sessions);
      for (var i = 0; i < first.length; i++) {
        expect(first[i].position, second[i].position);
        expect(first[i].plotIndex, second[i].plotIndex);
      }
    });

    test('her parsel sessionsPerGardenPlot kadar slot tutar, sonrası sonraki parsele taşar', () {
      final sessions = List.generate(sessionsPerGardenPlot + 5, (i) => _session(i));
      final cells = layoutGarden(sessions);

      final firstPlot = cells.take(sessionsPerGardenPlot);
      final secondPlot = cells.skip(sessionsPerGardenPlot);

      expect(firstPlot.every((c) => c.plotIndex == 0), isTrue);
      expect(secondPlot.every((c) => c.plotIndex == 1), isTrue);
    });

    test('aynı parseldeki mantarlar birbirinin üstüne binmez (min mesafe korunur)', () {
      final sessions = List.generate(sessionsPerGardenPlot, (i) => _session(i));
      final cells = layoutGarden(sessions);

      for (var i = 0; i < cells.length; i++) {
        for (var j = i + 1; j < cells.length; j++) {
          final distance = (cells[i].position - cells[j].position).distance;
          expect(distance, greaterThan(0), reason: '${cells[i].session.id} ve ${cells[j].session.id} aynı yerde');
        }
      }
    });

    test('başarısız seans haritaya özel (topraklı) çürük mantar sprite\'ı alır', () {
      final cells = layoutGarden([_session(0, status: SessionStatus.failed)]);
      expect(cells.single.spriteAsset, rottenMushroomMapSprite);
    });

    test('boş seans listesi boş harita verir', () {
      expect(layoutGarden([]), isEmpty);
    });
  });
}
