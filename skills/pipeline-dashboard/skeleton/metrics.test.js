// MOVE TO: skills/pipeline-dashboard/app/src/metrics.test.js
// Vitest. Import the fixture with a relative path: ../../fixtures/runs.json (use .workflow_runs).

// TODO (C1, criteria 2-4): at least 4 tests
//   - summarize(fixture) toEqual the exact object from criterion 3
//   - formatDuration for 45, 65, 336, 1453, 3725 and null
//   - durationSeconds is null for every run whose status is not "completed"

// TODO (C2, criteria 5-7): bring the total to 10+ tests
//   - runsPerDay: length 10, the empty 2026-11-14 day, 2026-11-10 (the 23:50Z run), 2026-11-17
//   - byWorkflow: exact order and numbers for CI, Deploy, Nightly
//   - empty input: summarize([]) and runsPerDay([])
//   - the input array is unchanged after summarize() (compare with a structuredClone taken before)
