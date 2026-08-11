import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/economy_provider.dart';
import '../../theme/app_theme.dart';

/// Bildirim aç/kapa ve varsayılan seans süresi tercihleri. Her değişiklik
/// anında Firestore'a yazılır (ayrı "Kaydet" adımı yok — anahtar/sürgü
/// hemen etkili olur, kullanıcı geri dönünce zaten kayıtlıdır).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider).value;
    final notificationsEnabled = stats?.notificationsEnabled ?? true;
    final defaultMinutes = stats?.defaultSessionMinutes ?? 25;
    final reminderEnabled = stats?.dailyReminderEnabled ?? true;
    final reminderHour = stats?.dailyReminderHour ?? 20;
    final reminderMinute = stats?.dailyReminderMinute ?? 0;

    void save({
      bool? notifications,
      int? minutes,
      bool? reminderOn,
      int? hour,
      int? minute,
    }) {
      ref.read(settingsNotifierProvider.notifier).updateSettings(
            notificationsEnabled: notifications ?? notificationsEnabled,
            defaultSessionMinutes: minutes ?? defaultMinutes,
            dailyReminderEnabled: reminderOn ?? reminderEnabled,
            dailyReminderHour: hour ?? reminderHour,
            dailyReminderMinute: minute ?? reminderMinute,
          );
    }

    Future<void> pickReminderTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: reminderHour, minute: reminderMinute),
      );
      if (picked != null) {
        save(hour: picked.hour, minute: picked.minute);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 1,
        centerTitle: true,
        title: const Text('Ayarlar', style: AppTextStyles.profileName),
      ),
      body: stats == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bildirimler', style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Seans bitiş bildirimi', style: AppTextStyles.taskTitle),
                      subtitle: Text(
                        'Odak seansı bitince "Mantar olgunlaştı" bildirimi gönderilir.',
                        style: AppTextStyles.legend,
                      ),
                      value: notificationsEnabled,
                      activeThumbColor: AppColors.tabSelectedBg,
                      onChanged: (value) => save(notifications: value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Odaklanma', style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Varsayılan seans süresi', style: AppTextStyles.taskTitle),
                            Text('$defaultMinutes dk', style: AppTextStyles.streak),
                          ],
                        ),
                        Text(
                          'Odaklan sekmesi her açıldığında sayaç bu süreyle kurulur.',
                          style: AppTextStyles.legend,
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.tabSelectedBg,
                            inactiveTrackColor: AppColors.progressTrackBg,
                            trackHeight: 6.0,
                            thumbColor: AppColors.tabSelectedBg,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                          ),
                          child: Slider(
                            value: defaultMinutes.toDouble(),
                            min: 15,
                            max: 120,
                            divisions: 21,
                            label: '$defaultMinutes dk',
                            onChanged: (value) => save(minutes: value.round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Seri Hatırlatması', style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Günlük hatırlatma', style: AppTextStyles.taskTitle),
                          subtitle: Text(
                            'O gün henüz odaklanmadıysan serini kaybetmemen için hatırlatılır.',
                            style: AppTextStyles.legend,
                          ),
                          value: reminderEnabled,
                          activeThumbColor: AppColors.tabSelectedBg,
                          onChanged: (value) => save(reminderOn: value),
                        ),
                        if (reminderEnabled)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Hatırlatma saati', style: AppTextStyles.taskTitle),
                            trailing: Text(
                              '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.streak,
                            ),
                            onTap: pickReminderTime,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.statCardRadius - 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
