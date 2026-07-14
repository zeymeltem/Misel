import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../models/tag.dart';
import '../models/task_log.dart';
import '../services/economy_service.dart';
import '../services/stats_service.dart';
import 'isar_provider.dart';

/// Haftalık odak/başarı/etiket/görev istatistikleri; ilgili koleksiyonlardan
/// biri değişince yeniden hesaplanır.
final weeklyStatsProvider = StreamProvider<WeeklyStats>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield StatsService.getWeeklyStats(isar);

  final changes = StreamController<void>();
  final subs = [
    isar.sessions.watchLazy().listen(changes.add),
    isar.tags.watchLazy().listen(changes.add),
    isar.taskLogs.watchLazy().listen(changes.add),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    changes.close();
  });

  await for (final _ in changes.stream) {
    yield StatsService.getWeeklyStats(isar);
  }
});

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, void>(ProfileNotifier.new);

class ProfileNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> rename(String name) async {
    final isar = await ref.read(isarProvider.future);
    EconomyService.setDisplayName(isar, name);
  }
}
