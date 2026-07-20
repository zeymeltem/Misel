import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/tag.dart';
import '../data/tag_repository.dart';
import 'auth_provider.dart';

/// Kullanılabilir etiketler. Firestore `.snapshots()` zaten canlı akış
/// olduğu için elle invalidate gerekmez.
final tagsProvider = StreamProvider<List<Tag>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return TagRepository().watchTags(uid);
});

final tagNotifierProvider = NotifierProvider<TagNotifier, void>(TagNotifier.new);

class TagNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<Tag?> create(String name) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return null;
    final currentCount = ref.read(tagsProvider).value?.length ?? 0;
    return TagRepository().createIfAbsent(uid, name, currentTagCount: currentCount);
  }

  Future<void> delete(String tagId) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await TagRepository().deleteTag(uid, tagId);
  }
}
