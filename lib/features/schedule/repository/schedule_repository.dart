import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firestore/batch_name_lookup.dart';
import '../model/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ScheduleRepository(this._firestore, this._auth);

  CollectionReference get _col => _firestore.collection('schedules');

  String get _uid => _auth.currentUser!.uid;

  /// Firestore requires the first `orderBy` to match the range-filtered
  /// field (`scheduledDate` here), so results are sorted by `startTime`
  /// client-side instead — day/month lists are small enough that this is
  /// cheap, and startTime's "HH:mm" format sorts correctly as text.
  Stream<List<ScheduleModel>> watchSchedules({
    required String planId,
    required DateTime start,
    required DateTime end,
  }) {
    return _col
        .where('userId', isEqualTo: _uid)
        .where('planId', isEqualTo: planId)
        .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) {
          final list = s.docs.map(ScheduleModel.fromFirestore).toList();
          list.sort((a, b) => a.startTime.compareTo(b.startTime));
          return list;
        });
  }

  Future<void> addSchedule({
    required String planId,
    required String subjectId,
    required String topicId,
    required DateTime scheduledDate,
    required String startTime,
    required int plannedMinutes,
    required String priority,
    required bool reminderEnabled,
    required int reminderMinutesBefore,
    String? notes,
  }) {
    final docRef = _col.doc();
    final schedule = ScheduleModel(
      id: docRef.id,
      userId: _uid,
      planId: planId,
      subjectId: subjectId,
      topicId: topicId,
      scheduledDate: scheduledDate,
      startTime: startTime,
      plannedMinutes: plannedMinutes,
      priority: priority,
      reminderEnabled: reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore,
      notes: notes,
    );
    return docRef.set(schedule.toFirestore());
  }

  /// Batched display-name lookups for rendering schedule tiles (the
  /// schedules collection only stores subjectId/topicId, not names).
  Future<Map<String, String>> fetchSubjectNames(Set<String> ids) =>
      fetchNamesById(_firestore, collection: 'subjects', field: 'name', ids: ids);

  Future<Map<String, String>> fetchTopicNames(Set<String> ids) =>
      fetchNamesById(_firestore, collection: 'topics', field: 'title', ids: ids);
}
