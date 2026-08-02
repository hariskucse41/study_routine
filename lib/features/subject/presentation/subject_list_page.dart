import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/navigation/nav_actions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';
import 'widgets/add_subject_sheet.dart';
import 'widgets/subject_card.dart';

class SubjectListPage extends StatelessWidget {
  const SubjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = context.read<AuthBloc>().state.user?.activeStudyPlanId;
    return BlocProvider<SubjectBloc>(
      create: (_) {
        final bloc = getIt<SubjectBloc>();
        if (planId != null) {
          bloc.add(WatchSubjectsRequested(planId));
        }
        return bloc;
      },
      child: const _SubjectListView(),
    );
  }
}

class _SubjectListView extends StatelessWidget {
  const _SubjectListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddSubjectSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<SubjectBloc, SubjectState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          },
          builder: (context, state) {
            switch (state.status) {
              case SubjectStatus.initial:
              case SubjectStatus.loading:
                return const LoadingIndicator();
              case SubjectStatus.error:
                return ErrorStateWidget(
                  message: state.errorMessage ?? 'Something went wrong',
                );
              case SubjectStatus.empty:
                return EmptyStateWidget(
                  message: 'No subjects yet',
                  icon: Icons.menu_book_outlined,
                  action: TextButton(
                    onPressed: () => showAddSubjectSheet(context),
                    child: const Text('+ Add Subject'),
                  ),
                );
              case SubjectStatus.success:
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: state.subjects.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final subject = state.subjects[index];
                    return SubjectCard(
                      subject: subject,
                      onTap: () =>
                          context.push(AppRoutes.subjectDetail(subject.id)),
                    );
                  },
                );
            }
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavTab.plan,
        onTap: (tab) => handleBottomNavTap(context, tab, AppNavTab.plan),
      ),
    );
  }
}
