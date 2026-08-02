/// Typed navigation payload for launching the Session Timer page — passed
/// via go_router's `extra` since this is a purely in-app flow with no
/// need for a deep-linkable URL.
class SessionStartArgs {
  final String planId;
  final String subjectId;
  final String topicId;
  final String subjectName;
  final String topicName;
  final String? scheduleId;
  final int plannedMinutes;

  const SessionStartArgs({
    required this.planId,
    required this.subjectId,
    required this.topicId,
    required this.subjectName,
    required this.topicName,
    this.scheduleId,
    required this.plannedMinutes,
  });
}
