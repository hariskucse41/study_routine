/// Typed navigation payload for the Revision Detail page — passed via
/// go_router's `extra`, same pattern as SessionStartArgs. Sourced from the
/// tapped RevisionModel (which already carries planId/subjectId) plus the
/// display names already resolved on the Revision List page.
class RevisionDetailArgs {
  final String planId;
  final String subjectId;
  final String subjectName;
  final String topicName;

  const RevisionDetailArgs({
    required this.planId,
    required this.subjectId,
    required this.subjectName,
    required this.topicName,
  });
}
