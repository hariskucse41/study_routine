import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/subject_model.dart';

class SubjectRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SubjectRepository(this._firestore, this._auth);

  CollectionReference get _col => _firestore.collection('subjects');

  String get _uid => _auth.currentUser!.uid;

  Stream<List<SubjectModel>> watchSubjects(String planId) {
    return _col
        .where('planId', isEqualTo: planId)
        .where('isArchived', isEqualTo: false)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map(SubjectModel.fromFirestore).toList());
  }

  Stream<SubjectModel?> watchSubject(String subjectId) {
    return _col
        .doc(subjectId)
        .snapshots()
        .map((doc) => doc.exists ? SubjectModel.fromFirestore(doc) : null);
  }

  /// Fields are accepted individually (not a pre-built SubjectModel) so the
  /// owning userId always comes from FirebaseAuth here, never from a
  /// caller-supplied value.
  Future<void> addSubject({
    required String planId,
    required String name,
    String? description,
    required String icon,
    required String color,
    required String priority,
    required int order,
    required int estimatedMinutes,
  }) {
    final docRef = _col.doc();
    final subject = SubjectModel(
      id: docRef.id,
      userId: _uid,
      planId: planId,
      name: name,
      description: description,
      icon: icon,
      color: color,
      priority: priority,
      order: order,
      estimatedMinutes: estimatedMinutes,
    );
    return docRef.set(subject.toFirestore());
  }

  Future<void> archiveSubject(String id) => _col.doc(id).update({
    'isArchived': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
