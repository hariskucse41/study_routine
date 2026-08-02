import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/study_session_bloc.dart';
import '../bloc/study_session_event.dart';
import '../bloc/study_session_state.dart';
import 'session_start_args.dart';

class SessionTimerPage extends StatelessWidget {
  final SessionStartArgs args;

  const SessionTimerPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StudySessionBloc>.value(
      value: getIt<StudySessionBloc>(),
      child: _SessionTimerView(args: args),
    );
  }
}

class _SessionTimerView extends StatefulWidget {
  final SessionStartArgs args;

  const _SessionTimerView({required this.args});

  @override
  State<_SessionTimerView> createState() => _SessionTimerViewState();
}

class _SessionTimerViewState extends State<_SessionTimerView> {
  Timer? _ticker;
  late int _remainingSeconds = widget.args.plannedMinutes * 60;

  @override
  void initState() {
    super.initState();
    context.read<StudySessionBloc>().add(
      StartSessionRequested(
        planId: widget.args.planId,
        subjectId: widget.args.subjectId,
        topicId: widget.args.topicId,
        subjectName: widget.args.subjectName,
        topicName: widget.args.topicName,
        scheduleId: widget.args.scheduleId,
        plannedMinutes: widget.args.plannedMinutes,
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String get _formattedRemaining {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: BlocConsumer<StudySessionBloc, StudySessionState>(
          listenWhen: (previous, current) => previous.phase != current.phase,
          listener: (context, state) {
            if (state.phase == StudySessionPhase.active) {
              _startTicker();
            } else if (state.phase == StudySessionPhase.paused) {
              _stopTicker();
            } else if (state.phase == StudySessionPhase.completed) {
              _stopTicker();
              context.go(AppRoutes.sessionComplete);
            }
          },
          builder: (context, state) {
            if (state.phase == StudySessionPhase.error) {
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Could not start session',
                onRetry: () => context.pop(),
              );
            }
            if (state.phase == StudySessionPhase.idle ||
                state.phase == StudySessionPhase.starting) {
              return const LoadingIndicator();
            }

            final totalSeconds = widget.args.plannedMinutes * 60;
            final ratio = totalSeconds == 0
                ? 0.0
                : (_remainingSeconds / totalSeconds).clamp(0.0, 1.0);
            final isPaused = state.phase == StudySessionPhase.paused;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      widget.args.topicName,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${widget.args.subjectName} • ${widget.args.topicName}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 10,
                          backgroundColor: AppColors.textOnPrimary.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryLight,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formattedRemaining,
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: 40,
                            ),
                          ),
                          Text(
                            isPaused ? 'Paused' : 'Focus Time',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textOnPrimary,
                        side: BorderSide(
                          color: AppColors.textOnPrimary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () => context.read<StudySessionBloc>().add(
                        const PauseSessionRequested(),
                      ),
                      icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(isPaused ? 'Resume' : 'Pause'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onPressed: () => context.read<StudySessionBloc>().add(
                        const EndSessionRequested(),
                      ),
                      icon: const Icon(Icons.stop),
                      label: const Text('End Session'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
