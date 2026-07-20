import 'package:flutter_test/flutter_test.dart';

import 'package:mantar_odak/services/economy_service.dart';

void main() {
  group('EconomyService.estimateCoins', () {
    test('formül: dakika * (0.25 + dakika/160), yuvarlanmış', () {
      // 25 dk: 25 * (0.25 + 25/160) = 25 * 0.40625 = 10.15625 → 10
      expect(EconomyService.estimateCoins(25), 10);
      // 60 dk: 60 * (0.25 + 60/160) = 60 * 0.625 = 37.5 → 38 (round half up)
      expect(EconomyService.estimateCoins(60), 38);
      // 120 dk: 120 * (0.25 + 120/160) = 120 * 1.0 = 120
      expect(EconomyService.estimateCoins(120), 120);
    });

    test('uzun seans dakika başına daha çok kazandırır (teşvik eğrisi)', () {
      final shortRate = EconomyService.estimateCoins(15) / 15;
      final longRate = EconomyService.estimateCoins(120) / 120;
      expect(longRate, greaterThan(shortRate));
    });

    test('slider aralığındaki (15-120 dk) her değer pozitif coin verir', () {
      for (var m = 15; m <= 120; m += 5) {
        expect(EconomyService.estimateCoins(m), greaterThan(0),
            reason: '$m dakika 0 coin veriyor');
      }
    });
  });
}
