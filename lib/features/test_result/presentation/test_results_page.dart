import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../subject/bloc/subject_bloc.dart';
import '../../subject/bloc/subject_event.dart';
import '../../subject/bloc/subject_state.dart';
import '../bloc/test_result_bloc.dart';
import '../bloc/test_result_event.dart';
import '../bloc/test_result_state.dart';
import '../model/test_result_model.dart';
import 'widgets/test_result_card.dart';

enum _TimeRange { allTime, thisWeek, thisMonth }

class TestResultsPage extends StatelessWidget {
  const TestResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = context.read<AuthBloc>().state.user?.activeStudyPlanId;
    return MultiBlocProvider(
      providers: [
        BlocProvider<TestResultBloc>(
          create: (_) {
            final bloc = getIt<TestResultBloc>();
            if (planId != null) bloc.add(WatchTestResultsRequested(planId));
            return bloc;
          },
        ),
        BlocProvider<SubjectBloc>(
          create: (_) {
            final bloc = getIt<SubjectBloc>();
            if (planId != null) bloc.add(WatchSubjectsRequested(planId));
            return bloc;
          },
        ),
      ],
      child: const _TestResultsView(),
    );
  }
}

class _TestResultsView extends StatefulWidget {
  const _TestResultsView();

  @override
  State<_TestResultsView> createState() => _TestResultsViewState();
}

class _TestResultsViewState extends State<_TestResultsView> {
  String? _selectedSubjectId;
  _TimeRange _selectedRange = _TimeRange.allTime;

  bool _withinRange(DateTime testDate) {
    if (_selectedRange == _TimeRange.allTime) return true;
    final today = localMidnight(DateTime.now());
    final cutoff = _selectedRange == _TimeRange.thisWeek
        ? today.subtract(Duration(days: today.weekday - 1))
        : DateTime(today.year, today.month, 1);
    return !localMidnight(testDate).isBefore(cutoff);
  }

  List<TestResultModel> _filtered(List<TestResultModel> results) {
    return results
        .where(
          (r) =>
              (_selectedSubjectId == null ||
                  r.subjectId == _selectedSubjectId) &&
              _withinRange(r.testDate),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Test Results')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTestResult),
        icon: const Icon(Icons.add),
        label: const Text('Add Test'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: BlocBuilder<SubjectBloc, SubjectState>(
                      builder: (context, subjectState) {
                        return DropdownButtonFormField<String?>(
                          initialValue: _selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Subjects'),
                            ),
                            ...subjectState.subjects.map(
                              (s) => DropdownMenuItem<String?>(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedSubjectId = value),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<_TimeRange>(
                      initialValue: _selectedRange,
                      decoration: const InputDecoration(labelText: 'Range'),
                      items: const [
                        DropdownMenuItem(
                          value: _TimeRange.allTime,
                          child: Text('All Time'),
                        ),
                        DropdownMenuItem(
                          value: _TimeRange.thisWeek,
                          child: Text('This Week'),
                        ),
                        DropdownMenuItem(
                          value: _TimeRange.thisMonth,
                          child: Text('This Month'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRange = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<TestResultBloc, TestResultState>(
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
                    case TestResultListStatus.initial:
                    case TestResultListStatus.loading:
                      return const LoadingIndicator();
                    case TestResultListStatus.error:
                      return ErrorStateWidget(
                        message: state.errorMessage ?? 'Something went wrong',
                      );
                    case TestResultListStatus.empty:
                      return EmptyStateWidget(
                        message: 'No test results yet',
                        icon: Icons.quiz_outlined,
                        action: TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.addTestResult),
                          child: const Text('+ Add Test'),
                        ),
                      );
                    case TestResultListStatus.success:
                      final filtered = _filtered(state.results);
                      if (filtered.isEmpty) {
                        return const EmptyStateWidget(
                          message: 'No test results match this filter',
                          icon: Icons.filter_alt_off_outlined,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final result = filtered[index];
                          return TestResultCard(
                            result: result,
                            subjectName:
                                state.subjectNames[result.subjectId] ?? '',
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
