import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, error }

enum SettingsSaveStatus { idle, saving, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final int dailyStudyGoalMinutes;
  final String studyStartTime;
  final String studyEndTime;
  final int breakReminderMinutes;
  final String themeMode;
  final String language;
  final SettingsSaveStatus saveStatus;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.dailyStudyGoalMinutes = 120,
    this.studyStartTime = '08:00',
    this.studyEndTime = '22:00',
    this.breakReminderMinutes = 60,
    this.themeMode = 'system',
    this.language = 'en',
    this.saveStatus = SettingsSaveStatus.idle,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    int? dailyStudyGoalMinutes,
    String? studyStartTime,
    String? studyEndTime,
    int? breakReminderMinutes,
    String? themeMode,
    String? language,
    SettingsSaveStatus? saveStatus,
    String? errorMessage,
    bool clearError = false,
  }) => SettingsState(
    status: status ?? this.status,
    dailyStudyGoalMinutes:
        dailyStudyGoalMinutes ?? this.dailyStudyGoalMinutes,
    studyStartTime: studyStartTime ?? this.studyStartTime,
    studyEndTime: studyEndTime ?? this.studyEndTime,
    breakReminderMinutes: breakReminderMinutes ?? this.breakReminderMinutes,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    saveStatus: saveStatus ?? this.saveStatus,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    status,
    dailyStudyGoalMinutes,
    studyStartTime,
    studyEndTime,
    breakReminderMinutes,
    themeMode,
    language,
    saveStatus,
    errorMessage,
  ];
}
