import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/tag.dart';
import '../providers/garden_provider.dart';
import '../providers/tag_provider.dart';
import '../services/garden_layout_service.dart';
import '../theme/app_theme.dart';
import 'pixel_number.dart';

/// Bahçe haritası: sabit boyutlu (352x400) tasarım PNG'si üstünde, o
/// parsele ait mantarlar rastgele-ama-sabit konumlarda gösterilir. Seans
/// sayısı arttıkça yeni parseller (sayfalar) açılır, yatay kaydırmayla
/// gezilir. Harita hiçbir yerde saklanmaz — her açılışta
/// [gardenCellsProvider] üzerinden Session kayıtlarından yeniden türetilir.
class GardenMap extends ConsumerStatefulWidget {
  const GardenMap({super.key});

  @override
  ConsumerState<GardenMap> createState() => _GardenMapState();
}

class _GardenMapState extends ConsumerState<GardenMap> {
  final _pageController = PageController();
  bool _jumpedToLast = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cells = ref.watch(gardenCellsProvider);
    final tags = ref.watch(tagsProvider).value ?? [];

    final plotCount = cells.isEmpty ? 1 : cells.map((c) => c.plotIndex).reduce((a, b) => a > b ? a : b) + 1;
    final cellsByPlot = <int, List<GardenCell>>{};
    for (final cell in cells) {
      cellsByPlot.putIfAbsent(cell.plotIndex, () => []).add(cell);
    }

    // İlk açılışta en son (dolmakta olan) parsele atla — kullanıcı her seferinde
    // en güncel bahçesini görsün.
    if (!_jumpedToLast) {
      _jumpedToLast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) _pageController.jumpToPage(plotCount - 1);
      });
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: AspectRatio(
            aspectRatio: AppSizes.gardenMapWidth / AppSizes.gardenMapHeight,
            child: PageView.builder(
              controller: _pageController,
              itemCount: plotCount,
              itemBuilder: (context, plotIndex) => _GardenPlotPage(
                cells: cellsByPlot[plotIndex] ?? const [],
                onCellTap: (cell) => _showSessionDetails(context, cell, tags),
              ),
            ),
          ),
        ),
        if (plotCount > 1) ...[
          const SizedBox(height: 8),
          _PlotIndicator(controller: _pageController, plotCount: plotCount),
        ],
      ],
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
            NumberText('Tarih: ${_formatDateTime(session.startTime)}', style: AppTextStyles.warning),
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

/// Tek bir parselin sayfası: sabit 352x400 tasarım arka planı + üstünde o
/// parsele düşen mantarlar. Ekran genişliğine göre orantılı ölçeklenir
/// (LayoutBuilder + FittedBox), pixel art netliği FilterQuality.none ile korunur.
class _GardenPlotPage extends StatelessWidget {
  final List<GardenCell> cells;
  final ValueChanged<GardenCell> onCellTap;

  const _GardenPlotPage({required this.cells, required this.onCellTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: AppSizes.gardenMapWidth,
            height: AppSizes.gardenMapHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/garden_map.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                for (final cell in cells)
                  Positioned(
                    // cell.position zaten hücre içinde ortalanmış + alttan
                    // boşluklu sol-üst köşe (bkz. garden_layout_service.dart).
                    left: cell.position.dx,
                    top: cell.position.dy,
                    width: AppSizes.gardenMushroomSize,
                    height: AppSizes.gardenMushroomSize,
                    child: GestureDetector(
                      onTap: () => onCellTap(cell),
                      child: _MushroomSprite(spriteAsset: cell.spriteAsset, size: AppSizes.gardenMushroomSize),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Kaçıncı parselin görüntülendiğini gösteren metin ("Parsel 3 / 20").
/// Nokta-başına-parsel göstergesi yerine metin kullanılır: parsel sayısı
/// çok arttığında (bkz. dev "+500 test seansı") noktalar satırı taşardı,
/// metin her koşulda sabit genişlikte kalır.
class _PlotIndicator extends StatelessWidget {
  final PageController controller;
  final int plotCount;

  const _PlotIndicator({required this.controller, required this.plotCount});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = controller.hasClients && controller.page != null
            ? controller.page!.round()
            : plotCount - 1;
        return NumberText(
          'Parsel ${current + 1} / $plotCount',
          style: AppTextStyles.warning,
        );
      },
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
    final isRotten = spriteAsset == rottenMushroomMapSprite;
    return Image.asset(
      spriteAsset,
      width: size,
      height: size,
      fit: BoxFit.fill,
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
        Icon(icon, size: 20, color: AppColors.tabUnselectedText.withValues(alpha: 0.8)),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.statLabel.copyWith(fontSize: 8, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        NumberText(
          value,
          style: AppTextStyles.statValue.copyWith(
            fontSize: 16,
            letterSpacing: -0.5,
            color: valueColor ?? AppColors.statValueText,
          ),
        ),
      ],
    );
  }
}
