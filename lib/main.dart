import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/isar_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MantarOdakApp()));
}

class MantarOdakApp extends ConsumerWidget {
  const MantarOdakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isar = ref.watch(isarProvider);
    final notifications = ref.watch(notificationInitProvider);
    final error = isar.error ?? notifications.error;

    return MaterialApp(
      title: 'Mantar Odak',
      theme: buildAppTheme(),
      home: error != null
          ? Scaffold(body: Center(child: Text('Hata: $error')))
          : (isar.hasValue && notifications.hasValue)
              ? const RootShell()
              : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
