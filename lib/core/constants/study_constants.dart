/// Fixed spaced-repetition interval used for v1: every newly logged
/// revision (whether auto-created on topic completion, or manually logged
/// as the "next" one) is scheduled this many days out. A variable/adaptive
/// interval is a reasonable future improvement but out of scope for now.
const int defaultRevisionIntervalDays = 3;

/// Fixed per-day goal targets for the Goals checklist (screen 26), used
/// until Settings (Phase 12) makes these user-configurable. Study minutes
/// isn't here since it already has a real per-plan value
/// (StudyPlanModel.dailyTargetMinutes).
const int defaultDailyTopicsTarget = 3;
const int defaultDailyRevisionsTarget = 3;
const int defaultDailyMcqsTarget = 20;

/// A subject whose average recent test score falls below this feeds all of
/// its topics into the Weak Topics screen (screen 24), alongside the
/// existing per-topic confidence/stalled-progress criteria.
const double weakSubjectScoreThreshold = 60.0;

/// "Recent" test results window used both for the weak-subject signal
/// above and generally treated as the meaningful recency horizon for test
/// performance.
const int recentTestResultsWindowDays = 30;
