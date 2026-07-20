import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/session.dart';
import '../data/mushroom_catalog.dart';
import '../data/session_repository.dart';
import '../data/user_repository.dart';
import '../services/economy_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';
import 'economy_provider.dart';

enum TimerPhase { idle, running, success, failed }

class TimerState {
  final TimerPhase phase;
  final int targetMinutes;
  final DateTime? startTime;
  final Duration elapsed;
  final int coinsEarned;
  final String? tagId;
  final String? mushroomTypeId;

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
    String? tagId,
    String? mushroomTypeId,
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
  bool _appliedDefaultFromSettings = false;

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return TimerState.initial();
  }

  /// Ayarlar ekranındaki "varsayılan seans süresi" ilk açılışta bir kez
  /// uygulanır (bkz. _SetupView.build). Kullanıcı seansı bitirip [reset]
  /// çağırdığında son kullanılan süre korunur — ayar tekrar dayatılmaz.
  void applyDefaultMinutesFromSettings(int minutes) {
    if (_appliedDefaultFromSettings || state.phase != TimerPhase.idle) return;
    _appliedDefaultFromSettings = true;
    state = state.copyWith(targetMinutes: minutes);
  }

  void setTargetMinutes(int minutes) {
    if (state.phase != TimerPhase.idle) return;
    state = state.copyWith(targetMinutes: minutes);
  }

  void setTag(String? tagId) {
    if (state.phase != TimerPhase.idle) return;
    state = state.copyWith(tagId: tagId, clearTag: tagId == null);
  }

  void setMushroomType(String mushroomTypeId) {
    if (state.phase != TimerPhase.idle) return;
    state = state.copyWith(mushroomTypeId: mushroomTypeId);
  }

  Future<void> start() async {
    if (state.phase == TimerPhase.running) return;

    final now = DateTime.now();
    state = state.copyWith(
      phase: TimerPhase.running,
      startTime: now,
      elapsed: Duration.zero,
      coinsEarned: 0,
    );

    final notificationsEnabled = ref.read(userStatsProvider).value?.notificationsEnabled ?? true;
    if (notificationsEnabled) {
      await NotificationService.instance
          .scheduleSessionEnd(now.add(Duration(minutes: state.targetMinutes)));
    }

    // Çalışan seansın izini Firestore'a bırak: uygulama seans ortasında
    // ölürse açılışta recoverAbandonedSession bunu bulup başarısız sayar.
    // await YOK — çevrimdışıyken sunucu onayı beklenirse sayaç başlamaz;
    // yazma zaten yerel önbelleğe anında işlenir.
    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      unawaited(SessionRepository().setActiveSession(uid, _sessionFromState(
        status: SessionStatus.failed,
        coins: 0,
        actualMinutes: 0,
      )));
    }

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

  Session _sessionFromState({
    required SessionStatus status,
    required int coins,
    required int actualMinutes,
  }) {
    return Session(
      id: '',
      startTime: state.startTime ?? DateTime.now(),
      targetMinutes: state.targetMinutes,
      actualMinutes: actualMinutes,
      status: status,
      tagId: state.tagId,
      mushroomTypeId: state.mushroomTypeId ?? MushroomCatalog.starterId,
      coinsEarned: coins,
    );
  }

  Future<void> _saveSession({
    required SessionStatus status,
    required int coins,
    required int actualMinutes,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final session = _sessionFromState(
      status: status,
      coins: coins,
      actualMinutes: actualMinutes,
    );

    await SessionRepository().addSession(uid, session);
    // Seans sonuçlandı — açılışta kurtarılacak iz kalmasın.
    unawaited(SessionRepository().clearActiveSession(uid));

    if (status == SessionStatus.success) {
      await UserRepository().recordSuccessfulSession(uid, coins: coins);
    }
    // Firestore .snapshots() akışları zaten canlı — elle invalidate gerekmez.
  }

  /// Uygulama açılışında çağrılır. Önceki çalıştırmada seans ortasında
  /// kapanılmışsa (activeSession izi duruyorsa) o seansı başarısız olarak
  /// tarihe işler. Kural gereği: 10 sn'den uzun her kopuş başarısızlıktır;
  /// uygulamanın ölmesi de bir kopuştur.
  Future<void> recoverAbandonedSession() async {
    if (state.phase != TimerPhase.idle) return;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final abandoned = await SessionRepository().getActiveSession(uid);
    if (abandoned == null) return;

    var actualMinutes = DateTime.now().difference(abandoned.startTime).inMinutes;
    if (actualMinutes > abandoned.targetMinutes) {
      actualMinutes = abandoned.targetMinutes;
    }
    if (actualMinutes < 0) actualMinutes = 0; // cihaz saati geri alınmışsa

    await SessionRepository().addSession(
      uid,
      Session(
        id: '',
        startTime: abandoned.startTime,
        targetMinutes: abandoned.targetMinutes,
        actualMinutes: actualMinutes,
        status: SessionStatus.failed,
        tagId: abandoned.tagId,
        mushroomTypeId: abandoned.mushroomTypeId,
        coinsEarned: 0,
      ),
    );
    await SessionRepository().clearActiveSession(uid);
  }

  /// Sonuç ekranından yeni seansa dönüş.
  void reset() {
    _pausedAt = null;
    final keepMinutes = state.targetMinutes;
    state = TimerState.initial().copyWith(targetMinutes: keepMinutes);
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);
