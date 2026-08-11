import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/economy_provider.dart';
import '../../theme/app_theme.dart';
import '../root_shell.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String body;

  const _OnboardingPage({required this.emoji, required this.title, required this.body});
}

const _pages = [
  _OnboardingPage(
    emoji: '🍄',
    title: 'Odaklan, Mantarını Büyüt',
    body: 'Bir süre seç ve seansı başlat. Seansı bitirmeden telefondan '
        '10 saniyeden uzun uzaklaşırsan mantarın çürür; bitirirsen '
        'bahçende büyür.',
  ),
  _OnboardingPage(
    emoji: '🛒',
    title: 'Coin Kazan, Mağazadan Al',
    body: 'Her başarılı seans coin kazandırır. Coin biriktirip mağazadan '
        'daha nadir mantar türleri satın alabilirsin.',
  ),
  _OnboardingPage(
    emoji: '🔥',
    title: 'Serini Koru',
    body: 'Her gün en az bir seans tamamlayarak serini büyüt. Unutmaman '
        'için günlük hatırlatma bildirimini açık tutabilirsin — '
        'istersen Ayarlar\'dan değiştirirsin.',
  ),
];

/// Hesap ilk kez açıldığında bir kez gösterilen 3 sayfalık tanıtım.
/// "Başla"ya (ya da "Atla"ya) basınca `hasSeenOnboarding` Firestore'a
/// yazılır, bir daha gösterilmez (bkz. main.dart'taki dallanma).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingNotifierProvider.notifier).markSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootShell()),
    );
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Atla', style: AppTextStyles.legend),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(page.emoji, style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.legend,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.tabSelectedBg : AppColors.progressTrackBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tabSelectedBg,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                ),
                child: Text(isLast ? 'Başla' : 'İleri'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
