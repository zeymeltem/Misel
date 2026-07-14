import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mantar_odak/main.dart';

void main() {
  testWidgets('Uygulama açılışta çöküyor mu', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MantarOdakApp()),
    );
    await tester.pump();
  });
}
