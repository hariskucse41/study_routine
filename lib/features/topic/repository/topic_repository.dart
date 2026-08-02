import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<void> updateTopicProgress({
    required String topicId,
    required String sessionId,
    required int progressPercentage,
    required String status,
    required double confidenceScore,
    String? notes,
  }) async {
    final batch = _firestore.batch();

    batch.update(_col.doc(topicId), {
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

    await batch.commit();
  }
}
