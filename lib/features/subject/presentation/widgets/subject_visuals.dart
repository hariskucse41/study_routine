import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Preset icon/color choices for subjects, stored as short string keys on
/// the Firestore doc (see SubjectModel.icon / .color) and resolved back to
/// Flutter types here for rendering.
const Map<String, IconData> subjectIconChoices = {
  'book': Icons.menu_book_outlined,
  'calculator': Icons.calculate_outlined,
  'language': Icons.language_outlined,
  'science': Icons.science_outlined,
  'flag': Icons.flag_outlined,
  'public': Icons.public_outlined,
};

const List<String> subjectColorChoices = [
  '5B3FD6',
  '2563EB',
  '16A34A',
  'EA580C',
  'DB2777',
  '0891B2',
];

IconData subjectIconFor(String key) =>
    subjectIconChoices[key] ?? Icons.menu_book_outlined;

Color subjectColorFor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final parsed = int.tryParse('FF$normalized', radix: 16);
  return parsed == null ? AppColors.primary : Color(parsed);
}
