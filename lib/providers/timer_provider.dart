import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../services/economy_service.dart';
import '../services/notification_service.dart';
import '../services/seed_service.dart';
import 'isar_provider.dart';

enum TimerPhase { idle, running, success, failed }

class TimerState {
  final TimerPhase phase;
  final int targetMinutes;
  final DateTime? startTime;
  final Duration elapsed;
  final int coinsEarned;
  final int? tagId;
  final int? mushroomTypeId;

  const TimerState({
    required this.phase,
    required this.targetMinutes,
    this.startTime,
    this.elapsed = Duration.zero,
    this.coinsEarned = 0,
    this.tagId,
    this.mushroomTypeId,
  });

  factory TimerState.initial() =>
      const TimerState(phase: TimerPhase.idle, targetMinutes: 25);

  double get progress =>
      (elapsed.inMilliseconds / (targetMinutes * 60 * 1000)).clamp(0, 1);

  int get estimatedCoins => EconomyService.estimateCoins(targetMinutes);

  TimerState copyWith({
    TimerPhase? phase,
    int? targetMinutes,
    DateTime? startTime,
    Duration? elapsed,
    int? coinsEarned,
    bool clearTag = false,
    int? tagId,
    int? mushroomTypeId,
  }) {
    return TimerState(
      phase: phase ?? this.phase,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      tagId: clearTag ? null : (tagId ?? this.tagId),
      mushroomTypeId: mushroomTypeId ?? this.mushroomTypeId,
    );
  }
}

/// 10 sn'yi aşan arka plana geçişler seansı geçersiz sayar (bkz. proje dokümanı bölüm 2, 9).
const _pauseTolerance = Duration(seconds: 10);

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;
  DateTime? _pausedAt;
  int? _starterMushroomId;

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return TimerState.initial();
  }

  void setTargetMinutes(int minutes) {
    if (state.phase != TimerPhase.idle) return;
    state = state.copyWith(targetMinutes: minutes);
  }

  void setTag(int? tagId) {
    if (state.phase != TimerPhase.idle) return;
    state = state.copyWith(tagId: tagId, clearTag: tagId == null);
  }

  void setMushroomType(int mushroomTypeId) {
    if (state.phase != TimerPhase.idle) return;
    state = state.copyWith(mushroomTypeId: mushroomTypeId);
  }

  Future<void> start() async {
    if (state.phase == TimerPhase.running) return;

    final isar = await ref.read(isarProvider.future);
    final starter = SeedService.ensureStarterMushroom(isar);
    _starterMushroomId = starter.id;

    final now = DateTime.now();
    state = state.copyWith(
      phase: TimerPhase.running,
      startTime: now,
      elapsed: Duration.zero,
      coinsEarned: 0,
    );

    await NotificationService.instance
        .scheduleSessionEnd(now.add(Duration(minutes: state.targetMinutes)));

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.phase != TimerPhase.running || state.startTime == null) return;
    final elapsed = DateTime.now().difference(state.startTime!);
    if (elapsed >= Duration(minutes: state.targetMinutes)) {
      _finishSuccess();
    } else {
      state = state.copyWith(elapsed: elapsed);
    }
  }

  /// AppLifecycleState.paused yakalandığında çağrılır.
  void onAppPaused() {
    if (state.phase == TimerPhase.running) {
      _pausedAt = DateTime.now();
    }
  }

  /// AppLifecycleState.resumed yakalandığında çağrılır.
  void onAppResumed() {
    if (state.phase != TimerPhase.running || _pausedAt == null) return;
    final awayFor = DateTime.now().difference(_pausedAt!);
    _pausedAt = null;
    if (awayFor > _pauseTolerance) {
      _finishFailed(cancelled: false);
    }
  }

  Future<void> cancelSession() async {
    if (state.phase != TimerPhase.running) return;
    await _finishFailed(cancelled: true);
  }

  Future<void> _finishSuccess() async {
    _ticker?.cancel();
    await NotificationService.instance.cancelSessionEnd();

    final target = state.targetMinutes;
    final coins = EconomyService.estimateCoins(target);
    await _saveSession(
      status: SessionStatus.success,
      coins: coins,
      actualMinutes: target,
    );
    state = state.copyWith(phase: TimerPhase.success, coinsEarned: coins);
  }

  Future<void> _finishFailed({required bool cancelled}) async {
    _ticker?.cancel();
    await NotificationService.instance.cancelSessionEnd();

    final actualMinutes = state.startTime == null
        ? 0
        : DateTime.now().difference(state.startTime!).inMinutes;
    await _saveSession(
      status: cancelled ? SessionStatus.cancelled : SessionStatus.failed,
      coins: 0,
      actualMinutes: actualMinutes,
    );
    state = state.copyWith(phase: TimerPhase.failed, coinsEarned: 0);
  }

  Future<void> _saveSession({
    required SessionStatus status,
    required int coins,
    required int actualMinutes,
  }) async {
    final isar = await ref.read(isarProvider.future);

    final session = Session()
      ..startTime = state.startTime ?? DateTime.now()
      ..targetMinutes = state.targetMinutes
      ..actualMinutes = actualMinutes
      ..status = status
      ..tagId = state.tagId
      ..mushroomTypeId = state.mushroomTypeId ?? _starterMushroomId ?? 0
      ..coinsEarned = coins;

    isar.write((isar) {
      session.id = isar.sessions.autoIncrement();
      isar.sessions.put(session);
    });

    if (status == SessionStatus.success) {
      EconomyService.recordSuccessfulSession(isar, coins: coins);
    }
  }

  /// Sonuç ekranından yeni seansa dönüş.
  void reset() {
    _pausedAt = null;
    final keepMinutes = state.targetMinutes;
    state = TimerState.initial().copyWith(targetMinutes: keepMinutes);
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);
