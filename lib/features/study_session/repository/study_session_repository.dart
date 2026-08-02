import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/date_utils.dart';
import '../model/study_session_model.dart';

class StudySessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StudySessionRepository(this._firestore, this._auth);

  CollectionReference get _col => _firestore.collection('study_sessions');

  String get _uid => _auth.currentUser!.uid;

  /// Creates the session doc with a client-observed startedAt (needed
  /// immediately for local elapsed-time tracking, unlike createdAt/
  /// updatedAt bookkeeping fields which use serverTimestamp()).
  Future<String> startSession({
    required String planId,
    required String subjectId,
    required String topicId,
    String? scheduleId,
    required int plannedMinutes,
  }) async {
    final docRef = _col.doc();
    final session = StudySessionModel(
      id: docRef.id,
      userId: _uid,
      planId: planId,
      scheduleId: scheduleId,
      subjectId: subjectId,
      topicId: topicId,
      startedAt: DateTime.now(),
      plannedMinutes: plannedMinutes,
    );
    await docRef.set(session.toFirestore());
    return docRef.id;
  }

  Future<void> endSession({
    required String sessionId,
    required DateTime endedAt,
    required int actualMinutes,
  }) {
    return _col.doc(sessionId).update({
      'endedAt': Timestamp.fromDate(endedAt),
      'actualMinutes': actualMinutes,
    });
  }

  /// Total actualMinutes across sessions in [start, end) for [planId].
  /// Uses the documented (userId, startedAt) index and filters planId
  /// client-side, since there's no composite index for that combination.
  Future<int> fetchTotalMinutesForRange({
    required String planId,
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _col
        .where('userId', isEqualTo: _uid)
        .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startedAt', isLessThan: Timestamp.fromDate(end))
        .get();

    var total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['planId'] != planId) continue;
      total += (data['actualMinutes'] ?? 0) as int;
    }
    return total;
  }

  /// Total actualMinutes per local calendar day since [windowStart], for
  /// streak computation.
  Future<Map<DateTime, int>> fetchMinutesByDay({
    required String planId,
    required DateTime windowStart,
  }) async {
    final snapshot = await _col
        .where('userId', isEqualTo: _uid)
        .where(
          'startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart),
        )
        .get();

    final minutesByDay = <DateTime, int>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['planId'] != planId) continue;
      final startedAt = (data['startedAt'] as Timestamp?)?.toDate();
      if (startedAt == null) continue;
      final day = localMidnight(startedAt);
      final minutes = (data['actualMinutes'] ?? 0) as int;
      minutesByDay[day] = (minutesByDay[day] ?? 0) + minutes;
    }
    return minutesByDay;
  }
}
