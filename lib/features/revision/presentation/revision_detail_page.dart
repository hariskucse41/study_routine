import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/revision_bloc.dart';
import '../bloc/revision_event.dart';
import '../bloc/revision_state.dart';
import '../model/revision_model.dart';
import 'revision_detail_args.dart';
import 'widgets/revision_visuals.dart';

class RevisionDetailPage extends StatelessWidget {
  final String topicId;
  final RevisionDetailArgs args;

  const RevisionDetailPage({
    super.key,
    required this.topicId,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RevisionBloc>(
      create: (_) => getIt<RevisionBloc>()
        ..add(
          WatchRevisionHistoryRequested(
            planId: args.planId,
            subjectId: args.subjectId,
            topicId: topicId,
          ),
        ),
      child: _RevisionDetailView(args: args),
    );
  }
}

class _RevisionDetailView extends StatelessWidget {
  final RevisionDetailArgs args;

  const _RevisionDetailView({required this.args});

  Future<void> _reschedule(BuildContext context, RevisionModel pending) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: pending.scheduledDate.isAfter(DateTime.now())
          ? pending.scheduledDate
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;
    context.read<RevisionBloc>().add(
      RescheduleRevisionRequested(
        revisionId: pending.id,
        newDate: localMidnight(picked),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(args.topicName)),
      body: SafeArea(
        child: BlocConsumer<RevisionBloc, RevisionState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
          builder: (context, state) {
            if (state.status == RevisionListStatus.loading ||
                state.status == RevisionListStatus.initial) {
              return const LoadingIndicator();
            }
            if (state.status == RevisionListStatus.error) {
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Something went wrong',
              );
            }

            final revisions = [...state.revisions]
              ..sort((a, b) => a.revisionNumber.compareTo(b.revisionNumber));
            final pending = revisions
                .where((r) => r.status == 'pending')
                .toList();
            final currentPending = pending.isEmpty ? null : pending.last;
            final isBusy = state.actionStatus == RevisionActionStatus.submitting;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Text(
                    args.subjectName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: revisions.isEmpty
                      ? const EmptyStateWidget(
                          message: 'No revision history yet',
                          icon: Icons.history,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          itemCount: revisions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final revision = revisions[index];
                            final color = revisionStatusColor(revision.status);
                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Revision #${revision.revisionNumber}',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          formatFriendlyDate(
                                            revision.scheduledDate,
                                          ),
                                          style: AppTextStyles.caption
                                              .copyWith(
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull,
                                      ),
                                    ),
                                    child: Text(
                                      revisionStatusLabel(revision.status),
                                      style: AppTextStyles.caption.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Reschedule',
                          isOutlined: true,
                          onPressed: (isBusy || currentPending == null)
                              ? null
                              : () => _reschedule(context, currentPending),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Log Next Revision',
                          onPressed: (isBusy || currentPending != null)
                              ? null
                              : () => context.read<RevisionBloc>().add(
                                  const LogNextRevisionRequested(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
