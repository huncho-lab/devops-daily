// MOVE TO: skills/pipeline-dashboard/app/src/metrics.js
// Pure functions only: no React, no fetch, no Date.now(). Input is the `workflow_runs` array.
// Spec and expected values for the fixture: days/2026-11-20/TASK.md ("The data and the metrics").

// TODO (C1): export function durationSeconds(run)
//   - null unless run.status === "completed"
//   - otherwise whole seconds between run_started_at and updated_at

// TODO (C1): export function formatDuration(sec)
//   - null -> "–"; under 60 -> "45s"; under 1 h -> "5m 36s" (seconds zero-padded); else "1h 02m"

// TODO (C1): export function summarize(runs)
//   - { total, completed, success, failure, cancelled, successRate, medianDurationSec, maxDurationSec }
//   - successRate: success / (success + failure) * 100, 1 decimal, null when the denominator is 0
//   - median/max over completed runs only; even count -> mean of the two middle values, Math.round
//   - must not mutate `runs`

// TODO (C2): export function runsPerDay(runs)
//   - [{ date: "YYYY-MM-DD", success, failure, other }] by UTC date of created_at, ascending,
//     every day from first to last present (zeros for empty days); [] for empty input

// TODO (C2): export function byWorkflow(runs)
//   - [{ name, runs, successRate, medianDurationSec }], sorted by runs desc, then name asc
//   - reuse your summarize() rules instead of duplicating them
