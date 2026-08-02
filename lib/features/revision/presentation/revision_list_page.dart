import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/revision_bloc.dart';
import '../bloc/revision_event.dart';
import '../bloc/revision_state.dart';
import 'revision_detail_args.dart';
import 'widgets/revision_tile.dart';

class RevisionListPage extends StatelessWidget {
  const RevisionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RevisionBloc>(
      create: (_) =>
          getIt<RevisionBloc>()..add(const WatchDueRevisionsRequested()),
      child: const _RevisionListView(),
    );
  }
}

class _RevisionListView extends StatelessWidget {
  const _RevisionListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Revision List'),
        actions: [
          BlocBuilder<RevisionBloc, RevisionState>(
            builder: (context, state) {
              if (state.revisions.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: state.actionStatus == RevisionActionStatus.submitting
                    ? null
                    : () => context.read<RevisionBloc>().add(
                        const MarkAllCompleteRequested(),
                      ),
                child: const Text('Mark All'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RevisionBloc, RevisionState>(
          listenWhen: (previous, current) =>
              (previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null) ||
              (previous.actionStatus != current.actionStatus &&
                  current.actionStatus == RevisionActionStatus.failure),
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          },
          builder: (context, state) {
            switch (state.status) {
              case RevisionListStatus.initial:
              case RevisionListStatus.loading:
                return const LoadingIndicator();
              case RevisionListStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                );
              case RevisionListStatus.empty:
                return const EmptyStateWidget(
                  message: 'No revisions due — nice work!',
                  icon: Icons.check_circle_outline,
                );
              case RevisionListStatus.success:
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: state.revisions.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final revision = state.revisions[index];
                    final subjectName =
                        state.subjectNames[revision.subjectId] ?? '';
                    final topicName =
                        state.topicNames[revision.topicId] ?? '';
                    return RevisionTile(
                      revision: revision,
                      subjectName: subjectName,
                      topicName: topicName,
                      onTap: () => context.push(
                        AppRoutes.revisionDetail(revision.topicId),
                        extra: RevisionDetailArgs(
                          planId: revision.planId,
                          subjectId: revision.subjectId,
                          subjectName: subjectName,
                          topicName: topicName,
                        ),
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
