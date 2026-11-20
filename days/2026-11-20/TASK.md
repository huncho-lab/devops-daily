# Pipeline health dashboard: React + Chart.js over GitHub Actions run data

- **Date:** 2026-11-20 (Friday)
- **Track:** Skills track, day 4 (topic: **React + Chart.js dashboard against an API**, with a CI pipeline for it)
- **Estimated time:** ~5 hours: **10 min first push**, **20 min setup**, **C1 (70 min)**, **C2 (100 min)**, **C3 (~100 min)**
- **Branch:** `task/2026-11-20`
- **Work folder:** `skills/pipeline-dashboard/` (you scaffold the Vite app into `skills/pipeline-dashboard/app/`; the workflow goes to `.github/workflows/` at the repo root in C3)

> Skeleton files in `skills/pipeline-dashboard/skeleton/` contain only TODO comments describing *what* each file must do. You write every line of JavaScript, JSX, CSS and YAML yourself. `fixtures/runs.json` is test data in the exact shape the GitHub REST API returns, not a solution.

## What's new

- **Today starts from your strongest skill.** React, Chart.js, Axios and responsive CSS are already on your CV. The new part is pointing them at DevOps data: success rate, durations and failures of CI pipelines, the numbers your thesis evaluation chapter (step 8) needs.
- **The core is pure functions with known answers.** `src/metrics.js` takes the run list and returns numbers. The acceptance criteria give the exact expected values for the fixture, so `npm test` tells you whether you're right before you draw a single chart.
- **Browser-only route works.** A GitHub Codespace has Node and a browser preview (port forwarding). No Docker, no cloud account, no token.
- **Earlier branches stay open.** Thesis step 1 (`task/2026-11-16`), Docker (`task/2026-11-17`), GitHub Actions (`task/2026-11-18`) and Linux admin (`task/2026-11-19`) are parked. Push to any of them and say `review now task/<date>` in Agent Hub.
- **Days not fitting right now?** One line in Agent Hub, thread *tasks*: `lighter tasks`, `pause until <date>`, `weekends only`, `extend thesis to <date>` or `thesis + skills`. The next brief adapts. A one-word reply is enough.

## Goal

Build a small React dashboard that loads GitHub Actions workflow runs (from a fixture by default, from any public repo with `?repo=owner/name`), computes pipeline health metrics in a tested `metrics.js`, and shows them as KPI tiles, two Chart.js charts and a per-workflow table, responsive from 375 px phones to desktop. Then give the dashboard its own CI pipeline: lint, test, build, artifact.

## Why it matters for DevOps jobs

The AGCO IT DevOps intern posting lists GitHub Actions/Azure DevOps and monitoring. "Is our pipeline healthy?" is a question every DevOps team answers weekly: success rate, median build time, which workflow fails most, how quickly a red main turns green again (the basis of DORA's change-failure-rate and recovery metrics). Being able to pull that from the Actions REST API, compute it correctly (UTC days, medians, excluding in-progress runs) and show it clearly is a portfolio piece an interviewer can open in a browser. It's also the tool you'll reuse to measure your own thesis pipeline.

## First push (10 min, no code) → criterion 0

Browser route: on https://github.com/huncho-lab/devops-daily switch to `task/2026-11-20`, open `days/2026-11-20/NOTES.md`, click the pencil, fill the 3 top lines, **Commit changes** to `task/2026-11-20`.

Terminal route:

```bash
git fetch origin && git switch task/2026-11-20
# edit days/2026-11-20/NOTES.md (3 lines at the top)
git add days/2026-11-20/NOTES.md && git commit -m "notes: start 2026-11-20" && git push
```

If anything fails, paste the exact error into Agent Hub (thread *tasks* or *review*). That counts as today's result.

## Setup (20 min)

1. **Codespace (recommended):** repo page → **Code** → **Codespaces** → create on branch `task/2026-11-20`. Stop the codespace when you're done (free monthly quota).
2. `node -v` must be **20.19+ or 22.12+** (current Vite requirement). If it's older: `nvm install 22 && nvm use 22`.
3. Scaffold the app **into `app/`** (so it doesn't collide with `skeleton/` and `fixtures/`):
   ```bash
   cd skills/pipeline-dashboard
   npm create vite@latest app -- --template react
   cd app && npm install
   npm install chart.js react-chartjs-2 axios
   npm install -D vitest
   ```
4. Add `"test": "vitest run"` to `package.json` scripts, then move the skeleton files where they belong (`skeleton/metrics.js` → `app/src/metrics.js`, `skeleton/components/*` → `app/src/components/`, `skeleton/pipeline-dashboard.yml` → `.github/workflows/` at the repo root in C3, and so on; each file's header says where). Replace Vite's demo `App.jsx`/`App.css` with yours.
5. `npm run dev`, open the forwarded port: the Vite demo page should load. Commit `package.json` + `package-lock.json` now (check `git status`: `node_modules/` and `dist/` must not appear; Vite's `.gitignore` handles both).

### Unstick table

| Symptom | Official fix |
|---|---|
| `Vite requires Node.js version 20.19+ or 22.12+` | Upgrade Node (nvm, or the Codespace's `nvm install 22`) |
| `npm create vite` asks about a non-empty folder | You ran it in `skills/pipeline-dashboard/` with `.`; use the folder name `app` as shown |
| Dev server page doesn't open in Codespaces | **Ports** tab → open port 5173. If the page is blank, run `npm run dev -- --host` |
| `"category" is not a registered scale` / `"bar" is not a registered controller` | Chart.js v4 is tree-shaken: call `ChartJS.register(...)` with every scale, element and plugin you use (Chart.js docs, "Integration → Bundlers") |
| Data fetched twice in dev | React 18/19 StrictMode runs effects twice on purpose in development (react.dev, "useEffect → My Effect runs twice") |
| `fetch('/runs.json')` 404 | Files served as-is must be in `app/public/`; copy `fixtures/runs.json` there (leave the original in `fixtures/` unchanged) |
| Importing the fixture in tests fails | From `app/src/metrics.test.js` the path is `../../fixtures/runs.json`; Vitest imports JSON directly |
| `403` from api.github.com | Unauthenticated limit is 60 requests/hour per IP. Wait for the reset time or test with the fixture. Never put a token in browser code |

## The data and the metrics (spec)

`fixtures/runs.json` has the shape of `GET /repos/{owner}/{repo}/actions/runs`: `{ total_count, workflow_runs: [...] }`, newest first. Each run has `name` (workflow), `status` (`completed`, `in_progress`, …), `conclusion` (`success`, `failure`, `cancelled`, or `null` while running), `created_at`, `run_started_at`, `updated_at` (ISO 8601, UTC), `run_attempt`, `html_url`. See `fixtures/README.md`.

All functions in `app/src/metrics.js` are pure (no React, no fetch) and take the `workflow_runs` array:

| Export | Returns | Rules |
|---|---|---|
| `durationSeconds(run)` | integer seconds, or `null` | `updated_at − run_started_at`; `null` unless `status === "completed"` |
| `formatDuration(sec)` | string | `45` → `"45s"`, `65` → `"1m 05s"`, `336` → `"5m 36s"`, `3725` → `"1h 02m"`; `null` → `"–"` |
| `summarize(runs)` | `{ total, completed, success, failure, cancelled, successRate, medianDurationSec, maxDurationSec }` | `successRate` = success ÷ (success + failure) × 100, rounded to 1 decimal, `null` if no success/failure. Median over completed runs only; even count → mean of the two middle values, rounded to the nearest second (`Math.round`). Empty input → counts 0, the rest `null` |
| `runsPerDay(runs)` | `[{ date, success, failure, other }]` | Grouped by the **UTC** date of `created_at` (`YYYY-MM-DD`), ascending, **every day from first to last included** (days with no runs as zeros). `other` = anything not success/failure, including in-progress |
| `byWorkflow(runs)` | `[{ name, runs, successRate, medianDurationSec }]` | One row per workflow `name`, same rules as `summarize`; sorted by `runs` descending, then `name` ascending |

## Plan (timed)

| Time | Block | What you do | Criteria | Push? |
|---|---|---|---|---|
| 0:00–0:10 | First push | NOTES.md, 3 lines | 0 | yes |
| 0:10–0:30 | Setup | Codespace, Node check, scaffold, install, commit lockfile | 1 | yes |
| 0:30–1:40 | C1 | `durationSeconds`, `formatDuration`, `summarize` + their tests | 2–4 | **yes: pass line** |
| 1:40–2:20 | C2a | `runsPerDay`, `byWorkflow` + tests, edge cases | 5–7 | yes |
| 2:20–3:20 | C2b | `App.jsx`, KPI tiles, two charts, workflow table from `public/runs.json` | 8 | yes |
| 3:20–3:40 | C2c | Responsive CSS, screenshots at 375 px and 1280 px | 9 | yes |
| 3:40–4:20 | C3a | `api.js` live mode with Axios, loading/error states, 2 mocked tests | 10 | yes |
| 4:20–4:45 | C3b | Lint clean, workflow moved to `.github/workflows/` and green | 11, 12 | yes |
| 4:45–5:10 | C3c | README with real live-mode numbers; remove `skeleton/` | 13, 14 | yes |

**Stop rule:** at 20:45, commit and push whatever you have. The review at 21:12 grades what is on the branch.

## Acceptance criteria (the evening review grades exactly these)

Commands run from `skills/pipeline-dashboard/app/` unless noted. "Fixture" means `../fixtures/runs.json` → `.workflow_runs`.

**First push**
- [ ] **0.** `days/2026-11-20/NOTES.md` has the 3 top lines filled in (or an error pasted in Agent Hub), committed by you and pushed.

**C1, pass line**
- [ ] **1.** `app/` is a Vite + React project with `package.json` and `package-lock.json` committed; `npm ci && npm run build` succeeds on a clean checkout; `node_modules/` and `dist/` are not committed.
- [ ] **2.** `npm test` runs Vitest (`vitest run`, no watch mode) and exits 0, with at least 4 tests in `src/metrics.test.js`.
- [ ] **3.** `summarize(fixture)` returns exactly `{ total: 40, completed: 38, success: 25, failure: 7, cancelled: 6, successRate: 78.1, medianDurationSec: 336, maxDurationSec: 1453 }`, asserted by a test.
- [ ] **4.** `formatDuration` gives `"45s"`, `"1m 05s"`, `"5m 36s"`, `"24m 13s"` (1453) and `"1h 02m"` (3725), and `durationSeconds` returns `null` for the in-progress runs; asserted by tests.

**C2, metrics + dashboard**
- [ ] **5.** `runsPerDay(fixture)` returns 10 entries from `2026-11-09` to `2026-11-18`, including `{ date: "2026-11-14", success: 0, failure: 0, other: 0 }`; `2026-11-10` is `{ success: 4, failure: 1, other: 0 }` (the run created at `23:50:12Z` counts on the 10th, UTC); `2026-11-17` is `{ success: 2, failure: 0, other: 3 }`.
- [ ] **6.** `byWorkflow(fixture)` returns, in this order: `CI` (runs 25, successRate 80, median 296), `Deploy` (8, 83.3, 439), `Nightly` (7, 66.7, 1311).
- [ ] **7.** At least **10** passing Vitest tests in total, covering criteria 3–6 plus: empty array input (`summarize([])` → counts 0, rates/durations `null`; `runsPerDay([])` → `[]`), and that the input array is not mutated (e.g. sorting a copy for the median).
- [ ] **8.** `npm run dev` with no query string shows, from `public/runs.json`: 4 KPI tiles (**Total runs 40**, **Success rate 78.1%**, **Median duration 5m 36s**, **Failures 7**), a **stacked bar chart** of runs per day (success/failure/other), a **line chart** of duration per completed run in time order, and a **per-workflow table** with the numbers from criterion 6. Charts use `react-chartjs-2`, with only the needed Chart.js components registered (no `chart.js/auto`).
- [ ] **9.** Responsive: at 375 px width no horizontal scrolling and one column; at ≥ 1024 px the 4 KPI tiles sit in one row. `skills/pipeline-dashboard/README.md` has a screenshot at each width.

**C3, live API + CI + docs**
- [ ] **10.** `src/api.js` exports `loadRuns()`: with `?repo=owner/name` in the page URL it fetches `https://api.github.com/repos/owner/name/actions/runs?per_page=100` with **Axios** (no token anywhere in the code); otherwise it loads `/runs.json`. The UI shows a loading state and readable errors, never a blank page: `404` → a message containing `not found`; `403`/`429` with `x-ratelimit-remaining: 0` → a message containing `rate limit` and the reset time. At least 2 tests mock Axios (`vi.mock`) and cover the success path and one error path.
- [ ] **11.** `npm run lint` exits 0 with no warnings (`eslint . --max-warnings 0` or equivalent).
- [ ] **12.** `.github/workflows/pipeline-dashboard.yml` (from the skeleton) runs on this branch: triggers `push` to `task/**` with a `paths:` filter covering `skills/pipeline-dashboard/**` and the workflow file itself, plus `workflow_dispatch`; exact runner label (not `-latest`); `timeout-minutes` ≤ 10; `permissions: contents: read`; `actions/checkout`, `actions/setup-node` and `actions/upload-artifact` pinned to full 40-char SHAs with version comments; `setup-node` caches npm with `cache-dependency-path` pointing at the lockfile; runs `npm ci`, lint, test, build in `skills/pipeline-dashboard/app`; uploads `dist/` as artifact `pipeline-dashboard-dist` with `retention-days` ≤ 7. The latest run on `task/2026-11-20` is green.
- [ ] **13.** `skills/pipeline-dashboard/README.md` has every section from its TODO, including the dashboard's numbers for one real public repo in live mode (which repo, when, 3 KPIs) and 3 "what I learned" bullets in your own words.
- [ ] **14.** At least 3 commits of your own on `task/2026-11-20`, no TODO-only files left, `skills/pipeline-dashboard/skeleton/` removed, `fixtures/runs.json` unchanged, and no tokens or `.env` files committed.

## Hints (no solutions)

- Write the tests first for C1: the expected numbers are above. Import the fixture in the test, call your function, `expect(...).toEqual({...})`.
- `Array.prototype.sort()` without a compare function sorts **as strings** (`[336, 1453, 45]` → `[1453, 336, 45]`). It also sorts **in place**, so sort a copy (MDN, `Array.prototype.sort`, `toSorted`).
- `Date.parse()` gives milliseconds; divide by 1000. ISO strings ending in `Z` are UTC, and `created_at.slice(0, 10)` is already the UTC date. `new Date(x).toLocaleDateString()` is **local** time and would move the 23:50Z run to the 11th in Budapest.
- Gap filling: start from the first date, add one day (`86 400 000` ms, safe in UTC) until you pass the last date.
- Rounding to 1 decimal: `Math.round(x * 10) / 10`. `toFixed` returns a string, and the criteria compare numbers.
- Chart.js v4: a stacked bar needs `stacked: true` on **both** the x and y scales. A line chart over time is simplest with string labels (run number or `created_at`), so you don't need the time scale and a date adapter.
- `react-chartjs-2` takes `data` and `options` props. Build them from your metrics with plain `map`, and keep chart code out of `metrics.js`.
- Responsive grid: `display: grid; grid-template-columns: repeat(auto-fit, minmax(…, 1fr))`, and set `maintainAspectRatio: false` on charts inside a container with a fixed height, or they grow on narrow screens.
- Read the query string with `new URLSearchParams(window.location.search).get("repo")`.
- Axios rejects on non-2xx responses: the status and headers are on `error.response`. `x-ratelimit-reset` is a Unix time in **seconds**.
- `vi.mock("axios")`, then `axios.get.mockResolvedValue(...)` / `mockRejectedValue(...)` (Vitest docs, "Mocking").
- Vite's template already ships an ESLint flat config (`eslint.config.js`): use it, don't add a second one.
- In the workflow: `defaults: run: working-directory: skills/pipeline-dashboard/app`, and remember `cache-dependency-path` is relative to the repo root, not to `working-directory`.

## Stretch goals (not graded, but noted in the review)

- **Time to recovery:** for each workflow on `main`, the time from the first failed run to the next successful one; show the median as a fifth KPI (DORA's "failed deployment recovery time" idea).
- p90 duration next to the median, and a date-range filter (last 7 / 14 / 30 days).
- Point live mode at `huncho-lab/devops-daily` once your own workflows (Days 2–4) have runs, and screenshot it. This is the measurement tool for thesis step 8.
- Deploy the built dashboard to GitHub Pages from `main` after merge (Vite `base` option + `actions/deploy-pages`).
- A Vitest + React Testing Library test that renders `KpiTiles` and finds "78.1%".

## Resources (official docs only)

- Vite, getting started and env/modes: https://vite.dev/guide/ · https://vite.dev/guide/static-deploy
- React: https://react.dev/learn · `useEffect` and fetching data: https://react.dev/reference/react/useEffect
- Chart.js (bar/line, stacked, integration with bundlers): https://www.chartjs.org/docs/latest/ · https://www.chartjs.org/docs/latest/getting-started/integration.html
- react-chartjs-2: https://react-chartjs-2.js.org/
- Axios (requests, error handling): https://axios-http.com/docs/intro · https://axios-http.com/docs/handling_errors
- Vitest (getting started, mocking): https://vitest.dev/guide/ · https://vitest.dev/guide/mocking
- GitHub REST API, workflow runs: https://docs.github.com/en/rest/actions/workflow-runs#list-workflow-runs-for-a-repository
- GitHub REST API rate limits: https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api
- MDN `Array.prototype.sort`, `Date.parse`, CSS grid: https://developer.mozilla.org/
- GitHub Actions: `actions/setup-node` caching: https://github.com/actions/setup-node#caching-global-packages-data · workflow syntax: https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions · artifacts: https://github.com/actions/upload-artifact
- DORA metrics: https://dora.dev/guides/dora-metrics-four-keys/
- GitHub Codespaces, port forwarding: https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace
