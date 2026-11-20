# Fixtures (test data, do not edit)

`runs.json` is 40 GitHub Actions workflow runs in the exact shape of
`GET /repos/{owner}/{repo}/actions/runs` (only the fields the dashboard needs are kept).
The evening review compares your functions' output on this file with the numbers in
`days/2026-11-20/TASK.md`, so keep it byte-for-byte unchanged (copy it into `app/public/`, don't move it).

What's inside, so you know which edge cases your code must survive:

- 3 workflows: `CI` (push, several branches), `Deploy` (push to main), `Nightly` (schedule).
- Conclusions: `success`, `failure`, `cancelled`, and 2 runs still `in_progress` (`conclusion: null`).
- Runs are ordered **newest first**, like the real API. Your charts probably want oldest first.
- One day (2026-11-14) has no runs at all.
- One run was created at `23:50:12Z`: UTC and Budapest time disagree on its date.
- One run is a re-run (`run_attempt: 2`). Treat it as a normal run.
- All timestamps are UTC (`...Z`).

Field reference: https://docs.github.com/en/rest/actions/workflow-runs#list-workflow-runs-for-a-repository
