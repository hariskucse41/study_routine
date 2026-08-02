import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

const List<String> difficultyChoices = ['easy', 'medium', 'hard'];

String topicStatusLabel(String status) {
  switch (status) {
    case 'inProgress':
      return 'In Progress';
    case 'completed':
      return 'Completed';
    case 'revisionNeeded':
      return 'Revision Needed';
    case 'mastered':
      return 'Mastered';
    case 'notStarted':
    default:
      return 'Not Started';
  }
}

Color topicStatusColor(String status) {
  switch (status) {
    case 'inProgress':
      return AppColors.info;
    case 'completed':
      return AppColors.success;
    case 'revisionNeeded':
      return AppColors.warning;
    case 'mastered':
      return AppColors.primary;
    case 'notStarted':
    default:
      return AppColors.textSecondary;
  }
}
