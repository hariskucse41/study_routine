import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/study_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../model/topic_model.dart';

class TopicRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TopicRepository(this._firestore, this._auth);

  CollectionReference get _col => _firestore.collection('topics');

  String get _uid => _auth.currentUser!.uid;

  Stream<List<TopicModel>> watchTopicsForSubject(String subjectId) {
    return _col
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(TopicModel.fromFirestore).toList());
  }

  /// One-shot fetch of every topic across a whole plan (all subjects) —
  /// single equality filter, no orderBy, so it's covered by Firestore's
  /// automatic single-field index (no composite index needed). Used by
  /// Progress Analytics for the overall/per-subject aggregates and Weak
  /// Topics.
  Future<List<TopicModel>> fetchTopicsForPlan(String planId) async {
    final snapshot = await _col.where('planId', isEqualTo: planId).get();
    return snapshot.docs.map(TopicModel.fromFirestore).toList();
  }

  /// Fields are accepted individually (not a pre-built TopicModel) so the
  /// owning userId always comes from FirebaseAuth here, never from a
  /// caller-supplied value. planId is resolved from the subject doc rather
  /// than trusted from the caller too.
  Future<void> addTopic({
    required String subjectId,
    String? parentTopicId,
    required String title,
    String? description,
    required String difficulty,
    required int estimatedMinutes,
    required int order,
  }) async {
    final subjectDoc = await _firestore
        .collection('subjects')
        .doc(subjectId)
        .get();
    final planId = subjectDoc.data()?['planId'] as String?;
    if (planId == null) {
      throw StateError('Subject $subjectId not found or missing planId');
    }

    final docRef = _col.doc();
    final topic = TopicModel(
      id: docRef.id,
      userId: _uid,
      planId: planId,
      subjectId: subjectId,
      parentTopicId: parentTopicId,
      title: title,
      description: description,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      order: order,
    );
    await docRef.set(topic.toFirestore());
  }

  /// Updates both the topic doc and its originating study_sessions doc in
  /// one atomic batch — the session captures what happened in that sitting
  /// (completionPercentage/confidenceScore/notes), while the topic's own
  /// fields reflect its overall current standing.
  ///
  /// Also auto-creates the first revision (revisionNumber: 1, due
  /// [defaultRevisionIntervalDays] out) in the same batch, but only when
  /// status is actually transitioning into 'completed' — reading the
  /// topic's current status first avoids spawning a duplicate revision
  /// chain if a topic gets marked completed more than once.
  Future<void> updateTopicProgress({
    required String topicId,
    required String sessionId,
    required int progressPercentage,
    required String status,
    required double confidenceScore,
    String? notes,
  }) async {
    final topicRef = _col.doc(topicId);
    final currentDoc = await topicRef.get();
    final currentData = currentDoc.data() as Map<String, dynamic>?;
    final previousStatus = currentData?['status'] as String?;
    final justCompleted = status == 'completed' && previousStatus != 'completed';

    final batch = _firestore.batch();

    batch.update(topicRef, {
      'progressPercentage': progressPercentage,
      'status': status,
      'confidenceScore': confidenceScore,
      'revisionRequired': status == 'revisionNeeded',
      'updatedAt': FieldValue.serverTimestamp(),
      if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('study_sessions').doc(sessionId), {
      'completionPercentage': progressPercentage,
      'confidenceScore': confidenceScore,
      if (notes != null) 'notes': notes,
    });

    if (justCompleted && currentData != null) {
      final revisionRef = _firestore.collection('revisions').doc();
      batch.set(revisionRef, {
        'userId': _uid,
        'planId': currentData['planId'],
        'subjectId': currentData['subjectId'],
        'topicId': topicId,
        'revisionNumber': 1,
        'scheduledDate': Timestamp.fromDate(
          localMidnight(
            DateTime.now().add(
              const Duration(days: defaultRevisionIntervalDays),
            ),
          ),
        ),
        'status': 'pending',
        'confidenceScore': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Count of topics whose completedAt falls within [start, end) — used by
  /// the Goals checklist's "Topics Completed" item.
  Future<int> countCompletedInRange({
    required String planId,
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _col
        .where('planId', isEqualTo: planId)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('completedAt', isLessThan: Timestamp.fromDate(end))
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
