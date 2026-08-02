import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repo;

  DashboardBloc(this._repo) : super(const DashboardState()) {
    on<LoadDashboardRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    LoadDashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final summary = await _repo.loadDashboard();
      if (summary == null) {
        emit(state.copyWith(status: DashboardStatus.noPlan));
        return;
      }
      emit(state.copyWith(status: DashboardStatus.success, summary: summary));
    } catch (e) {
      emit(
        state.copyWith(status: DashboardStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
