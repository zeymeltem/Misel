import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/tag.dart';
import '../providers/garden_provider.dart';
import '../providers/tag_provider.dart';
import '../services/garden_layout_service.dart';
import '../theme/app_theme.dart';

/// Bahçe haritası: tüm seansların (cancelled hariç) merkezden dışa sarmal
/// yerleştiği, kaydırılabilir + yakınlaştırılabilir ızgara. Harita hiçbir
/// yerde saklanmaz — her açılışta [gardenCellsProvider] üzerinden Session
/// kayıtlarından yeniden türetilir.
class GardenMap extends ConsumerStatefulWidget {
  const GardenMap({super.key});

  @override
  ConsumerState<GardenMap> createState() => _GardenMapState();
}

class _GardenMapState extends ConsumerState<GardenMap> {
  final _controller = TransformationController();
  Rect _visibleRect = Rect.zero;
  bool _centered = false;
  double? _lastCenterOffset;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateVisibleRect(Size viewportSize) {
    final matrix = _controller.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();
    final rect = Rect.fromLTWH(
      -translation.x / scale,
      -translation.y / scale,
      viewportSize.width / scale,
      viewportSize.height / scale,
    ).inflate(AppSizes.gardenCellSize * 2);
    if (rect != _visibleRect && mounted) {
      setState(() => _visibleRect = rect);
    }
  }

  void _centerOn(double mapSize, Size viewportSize) {
    if (_centered) return;
    _centered = true;
    final offset = (mapSize / 2) - (viewportSize.width / 2);
    _controller.value = Matrix4.translationValues(-offset, -offset, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleRect(viewportSize));
  }

  /// Bahçe büyüyüp (0,0) merkezinin piksel karşılığı kaydığında (centerOffset
  /// artınca), görünümü aynı yerde tutmak için transform'u telafi eder.
  /// Aksi halde her yeni halka eklendiğinde tüm mantarlar görünüm dışına
  /// kaymış gibi görünürdü.
  void _compensateAnchorShift(double delta, Size viewportSize) {
    _controller.value = _controller.value.clone()..translateByDouble(-delta, -delta, 0, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleRect(viewportSize));
  }

  @override
  Widget build(BuildContext context) {
    final cells = ref.watch(gardenCellsProvider);
    final tags = ref.watch(tagsProvider).value ?? [];
    final radius = gardenRadius(cells.length);
    const cellSize = AppSizes.gardenCellSize;
    final mapSize = (2 * radius + 1) * cellSize;
    final centerOffset = radius * cellSize;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: SizedBox(
        height: AppSizes.gardenCardHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportSize = constraints.biggest;
            WidgetsBinding.instance.addPostFrameCallback((_) => _centerOn(mapSize, viewportSize));
            if (_visibleRect == Rect.zero) {
              _visibleRect = Rect.fromLTWH(0, 0, viewportSize.width, viewportSize.height)
                  .inflate(cellSize * 2);
            }
            if (_centered && _lastCenterOffset != null && _lastCenterOffset != centerOffset) {
              final delta = centerOffset - _lastCenterOffset!;
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _compensateAnchorShift(delta, viewportSize));
            }
            _lastCenterOffset = centerOffset;

            final visibleCells = cells.where((cell) {
              final left = centerOffset + cell.coord.x * cellSize;
              final top = centerOffset - cell.coord.y * cellSize;
              return _visibleRect.overlaps(Rect.fromLTWH(left, top, cellSize, cellSize));
            }).toList();

            return NotificationListener<Notification>(
              onNotification: (_) => false,
              child: InteractiveViewer(
                transformationController: _controller,
                constrained: false,
                minScale: 0.4,
                maxScale: 3,
                boundaryMargin: const EdgeInsets.all(80),
                onInteractionUpdate: (_) => _updateVisibleRect(viewportSize),
                child: SizedBox(
                  width: mapSize,
                  height: mapSize,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: const AssetImage('assets/images/garden_bg.png'),
                              repeat: ImageRepeat.repeat,
                              fit: BoxFit.none,
                              filterQuality: FilterQuality.none,
                            ),
                            color: AppColors.gardenBackground,
                          ),
                        ),
                      ),
                      for (final cell in visibleCells)
                        Positioned(
                          left: centerOffset + cell.coord.x * cellSize,
                          top: centerOffset - cell.coord.y * cellSize,
                          width: cellSize,
                          height: cellSize,
                          child: _MushroomTile(
                            cell: cell,
                            onTap: () => _showSessionDetails(context, cell, tags),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, GardenCell cell, List<Tag> tags) {
    final session = cell.session;
    final matchingTags = tags.where((t) => t.id == session.tagId);
    final tagName = matchingTags.isEmpty ? 'Genel' : matchingTags.first.name;
    final tagColor = matchingTags.isEmpty
        ? AppColors.tabUnselectedText
        : AppColors.tagPalette[matchingTags.first.colorIndex % AppColors.tagPalette.length];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _MushroomSprite(spriteAsset: cell.spriteAsset, size: 72),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailColumn(icon: Icons.timer_outlined, label: 'SÜRE', value: '${session.actualMinutes} dk'),
                _DetailColumn(
                  icon: Icons.tag,
                  label: 'ETİKET',
                  value: tagName,
                  valueColor: tagColor,
                ),
                _DetailColumn(
                  icon: Icons.monetization_on,
                  label: 'ÖDÜL',
                  value: '+${session.coinsEarned}',
                  valueColor: AppColors.coinBadgeText,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Tarih: ${_formatDateTime(session.startTime)}', style: AppTextStyles.warning),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _MushroomTile extends StatelessWidget {
  final GardenCell cell;
  final VoidCallback onTap;
  const _MushroomTile({required this.cell, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 1)),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: _MushroomSprite(spriteAsset: cell.spriteAsset, size: AppSizes.gardenCellSize - 16),
        ),
      ),
    );
  }
}

/// Sprite'ı çizer; gerçek pixel art eklenene kadar (placeholder dosya
/// yoksa) emoji fallback gösterir.
class _MushroomSprite extends StatelessWidget {
  final String spriteAsset;
  final double size;
  const _MushroomSprite({required this.spriteAsset, required this.size});

  @override
  Widget build(BuildContext context) {
    final isRotten = spriteAsset == rottenMushroomSprite;
    return Image.asset(
      spriteAsset,
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stack) => Center(
        child: Text(isRotten ? '🥀' : '🍄', style: TextStyle(fontSize: size * 0.6)),
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailColumn({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.tabUnselectedText.withOpacity(0.8)),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.statLabel.copyWith(fontSize: 10, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(fontSize: 14, color: valueColor ?? AppColors.statValueText),
        ),
      ],
    );
  }
}
