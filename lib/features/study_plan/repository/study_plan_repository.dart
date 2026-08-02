import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/study_plan_model.dart';

class StudyPlanRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StudyPlanRepository(this._firestore, this._auth);

  CollectionReference get _plansCol => _firestore.collection('study_plans');

  String get _uid => _auth.currentUser!.uid;

  /// Creates a new study_plans doc for the current user and points
  /// users/{uid}.activeStudyPlanId at it.
  Future<StudyPlanModel> createAndActivatePlan({
    required String title,
    String? examName,
    DateTime? examDate,
    required int dailyTargetMinutes,
  }) async {
    final docRef = _plansCol.doc();
    final plan = StudyPlanModel(
      id: docRef.id,
      userId: _uid,
      title: title,
      examName: examName,
      examDate: examDate,
      status: 'active',
      dailyTargetMinutes: dailyTargetMinutes,
    );
    await docRef.set(plan.toFirestore());
    await _firestore.collection('users').doc(_uid).update({
      'activeStudyPlanId': docRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return plan;
  }

  /// One-shot fetch of the plan pointed to by users/{uid}.activeStudyPlanId,
  /// or null if the user hasn't selected one yet.
  Future<StudyPlanModel?> fetchActivePlan() async {
    final userDoc = await _firestore.collection('users').doc(_uid).get();
    final activeId = userDoc.data()?['activeStudyPlanId'] as String?;
    if (activeId == null) return null;
    final planDoc = await _plansCol.doc(activeId).get();
    if (!planDoc.exists) return null;
    return StudyPlanModel.fromFirestore(planDoc);
  }
}
