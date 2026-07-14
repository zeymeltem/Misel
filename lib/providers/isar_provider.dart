import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

import '../services/isar_service.dart';
import '../services/seed_service.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final isar = await IsarService.open();
  SeedService.ensureShopMushrooms(isar);
  return isar;
});
