import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../subject/model/subject_model.dart';
import '../../topic/model/topic_model.dart';
import '../model/syllabus_template_model.dart';
import '../model/template_subject_model.dart';
import '../model/template_topic_model.dart';

/// Reads the read-only syllabus_templates/template_subjects/template_topics
/// collections (seeded manually — Firebase console or a one-off admin
/// script, never written from the app) and copies a chosen template's
/// structure into the current user's own subjects/topics collections for a
/// newly created plan.
class SyllabusTemplateRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SyllabusTemplateRepository(this._firestore, this._auth);

  String get _uid => _auth.currentUser!.uid;

  /// Matches a syllabus_templates doc by its exact `name`, which is the
  /// same string as the plan title chosen on the Select Study Plan screen
  /// (e.g. 'BCS Preparation'). Returns null if none is seeded yet for that
  /// plan type — callers should treat this the same as the Custom Plan
  /// path and simply skip the copy.
  Future<SyllabusTemplateModel?> fetchTemplateByName(String name) async {
    final snapshot = await _firestore
        .collection('syllabus_templates')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return SyllabusTemplateModel.fromFirestore(snapshot.docs.first);
  }

  /// Copies [templateId]'s subjects/topics into the current user's own
  /// subjects/topics collections, scoped to [planId]. New doc IDs are
  /// minted up front so template_topics' parent/child and subject
  /// references can be remapped in a single pass. Writes are split into
  /// batches of 450 (Firestore's hard cap is 500 per WriteBatch) since a
  /// full syllabus can exceed that once subjects + topics are combined.
  Future<void> copyTemplateToPlan({
    required String templateId,
    required String planId,
  }) async {
    // Single equality filter each, no orderBy — covered by Firestore's
    // automatic single-field index, same rationale as
    // TopicRepository.fetchTopicsForPlan. Sorting happens client-side.
    final subjectSnapshot = await _firestore
        .collection('template_subjects')
        .where('templateId', isEqualTo: templateId)
        .get();
    final templateSubjects =
        subjectSnapshot.docs.map(TemplateSubjectModel.fromFirestore).toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    final topicSnapshot = await _firestore
        .collection('template_topics')
        .where('templateId', isEqualTo: templateId)
        .get();
    final templateTopics = topicSnapshot.docs
        .map(TemplateTopicModel.fromFirestore)
        .toList();

    final pendingWrites =
        <MapEntry<DocumentReference, Map<String, dynamic>>>[];

    final subjectIdMap = <String, String>{};
    for (final templateSubject in templateSubjects) {
      final ref = _firestore.collection('subjects').doc();
      subjectIdMap[templateSubject.id] = ref.id;
      final subject = SubjectModel(
        id: ref.id,
        userId: _uid,
        planId: planId,
        name: templateSubject.name,
        description: templateSubject.description,
        icon: templateSubject.icon,
        color: templateSubject.color,
        priority: templateSubject.priority,
        order: templateSubject.order,
        estimatedMinutes: templateSubject.estimatedMinutes,
      );
      pendingWrites.add(MapEntry(ref, subject.toFirestore()));
    }

    final topicIdMap = {
      for (final templateTopic in templateTopics)
        templateTopic.id: _firestore.collection('topics').doc().id,
    };

    for (final templateTopic in templateTopics) {
      final subjectId = subjectIdMap[templateTopic.subjectTemplateId];
      if (subjectId == null) continue; // orphaned template reference — skip
      final ref = _firestore
          .collection('topics')
          .doc(topicIdMap[templateTopic.id]);
      final parentTopicId = templateTopic.parentTopicTemplateId == null
          ? null
          : topicIdMap[templateTopic.parentTopicTemplateId];
      final topic = TopicModel(
        id: ref.id,
        userId: _uid,
        planId: planId,
        subjectId: subjectId,
        parentTopicId: parentTopicId,
        title: templateTopic.title,
        description: templateTopic.description,
        priority: templateTopic.priority,
        difficulty: templateTopic.difficulty,
        estimatedMinutes: templateTopic.estimatedMinutes,
        order: templateTopic.order,
      );
      pendingWrites.add(MapEntry(ref, topic.toFirestore()));
    }

    const maxOpsPerBatch = 450;
    for (var i = 0; i < pendingWrites.length; i += maxOpsPerBatch) {
      final batch = _firestore.batch();
      for (final entry in pendingWrites.skip(i).take(maxOpsPerBatch)) {
        batch.set(entry.key, entry.value);
      }
      await batch.commit();
    }
  }
}
