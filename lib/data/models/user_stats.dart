import 'package:cloud_firestore/cloud_firestore.dart';

/// `users/{uid}` dokümanının kendisi — tek doküman, tek yazımda güncellenir.
class UserStats {
  final String? displayName;
  final String? username;
  final int dailyGoalMinutes;
  final int totalCoins;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSuccessDate;
  final DateTime? lastOpenDate;
  final String? selectedMushroomTypeId;
  final bool notificationsEnabled;
  final int defaultSessionMinutes;
  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool hasSeenOnboarding;
  final String? photoBase64;

  const UserStats({
    this.displayName,
    this.username,
    this.dailyGoalMinutes = 120,
    this.totalCoins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSuccessDate,
    this.lastOpenDate,
    this.selectedMushroomTypeId,
    this.notificationsEnabled = true,
    this.defaultSessionMinutes = 25,
    this.dailyReminderEnabled = true,
    this.dailyReminderHour = 20,
    this.dailyReminderMinute = 0,
    this.hasSeenOnboarding = false,
    this.photoBase64,
  });

  factory UserStats.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return const UserStats();
    return UserStats(
      displayName: data['displayName'] as String?,
      username: data['username'] as String?,
      dailyGoalMinutes: data['dailyGoalMinutes'] as int? ?? 120,
      totalCoins: data['totalCoins'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      lastSuccessDate: (data['lastSuccessDate'] as Timestamp?)?.toDate(),
      lastOpenDate: (data['lastOpenDate'] as Timestamp?)?.toDate(),
      selectedMushroomTypeId: data['selectedMushroomTypeId'] as String?,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      defaultSessionMinutes: data['defaultSessionMinutes'] as int? ?? 25,
      dailyReminderEnabled: data['dailyReminderEnabled'] as bool? ?? true,
      dailyReminderHour: data['dailyReminderHour'] as int? ?? 20,
      dailyReminderMinute: data['dailyReminderMinute'] as int? ?? 0,
      hasSeenOnboarding: data['hasSeenOnboarding'] as bool? ?? false,
      photoBase64: data['photoBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'username': username,
        'dailyGoalMinutes': dailyGoalMinutes,
        'totalCoins': totalCoins,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastSuccessDate': lastSuccessDate == null ? null : Timestamp.fromDate(lastSuccessDate!),
        'lastOpenDate': lastOpenDate == null ? null : Timestamp.fromDate(lastOpenDate!),
        'selectedMushroomTypeId': selectedMushroomTypeId,
        'notificationsEnabled': notificationsEnabled,
        'defaultSessionMinutes': defaultSessionMinutes,
        'dailyReminderEnabled': dailyReminderEnabled,
        'dailyReminderHour': dailyReminderHour,
        'dailyReminderMinute': dailyReminderMinute,
        'hasSeenOnboarding': hasSeenOnboarding,
        'photoBase64': photoBase64,
      };

  UserStats copyWith({
    String? displayName,
    String? username,
    int? dailyGoalMinutes,
    int? totalCoins,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSuccessDate,
    DateTime? lastOpenDate,
    String? selectedMushroomTypeId,
    bool? notificationsEnabled,
    int? defaultSessionMinutes,
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? hasSeenOnboarding,
    String? photoBase64,
  }) {
    return UserStats(
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      totalCoins: totalCoins ?? this.totalCoins,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSuccessDate: lastSuccessDate ?? this.lastSuccessDate,
      lastOpenDate: lastOpenDate ?? this.lastOpenDate,
      selectedMushroomTypeId: selectedMushroomTypeId ?? this.selectedMushroomTypeId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultSessionMinutes: defaultSessionMinutes ?? this.defaultSessionMinutes,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}
