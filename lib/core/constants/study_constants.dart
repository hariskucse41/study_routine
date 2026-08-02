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
