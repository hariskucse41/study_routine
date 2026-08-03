import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/model/app_user_model.dart';
import '../../auth/repository/auth_repository.dart';
import '../../notification/model/notification_preferences_model.dart';
import '../../notification/repository/notification_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AuthRepository _authRepository;
  final NotificationRepository _notificationRepository;

  // Kept so a save can preserve fields (name/email/photoUrl/timezone/...)
  // this bloc never edits itself.
  AppUserModel? _user;
  NotificationPreferencesModel? _preferences;

  SettingsBloc(this._authRepository, this._notificationRepository)
    : super(const SettingsState()) {
    on<SettingsDataRequested>(_onDataRequested);
    on<SettingsSaveRequested>(_onSaveRequested);
  }

  Future<void> _onDataRequested(
    SettingsDataRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final firebaseUser = _authRepository.currentUser;
      if (firebaseUser == null) {
        emit(
          state.copyWith(
            status: SettingsStatus.error,
            errorMessage: 'Not signed in',
          ),
        );
        return;
      }
      final user =
          await _authRepository.fetchUserProfile(firebaseUser.uid) ??
          AppUserModel.fromFirebaseUser(firebaseUser);
      final preferences = await _notificationRepository.fetchPreferences();
      _user = user;
      _preferences = preferences;
      emit(
        state.copyWith(
          status: SettingsStatus.success,
          dailyStudyGoalMinutes: user.dailyStudyGoalMinutes,
          studyStartTime: user.studyStartTime,
          studyEndTime: user.studyEndTime,
          breakReminderMinutes: preferences.breakReminderMinutes,
          themeMode: user.themeMode,
          language: user.language,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaveRequested(
    SettingsSaveRequested event,
    Emitter<SettingsState> emit,
  ) async {
    final user = _user;
    final preferences = _preferences;
    if (user == null || preferences == null) return;

    emit(
      state.copyWith(saveStatus: SettingsSaveStatus.saving, clearError: true),
    );
    try {
      final updatedUser = user.copyWith(
        dailyStudyGoalMinutes: event.dailyStudyGoalMinutes,
        studyStartTime: event.studyStartTime,
        studyEndTime: event.studyEndTime,
        themeMode: event.themeMode,
        language: event.language,
      );
      final updatedPreferences = preferences.copyWith(
        breakReminderMinutes: event.breakReminderMinutes,
      );
      await _authRepository.updateUserProfile(updatedUser);
      await _notificationRepository.savePreferences(updatedPreferences);
      _user = updatedUser;
      _preferences = updatedPreferences;
      emit(
        state.copyWith(
          saveStatus: SettingsSaveStatus.success,
          dailyStudyGoalMinutes: event.dailyStudyGoalMinutes,
          studyStartTime: event.studyStartTime,
          studyEndTime: event.studyEndTime,
          breakReminderMinutes: event.breakReminderMinutes,
          themeMode: event.themeMode,
          language: event.language,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: SettingsSaveStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
