import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/study_constants.dart';
import '../../../core/firestore/batch_name_lookup.dart';
import '../../../core/utils/date_utils.dart';
import '../model/revision_model.dart';

class RevisionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RevisionRepository(this._firestore, this._auth);

  CollectionReference get _col => _firestore.collection('revisions');

  String get _uid => _auth.currentUser!.uid;

  /// Due = pending and scheduled today or earlier.
  Stream<List<RevisionModel>> watchDueRevisions() {
    final today = todayRange();
    return _col
        .where('userId', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .where('scheduledDate', isLessThan: today.endTimestamp)
        .snapshots()
        .map((s) {
          final list = s.docs.map(RevisionModel.fromFirestore).toList();
          list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          return list;
        });
  }

  Stream<List<RevisionModel>> watchRevisionHistory(String topicId) {
    return _col
        .where('topicId', isEqualTo: topicId)
        .orderBy('revisionNumber')
        .snapshots()
        .map((s) => s.docs.map(RevisionModel.fromFirestore).toList());
  }

  Future<void> markAllComplete(List<String> revisionIds) async {
    final batch = _firestore.batch();
    for (final id in revisionIds) {
      batch.update(_col.doc(id), {
        'status': 'completed',
        'completedDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Keeps status as 'pending' (not the literal 'rescheduled' string) so
  /// the item still shows up as due on its new date — see revision_repository
  /// design note in the Phase 7 summary.
  Future<void> reschedule({
    required String revisionId,
    required DateTime newDate,
  }) {
    return _col.doc(revisionId).update({
      'scheduledDate': Timestamp.fromDate(newDate),
      'status': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> logNextRevision({
    required String planId,
    required String subjectId,
    required String topicId,
    required int revisionNumber,
  }) {
    final docRef = _col.doc();
    final revision = RevisionModel(
      id: docRef.id,
      userId: _uid,
      planId: planId,
      subjectId: subjectId,
      topicId: topicId,
      revisionNumber: revisionNumber,
      scheduledDate: localMidnight(
        DateTime.now().add(const Duration(days: defaultRevisionIntervalDays)),
      ),
    );
    return docRef.set(revision.toFirestore());
  }

  /// Count of revisions completed within [start, end) — used by the Goals
  /// checklist's "Revisions Done" item.
  Future<int> countCompletedInRange({
    required String planId,
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _col
        .where('planId', isEqualTo: planId)
        .where('status', isEqualTo: 'completed')
        .where(
          'completedDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where('completedDate', isLessThan: Timestamp.fromDate(end))
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<Map<String, String>> fetchSubjectNames(Set<String> ids) =>
      fetchNamesById(_firestore, collection: 'subjects', field: 'name', ids: ids);

  Future<Map<String, String>> fetchTopicNames(Set<String> ids) =>
      fetchNamesById(_firestore, collection: 'topics', field: 'title', ids: ids);
}
