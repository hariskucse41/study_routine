import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only reference doc describing one pre-built syllabus (e.g. "BCS
/// Preparation"). Templates are seeded manually (Firebase console or a
/// one-off admin script) — the app never writes to this collection, only
/// reads from it.
class SyllabusTemplateModel {
  final String id;
  final String name;
  final String? examName;
  final String? description;

  const SyllabusTemplateModel({
    required this.id,
    required this.name,
    this.examName,
    this.description,
  });

  factory SyllabusTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SyllabusTemplateModel(
      id: doc.id,
      name: d['name'] ?? '',
      examName: d['examName'],
      description: d['description'],
    );
  }
}
