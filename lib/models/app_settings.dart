import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// Single app-wide settings record.
@HiveType(typeId: 4)
class AppSettings {
  @HiveField(0)
  bool onboardingDone;

  @HiveField(1)
  bool reminderEnabled;

  /// Local time.
  @HiveField(2)
  int reminderHour;

  @HiveField(3)
  int reminderMinute;

  /// Optional, printed on the doctor report.
  @HiveField(4)
  String? patientName;

  /// Opt-in consent: the user has agreed that aggregated data may be sent to
  /// the DeepSeek analysis service (via the Firebase proxy). Off by default.
  @HiveField(5)
  bool aiEnabled;

  AppSettings({
    this.onboardingDone = false,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.patientName,
    this.aiEnabled = false,
  });

  AppSettings copyWith({
    bool? onboardingDone,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? patientName,
    bool clearPatientName = false,
    bool? aiEnabled,
  }) {
    return AppSettings(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      patientName: clearPatientName ? null : (patientName ?? this.patientName),
      aiEnabled: aiEnabled ?? this.aiEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingDone': onboardingDone,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'patientName': patientName,
        'aiEnabled': aiEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        onboardingDone: json['onboardingDone'] as bool? ?? false,
        reminderEnabled: json['reminderEnabled'] as bool? ?? false,
        reminderHour: json['reminderHour'] as int? ?? 20,
        reminderMinute: json['reminderMinute'] as int? ?? 0,
        patientName: json['patientName'] as String?,
        aiEnabled: json['aiEnabled'] as bool? ?? false,
      );
}
