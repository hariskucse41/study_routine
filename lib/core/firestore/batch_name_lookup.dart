import 'package:cloud_firestore/cloud_firestore.dart';

/// Batched display-name lookup for docs referenced only by id (e.g. a
/// schedule's subjectId/topicId, a revision's subjectId/topicId) — used
/// wherever a list needs to show a human-readable name without denormalizing
/// it onto every referencing document.
///
/// whereIn supports up to 30 values; the lists this is used for (a single
/// day/month of schedules, a topic's revision history) are expected to stay
/// well under that for v1.
Future<Map<String, String>> fetchNamesById(
  FirebaseFirestore firestore, {
  required String collection,
  required String field,
  required Set<String> ids,
}) async {
  if (ids.isEmpty) return {};
  final snapshot = await firestore
      .collection(collection)
      .where(FieldPath.documentId, whereIn: ids.toList())
      .get();
  return {
    for (final doc in snapshot.docs) doc.id: (doc.data())[field] as String? ?? '',
  };
}
