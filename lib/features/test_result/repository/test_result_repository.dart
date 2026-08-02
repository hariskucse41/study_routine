import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firestore/batch_name_lookup.dart';
import '../model/test_result_model.dart';

class TestResultRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TestResultRepository(this._firestore, this._auth);

  CollectionReference get _col => _firestore.collection('test_results');

  String get _uid => _auth.currentUser!.uid;

  /// One broad fetch (userId + planId, newest first) — subject and
  /// time-range filtering happen client-side on the page, avoiding the
  /// need for a composite index per filter combination for what's a
  /// personal-scale collection.
  Stream<List<TestResultModel>> watchTestResults(String planId) {
    return _col
        .where('userId', isEqualTo: _uid)
        .where('planId', isEqualTo: planId)
        .orderBy('testDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map(TestResultModel.fromFirestore).toList());
  }

  Future<void> addTestResult({
    required String planId,
    required String subjectId,
    required String title,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required int skippedAnswers,
    required int durationMinutes,
    required DateTime testDate,
    String? notes,
  }) {
    final docRef = _col.doc();
    final scorePercentage = totalQuestions <= 0
        ? 0.0
        : (correctAnswers / totalQuestions) * 100;
    final result = TestResultModel(
      id: docRef.id,
      userId: _uid,
      planId: planId,
      subjectId: subjectId,
      title: title,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      skippedAnswers: skippedAnswers,
      scorePercentage: scorePercentage,
      durationMinutes: durationMinutes,
      testDate: testDate,
    );
    return docRef.set({...result.toFirestore(), 'notes': notes});
  }

  /// Average scorePercentage per subjectId across test_results since
  /// [since] — used by Progress Analytics to feed low-scoring subjects'
  /// topics into the Weak Topics screen.
  Future<Map<String, double>> fetchAverageScoreBySubject({
    required String planId,
    required DateTime since,
  }) async {
    final snapshot = await _col
        .where('userId', isEqualTo: _uid)
        .where('planId', isEqualTo: planId)
        .where('testDate', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();

    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final subjectId = data['subjectId'] as String?;
      if (subjectId == null) continue;
      final score = (data['scorePercentage'] ?? 0.0).toDouble();
      totals[subjectId] = (totals[subjectId] ?? 0) + score;
      counts[subjectId] = (counts[subjectId] ?? 0) + 1;
    }

    return {
      for (final subjectId in totals.keys)
        subjectId: totals[subjectId]! / counts[subjectId]!,
    };
  }

  Future<Map<String, String>> fetchSubjectNames(Set<String> ids) =>
      fetchNamesById(_firestore, collection: 'subjects', field: 'name', ids: ids);
}
