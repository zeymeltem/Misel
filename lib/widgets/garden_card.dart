import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../models/mushroom_type.dart';
import '../models/tag.dart';
import '../providers/economy_provider.dart';
import '../providers/tag_provider.dart';
import '../theme/app_theme.dart';
import 'coin_badge.dart';

enum GardenPeriod { all, today, week, month }

extension GardenPeriodX on GardenPeriod {
  String get label => switch (this) {
        GardenPeriod.all => 'Tümü',
        GardenPeriod.today => 'Bugün',
        GardenPeriod.week => 'Hafta',
        GardenPeriod.month => 'Ay',
      };
}

/// Ana sayfanın üst kısmı: bahçe başlığı, coin rozeti, dönem sekmeleri,
/// parsel ilerleme banner'ı ve bahçe haritası.
/// Bahçede başarılı seanslarla büyütülen gerçek mantarları gösterir.
class GardenCard extends ConsumerStatefulWidget {
  const GardenCard({super.key});

  @override
  ConsumerState<GardenCard> createState() => _GardenCardState();
}

class _GardenCardState extends ConsumerState<GardenCard> {
  GardenPeriod _period = GardenPeriod.all;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(gardenProgressProvider).value;
    final sessionsAsync = ref.watch(successfulSessionsProvider);
    final shopMushroomsAsync = ref.watch(shopMushroomsProvider);
    final tagsAsync = ref.watch(tagsProvider);

    final sessions = sessionsAsync.value ?? [];
    final shopMushrooms = shopMushroomsAsync.value ?? [];
    final tags = tagsAsync.value ?? [];

    // Filter sessions based on period
    final now = DateTime.now();
    final filteredSessions = sessions.where((s) {
      switch (_period) {
        case GardenPeriod.all:
          return true;
        case GardenPeriod.today:
          return s.startTime.year == now.year &&
              s.startTime.month == now.month &&
              s.startTime.day == now.day;
        case GardenPeriod.week:
          final startOfWeek = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          return s.startTime.isAfter(startOfWeek) ||
              s.startTime.isAtSameMomentAs(startOfWeek);
        case GardenPeriod.month:
          return s.startTime.year == now.year && s.startTime.month == now.month;
      }
    }).toList();

    // Sort chronologically (so they fill the garden in order)
    filteredSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    final totalCells = filteredSessions.length;
    final int pageCount = (totalCells / 25).ceil().clamp(1, 999);
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Bahçen', style: AppTextStyles.sectionTitle),
            const CoinBadge(),
          ],
        ),
        const SizedBox(height: AppSizes.gap),
        Row(
          children: GardenPeriod.values.map((p) => _PeriodTab(
                period: p,
                selected: p == _period,
                onTap: () {
                  setState(() {
                    _period = p;
                    _currentPage = 0; // Reset page on period change
                  });
                },
              )).toList(),
        ),
        const SizedBox(height: AppSizes.gap),
        
        // Progress Banner & Paginator combined
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gardenBanner,
            borderRadius: BorderRadius.circular(AppSizes.bannerRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress != null
                    ? 'yeni parsel: ${progress.sessionsUntilNextPlot} seans'
                    : 'seanslar yükleniyor...',
                style: AppTextStyles.bannerText,
              ),
              if (pageCount > 1)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20, color: AppColors.gardenBannerText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Parsel ${_currentPage + 1}/$pageCount',
                      style: AppTextStyles.bannerText,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20, color: AppColors.gardenBannerText),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentPage < pageCount - 1
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gap),

        // Garden Grid view container
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/garden_bg.png',
                height: AppSizes.gardenCardHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Soft green overlay
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.04),
                ),
              ),
              // The 5x5 Grid
              Container(
                height: AppSizes.gardenCardHeight,
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    final sessionIndex = _currentPage * 25 + index;
                    if (sessionIndex < filteredSessions.length) {
                      final session = filteredSessions[sessionIndex];
                      final mushroom = shopMushrooms.where((m) => m.id == session.mushroomTypeId).firstOrNull ??
                          (shopMushrooms.isNotEmpty ? shopMushrooms.first : null);

                      return GestureDetector(
                        onTap: () => _showSessionDetails(context, session, mushroom, tags),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 20).clamp(0, 300)),
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: mushroom != null
                                ? Image.asset(mushroom.spriteAsset)
                                : const Center(child: Text('🍄', style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      );
                    } else {
                      // Empty slot
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSessionDetails(BuildContext context, Session session, MushroomType? mushroom, List<Tag> tags) {
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
            if (mushroom != null) ...[
              Image.asset(mushroom.spriteAsset, width: 72, height: 72),
              const SizedBox(height: 12),
              Text(
                mushroom.name,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                mushroom.tier.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getTierColor(mushroom.tier),
                  letterSpacing: 1.2,
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailColumn(
                  icon: Icons.timer_outlined,
                  label: 'SÜRE',
                  value: '${session.actualMinutes} dk',
                ),
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
            Text(
              'Tarih: ${_formatDateTime(session.startTime)}',
              style: AppTextStyles.warning,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(MushroomTier tier) {
    return switch (tier) {
      MushroomTier.starter => AppColors.tabUnselectedText,
      MushroomTier.common => AppColors.shopIconCommon,
      MushroomTier.rare => AppColors.shopIconRare,
      MushroomTier.epic => Colors.purple,
      MushroomTier.legendary => AppColors.shopIconLegendary,
    };
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _PeriodTab extends StatelessWidget {
  final GardenPeriod period;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.period,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.tabSelectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.pillRadius),
          ),
          child: Text(
            period.label,
            style: AppTextStyles.tab.copyWith(
              color: selected ? AppColors.tabSelectedText : AppColors.tabUnselectedText,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailColumn({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

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
          style: AppTextStyles.statValue.copyWith(
            fontSize: 14,
            color: valueColor ?? AppColors.statValueText,
          ),
        ),
      ],
    );
  }
}
