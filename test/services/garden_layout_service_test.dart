import 'package:flutter_test/flutter_test.dart';
import 'package:mantar_odak/services/garden_layout_service.dart';

void main() {
  group('sessionIndexToGridCoord', () {
    // Merkezden dışa sarmal: sağ, yukarı, sol, aşağı; segment uzunluğu
    // 1,1,2,2,3,3,... Bu sabit değerler bozulursa spiral yönü kırılmış demektir.
    const expected = [
      GridCoord(0, 0), // index 0: merkez
      GridCoord(1, 0), // index 1: sağ
      GridCoord(1, 1), // index 2: yukarı
      GridCoord(0, 1), // index 3: sol
      GridCoord(-1, 1), // index 4: sol
      GridCoord(-1, 0), // index 5: aşağı
      GridCoord(-1, -1), // index 6: aşağı
      GridCoord(0, -1), // index 7: sağ (yeni segment, uzunluk 3)
      GridCoord(1, -1), // index 8: sağ
      GridCoord(2, -1), // index 9: sağ
      GridCoord(2, 0), // index 10: yukarı
      GridCoord(2, 1), // index 11: yukarı
      GridCoord(2, 2), // index 12: yukarı
    ];

    for (var i = 0; i < expected.length; i++) {
      test('index $i -> ${expected[i]}', () {
        expect(sessionIndexToGridCoord(i), expected[i]);
      });
    }

    test('deterministik: aynı index her zaman aynı koordinatı verir', () {
      for (var i = 0; i < 200; i++) {
        expect(sessionIndexToGridCoord(i), sessionIndexToGridCoord(i));
      }
    });

    test('her koordinat benzersizdir (çakışma yok)', () {
      final seen = <GridCoord>{};
      for (var i = 0; i < 500; i++) {
        final coord = sessionIndexToGridCoord(i);
        expect(seen.contains(coord), isFalse, reason: 'index $i çakıştı: $coord');
        seen.add(coord);
      }
    });

    test('negatif index hata fırlatır', () {
      expect(() => sessionIndexToGridCoord(-1), throwsArgumentError);
    });
  });

  group('gardenRadius', () {
    test('0 seansla bile en az 1 halka gösterir', () {
      expect(gardenRadius(0), 1);
    });

    test('24 seansta hâlâ 1 halka', () {
      expect(gardenRadius(24), 1);
    });

    test('25 seansta 2. halkaya geçer', () {
      expect(gardenRadius(25), 2);
    });

    test('49 seansta hâlâ 2 halka', () {
      expect(gardenRadius(49), 2);
    });

    test('50 seansta 3. halkaya geçer', () {
      expect(gardenRadius(50), 3);
    });

    test('her 25 seansta bir halka daha ekler', () {
      for (var rings = 1; rings <= 10; rings++) {
        final countAtRingStart = (rings - 1) * 25;
        expect(gardenRadius(countAtRingStart), rings);
      }
    });
  });
}
