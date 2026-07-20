import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/economy_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/timer_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mushroom_growth_ring.dart';
import '../../widgets/mushroom_picker.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/tag_selector.dart';
import '../../widgets/today_tasks_section.dart';

/// Sayaç: seans kurulumu + odak seansı (kronometre) + yaşam döngüsü tespiti.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Önceki çalıştırma seans ortasında kapandıysa o seansı başarısız işle.
    // RootShell IndexedStack kullandığı için bu initState uygulama açılışında
    // bir kez çalışır.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerProvider.notifier).recoverAbandonedSession();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(timerProvider.notifier);
    if (state == AppLifecycleState.paused) {
      notifier.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      notifier.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);

    return Scaffold(
      body: switch (timer.phase) {
        TimerPhase.idle => _SetupView(timer: timer),
        TimerPhase.running => _ActiveView(timer: timer),
        TimerPhase.success => _ResultView(
            success: true,
            coinsEarned: timer.coinsEarned,
            mushroomTypeId: timer.mushroomTypeId,
          ),
        TimerPhase.failed => _ResultView(
            success: false,
            coinsEarned: 0,
            mushroomTypeId: timer.mushroomTypeId,
          ),
      },
    );
  }
}

class _SetupView extends ConsumerWidget {
  final TimerState timer;
  const _SetupView({required this.timer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerProvider.notifier);
    final stats = ref.watch(userStatsProvider).value;
    final totalCoins = stats?.totalCoins ?? 0;

    final ownedMushrooms = ref.watch(ownedMushroomsProvider);
    final selectedMushroomId = timer.mushroomTypeId ?? ownedMushrooms.firstOrNull?.id;
    if (timer.mushroomTypeId == null && ownedMushrooms.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(timerProvider).mushroomTypeId == null) {
          notifier.setMushroomType(ownedMushrooms.first.id);
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Odaklanma Zamanı',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 2),
                  const StreakBadge(suffix: 'günlük seri'),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.coinBadge,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, size: 16, color: AppColors.coinBadgeText),
                    const SizedBox(width: 4),
                    Text('$totalCoins', style: AppTextStyles.coinValue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 1: Duration Setup Card
          _SetupCard(
            icon: Icons.access_time_filled_rounded,
            title: 'Süre Seç',
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  '${timer.targetMinutes} dk',
                  style: AppTextStyles.durationValue.copyWith(
                    color: AppColors.tabSelectedBg,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gardenBanner,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, size: 14, color: AppColors.coinPreviewText),
                      const SizedBox(width: 4),
                      Text(
                        '+${timer.estimatedCoins} coin kazanacaksın',
                        style: AppTextStyles.coinPreview,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.tabSelectedBg,
                    inactiveTrackColor: AppColors.progressTrackBg,
                    trackHeight: 6.0,
                    thumbColor: AppColors.tabSelectedBg,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    overlayColor: AppColors.tabSelectedBg.withOpacity(0.12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                  ),
                  child: Slider(
                    value: timer.targetMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 21,
                    label: '${timer.targetMinutes} dk',
                    onChanged: (value) => notifier.setTargetMinutes(value.round()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gap),

          // Section 2: Tag Selection Card
          _SetupCard(
            icon: Icons.label_rounded,
            title: 'Etiket Belirle',
            child: TagSelector(
              selectedTagId: timer.tagId,
              onChanged: notifier.setTag,
            ),
          ),
          const SizedBox(height: AppSizes.gap),

          // Section 3: Mushroom Picker Card
          _SetupCard(
            icon: Icons.park_rounded,
            title: 'Büyütülecek Mantar',
            child: MushroomPicker(
              selectedId: selectedMushroomId,
              onChanged: notifier.setMushroomType,
            ),
          ),
          const SizedBox(height: 24),

          // Start Button
          FilledButton(
            onPressed: notifier.start,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tabSelectedBg,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
            ),
            child: const Text(
              'Seansı Başlat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const TodayTasksSection(),
        ],
      ),
    );
  }
}

class _ActiveView extends ConsumerWidget {
  final TimerState timer;
  const _ActiveView({required this.timer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerProvider.notifier);
    final tags = ref.watch(tagsProvider).value ?? [];
    final matchingTags = tags.where((t) => t.id == timer.tagId);
    final tagName = matchingTags.isEmpty ? null : matchingTags.first.name;

    final mushrooms = ref.watch(shopMushroomsProvider);
    final selectedMushroom = mushrooms.where((m) => m.id == timer.mushroomTypeId).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: MushroomGrowthRing(
              progress: timer.progress,
              mushroomSprite: selectedMushroom?.spriteAsset,
            ),
          ),
          const SizedBox(height: 24),
          
          // Focus Info Chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (tagName != null)
                _InfoChip(
                  text: tagName,
                  bg: AppColors.chipSelectedBg,
                  textColor: AppColors.chipSelectedText,
                ),
              _InfoChip(
                text: '${timer.targetMinutes} dk',
                bg: AppColors.chipSelectedBg,
                textColor: AppColors.chipSelectedText,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cancel/Give Up button with warning popup
          OutlinedButton(
            onPressed: () => _showGiveUpConfirmation(context, notifier),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Colors.redAccent, width: 1.2),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
            ),
            child: const Text(
              'Vazgeç',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          
          const Align(
            alignment: Alignment.centerLeft,
            child: TodayTasksSection(readOnly: true),
          ),
        ],
      ),
    );
  }

  Future<void> _showGiveUpConfirmation(BuildContext context, TimerNotifier notifier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seanstan Vazgeç?'),
        content: const Text(
          'Eğer şimdi vazgeçersen büyütmekte olduğun mantar çürüyecek ve bu seans kaydedilmeyecek. Yine de vazgeçmek istiyor musun?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Devam et'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Evet, Vazgeç'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await notifier.cancelSession();
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  const _InfoChip({required this.text, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSizes.chipRadius)),
      child: Text(text, style: AppTextStyles.chip.copyWith(color: textColor)),
    );
  }
}

class _ResultView extends ConsumerWidget {
  final bool success;
  final int coinsEarned;
  final String? mushroomTypeId;

  const _ResultView({
    required this.success,
    required this.coinsEarned,
    required this.mushroomTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerProvider.notifier);
    final mushrooms = ref.watch(shopMushroomsProvider);
    final mushroom = mushrooms.where((m) => m.id == mushroomTypeId).firstOrNull;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Result Visuals
              if (success) ...[
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 8),
                if (mushroom != null)
                  Image.asset(mushroom.spriteAsset, width: 80, height: 80)
                else
                  const Text('🍄', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Harika İş!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.priceText),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Odaklanma seansın başarıyla tamamlandı ve yeni bir mantar yetiştirdin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.tabUnselectedText, height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.coinBadge.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.coinBadgeText),
                      const SizedBox(width: 6),
                      Text(
                        '+$coinsEarned Coin',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coinBadgeText,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                  '🥀',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mantar Çürüdü',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Maalesef seansı tamamlayamadın ve mantarın çürüdü. Bir sonraki seansta görüşmek üzere.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.tabUnselectedText, height: 1.4),
                ),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: notifier.reset,
                style: FilledButton.styleFrom(
                  backgroundColor: success ? AppColors.priceText : AppColors.tabSelectedBg,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tamam',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SetupCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius - 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.tabSelectedBg),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.fieldLabel.copyWith(
                  color: AppColors.taskTitle,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
