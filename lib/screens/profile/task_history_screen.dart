import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/percent_ring.dart';
import '../../widgets/pixel_number.dart';
import 'day_detail_screen.dart';

const _weekdayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık', //
];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatHistoryDay(DateTime date) {
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  if (_isSameDay(date, today)) return 'Bugün';
  if (_isSameDay(date, yesterday)) return 'Dün';
  return '${date.day} ${_monthNames[date.month - 1]}, ${_weekdayNames[date.weekday - 1]}';
}

enum _Range { daily, weekly, monthly }

class _HistoryRow {
  final String label;
  final int completed;
  final int total;
  final DateTime? date;

  const _HistoryRow({required this.label, required this.completed, required this.total, this.date});

  double get percent => total == 0 ? 0.0 : completed / total * 100;
}

/// Geçmiş günlerin/haftaların/ayların görev tamamlanma oranları. Sadece
/// günlük sekmedeki öğeler [DayDetailScreen]'e açılır.
class TaskHistoryScreen extends ConsumerStatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  ConsumerState<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends ConsumerState<TaskHistoryScreen> {
  _Range _range = _Range.daily;
  int _visibleDaily = 10;
  int _visibleMonthly = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Görev Geçmişi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding, 18, AppSizes.screenPadding, 0),
            child: _RangeTabs(range: _range, onChanged: (r) => setState(() => _range = r)),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    switch (_range) {
      case _Range.daily:
        final all = ref.watch(dailyTaskHistoryProvider);
        final rows = all
            .map((d) => _HistoryRow(
                  label: formatHistoryDay(d.date),
                  completed: d.completedCount,
                  total: d.totalCount,
                  date: d.date,
                ))
            .toList();
        return _buildRangeList(rows, _visibleDaily, () => setState(() => _visibleDaily += 10));

      case _Range.weekly:
        final all = ref.watch(weeklyTaskHistoryProvider);
        final rows = all
            .map((w) => _HistoryRow(
                  label: w.weeksAgo == 0
                      ? 'Bu Hafta'
                      : w.weeksAgo == 1
                          ? 'Geçen Hafta'
                          : '${w.weeksAgo} Hafta Önce',
                  completed: w.completedCount,
                  total: w.totalCount,
                ))
            .toList();
        return _buildRangeList(rows, rows.length, null);

      case _Range.monthly:
        final all = ref.watch(monthlyTaskHistoryProvider);
        final currentYear = DateTime.now().year;
        final rows = all
            .map((m) => _HistoryRow(
                  label: m.year == currentYear
                      ? _monthNames[m.month - 1]
                      : '${_monthNames[m.month - 1]} ${m.year}',
                  completed: m.completedCount,
                  total: m.totalCount,
                ))
            .toList();
        return _buildRangeList(rows, _visibleMonthly, () => setState(() => _visibleMonthly += 6));
    }
  }

  Widget _buildRangeList(List<_HistoryRow> rows, int visibleCount, VoidCallback? onLoadMore) {
    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Henüz geçmiş görev kaydı yok.',
            style: TextStyle(color: AppColors.tabUnselectedText),
          ),
        ),
      );
    }

    final visible = rows.take(visibleCount).toList();
    final hasMore = onLoadMore != null && visibleCount < rows.length;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      children: [
        for (final row in visible) ...[
          _HistoryTile(row: row),
          const SizedBox(height: 10),
        ],
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: OutlinedButton(
              onPressed: onLoadMore,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.streakText,
                side: BorderSide.none,
                backgroundColor: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.statCardRadius - 2),
                ),
              ),
              child: const Text('Daha Fazla Yükle', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

class _RangeTabs extends StatelessWidget {
  final _Range range;
  final ValueChanged<_Range> onChanged;
  const _RangeTabs({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = {_Range.daily: 'Günlük', _Range.weekly: 'Haftalık', _Range.monthly: 'Aylık'};
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.statCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final entry in labels.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: range == entry.key ? AppColors.cardBackground : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.5,
                      color: range == entry.key ? AppColors.streakText : AppColors.tabUnselectedText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _HistoryRow row;
  const _HistoryTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
        onTap: row.date == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DayDetailScreen(date: row.date!)),
                ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.statCardRadius),
            border: Border.all(color: AppColors.chipUnselectedBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              PercentRing(
                size: 52,
                percent: row.percent,
                centerText: '%${row.percent.round()}',
                centerFontSize: 8,
                strokeWidth: 6,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NumberText(row.label, style: AppTextStyles.taskTitle.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    NumberText('${row.completed} / ${row.total} görev', style: AppTextStyles.statLabel),
                  ],
                ),
              ),
              if (row.date != null)
                const Icon(Icons.chevron_right_rounded, color: AppColors.tabUnselectedText),
            ],
          ),
        ),
      ),
    );
  }
}
