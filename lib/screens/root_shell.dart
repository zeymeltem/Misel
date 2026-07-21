import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/timer_provider.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'timer/timer_screen.dart';

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;

  static const _screens = [HomeScreen(), TimerScreen(), ProfileScreen()];
  static const _timerTabIndex = 1;

  void _onDestinationSelected(int i, bool sessionRunning) {
    if (sessionRunning && i != _timerTabIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seans sürerken diğer sekmelere geçemezsin.')),
      );
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final sessionRunning = ref.watch(timerProvider.select((s) => s.phase)) == TimerPhase.running;

    return Scaffold(
      // IndexedStack: sekmeler arası geçişte ekranlar dispose edilmez. Bu şart,
      // çünkü TimerScreen'deki WidgetsBindingObserver seans sırasında başka
      // sekmedeyken de yaşamalı — yoksa "10 sn arka plan = başarısız" kuralı
      // sadece Odaklan sekmesi açıkken işler.
      body: SafeArea(child: IndexedStack(index: _index, children: _screens)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => _onDestinationSelected(i, sessionRunning),
          backgroundColor: AppColors.cardBackground,
          indicatorColor: AppColors.gardenBackground,
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.gardenBannerText),
              label: 'Bahçe',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer, color: AppColors.gardenBannerText),
              label: 'Odaklan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.gardenBannerText),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
