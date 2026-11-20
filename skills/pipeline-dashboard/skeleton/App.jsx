// MOVE TO: skills/pipeline-dashboard/app/src/App.jsx  (replace Vite's demo App.jsx; delete App.css or reuse it)

// TODO (C2): the page
//   - state: loading / error / { source, runs }
//   - C2: load /runs.json; C3: switch to loadRuns() from ./api.js
//   - header: title + which source is shown (fixture or owner/name) + "last run" time
//   - <KpiTiles>, <RunsPerDayChart>, <DurationChart>, <WorkflowTable>, all fed from metrics.js results
//   - loading and error states render text, never a blank page
//   - import ./dashboard.css
