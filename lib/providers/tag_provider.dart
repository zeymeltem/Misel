import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../services/tag_service.dart';
import 'isar_provider.dart';

/// Kullanılabilir etiketler; yeni etiket eklendiğinde otomatik günceller.
final tagsProvider = StreamProvider<List<Tag>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield TagService.getAll(isar);
  await for (final _ in isar.tags.watchLazy()) {
    yield TagService.getAll(isar);
  }
});

final tagNotifierProvider = NotifierProvider<TagNotifier, void>(TagNotifier.new);

class TagNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<Tag> create(String name) async {
    final isar = await ref.read(isarProvider.future);
    return TagService.createIfAbsent(isar, name);
  }
}
