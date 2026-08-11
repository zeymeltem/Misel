import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tag_provider.dart';
import '../../theme/app_theme.dart';

/// Etiket yönetim ekranı: arama, yeni etiket oluşturma, eski etiket silme.
/// Sadece görüntüleme + kullanıcı girdisini alma burada; gerçek okuma/yazma
/// [tagsProvider] / [TagNotifier] üzerinden yapılır.
class TagManagementScreen extends ConsumerStatefulWidget {
  const TagManagementScreen({super.key});

  @override
  ConsumerState<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends ConsumerState<TagManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider).value ?? [];
    final filtered = _query.isEmpty
        ? tags
        : tags.where((t) => t.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Etiketleri Yönet')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTag(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Etiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Etiket ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSizes.gap),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        tags.isEmpty ? 'Henüz etiket yok.' : 'Eşleşen etiket yok.',
                        style: const TextStyle(color: AppColors.tabUnselectedText),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final tag = filtered[index];
                        return _TagRow(
                          name: tag.name,
                          color: AppColors.tagPalette[tag.colorIndex % AppColors.tagPalette.length],
                          onDelete: () => _deleteTag(context, tag.id, tag.name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTag(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni etiket'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Örn. Ders Çalışma',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;
    if (!context.mounted) return;
    try {
      await ref.read(tagNotifierProvider.notifier).create(name);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etiket eklenemedi: $e')),
      );
    }
  }

  Future<void> _deleteTag(BuildContext context, String tagId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etiketi Sil?'),
        content: Text('"$name" etiketi kalıcı olarak silinecek.', style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await ref.read(tagNotifierProvider.notifier).delete(tagId);
  }
}

class _TagRow extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onDelete;

  const _TagRow({required this.name, required this.color, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.taskCardRadius),
        border: Border.all(color: AppColors.chipUnselectedBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: AppTextStyles.taskTitle)),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
