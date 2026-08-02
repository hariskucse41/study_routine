import 'package:equatable/equatable.dart';

sealed class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoalsRequested extends GoalsEvent {
  const LoadGoalsRequested();
}
