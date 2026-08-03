import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsDataRequested extends SettingsEvent {
  const SettingsDataRequested();
}

class SettingsSaveRequested extends SettingsEvent {
  final int dailyStudyGoalMinutes;
  final String studyStartTime;
  final String studyEndTime;
  final int breakReminderMinutes;
  final String themeMode;
  final String language;

  const SettingsSaveRequested({
    required this.dailyStudyGoalMinutes,
    required this.studyStartTime,
    required this.studyEndTime,
    required this.breakReminderMinutes,
    required this.themeMode,
    required this.language,
  });

  @override
  List<Object?> get props => [
    dailyStudyGoalMinutes,
    studyStartTime,
    studyEndTime,
    breakReminderMinutes,
    themeMode,
    language,
  ];
}
