# Thesis step 1: REST API sample app with tests (restart + replan edition)

- **Date:** 2026-11-05
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours: a 15-min first push, then 4 milestones you push one by one
- **Branch:** `task/2026-11-05`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step. The 31 Oct – 4 Nov branches have no commits of yours, so the **spec and the 12 acceptance criteria are unchanged** (the review grades the same things). Code you wrote locally elsewhere? Copy it into this branch.

> Own-work rule: this is your thesis implementation. The skeleton files only contain TODO comments and test *names*. You write all the code yourself.

## What's different today

1. **M0: a 15-minute first push that needs no code.** Fill in `days/2026-11-05/NOTES.md` (what got in the way, which pace is realistic), commit, push. That breaks the zero-commit streak and tells the Task Creator how to size the rest of the thesis.
2. **Honest schedule.** 11 days remain until 16 Nov (5–16 Nov) for 8 steps. The table below shows what still fits if step 1 lands today vs. later, so you can choose with your eyes open.
3. **Stop rule.** If you hit 21:00 with M1 not done, push whatever you have anyway. The review gives feedback on partial work.

### Replan: what fits before 16 Nov

| If step 1 is merged… | Realistic plan for steps 2–8 by 16 Nov |
|---|---|
| **today (5 Nov)** | 1 step/day: 2 → 6 Nov, 3 → 7 Nov, 4 → 8 Nov, 5 → 9 Nov, 6 → 10 Nov, 7 → 11 Nov, 8 → 12 Nov, leaving 4 buffer days. Everything fits. |
| tomorrow (6 Nov) | Still fits at 1 step/day, with 3 buffer days. |
| 8 Nov or later | Steps 2–6 fit; 7 (monitoring) and 8 (measurements) get tight. Consider "2 days per step" and moving 7–8 after 16 Nov. |

Tell the Task Creator your choice in Agent Hub (thread *tasks*), e.g. "1 step per day", "smaller thesis tasks" or "2 days per step".

## Goal

Build the sample application the rest of your thesis pipeline will build, test, containerise and deploy: a small **Node.js + Express REST API** (in-memory "items" store) with a health endpoint, a version endpoint, automated tests and a lint step. It must be **testable, configured through environment variables, and fast to start**, because Docker (step 2), CI (step 3), Kind (step 4), CD smoke tests (step 5) and monitoring (step 7) all depend on it.

## Why it matters for DevOps jobs

- CI gates on scripts that exit non-zero on failure. `npm test` and `npm run lint` are exactly what your GitHub Actions workflow will call in step 3.
- `/healthz` and `/version` are what Kubernetes probes and CD smoke tests hit (steps 4–5). Designing for operability from day one is a point interviewers like to hear.
- 12-factor config (`PORT`, `APP_VERSION` from env) lets the same image run locally, in Docker and in Kubernetes with a ConfigMap.
- Splitting `app.js` (the app) from `server.js` (the listener) lets you test HTTP without opening ports, which keeps CI fast and stable.

## API specification (implement exactly this)

| Method | Path | Success | Errors |
|---|---|---|---|
| GET | `/healthz` | `200` `{"status":"ok"}` | – |
| GET | `/version` | `200` `{"version": <APP_VERSION env or "dev">}` | – |
| GET | `/api/items` | `200` JSON array of all items | – |
| POST | `/api/items` | `201` the created item `{id, name, createdAt}` | `400` `{"error": "..."}` if `name` is missing, not a string, empty or longer than 100 chars |
| GET | `/api/items/:id` | `200` the item | `404` `{"error":"not found"}` |
| DELETE | `/api/items/:id` | `204` no body | `404` `{"error":"not found"}` |
| any | unknown route | – | `404` JSON `{"error":"not found"}` (not Express's HTML page) |

- `id` must be unique (e.g. `crypto.randomUUID()`), `createdAt` an ISO-8601 string.
- The server listens on `PORT` (default `3000`).

## Plan: push after every milestone

```bash
git fetch origin && git switch task/2026-11-05
```

### M0: first push, no code (15 min) → commit + push

1. Open `days/2026-11-05/NOTES.md`, write 2–3 sentences on what blocked you, tick a pace option, fill the M0 row.
2. `git add days/2026-11-05/NOTES.md && git commit -m "docs: day log and pace for thesis step 1" && git push -u origin task/2026-11-05`
3. Post your pace choice in Agent Hub.

### M1: first green test (45 min) → commit + push

1. `cd thesis-pipeline/app`, `npm init -y`, then set `"private": true` and `"engines": {"node": ">=24"}`. Add `.nvmrc` containing `24`.
2. `npm i express` and `npm i -D jest supertest`.
3. In `src/app.js`, write only `GET /healthz` and export the app.
4. Turn the first `test.todo` in `tests/app.test.js` into a real Supertest test.
5. Add `"test": "jest"`. Green → commit (`feat(app): health endpoint and first test`) and push.

### M2: the whole API (1 h 30 min) → commit + push

1. `src/store.js`: list / create / get / remove / reset.
2. `src/app.js`: `/version`, the four `/api/items` routes, name validation, a JSON 404 catch-all after all routes.
3. `src/server.js`: read `PORT` (default 3000), `listen()`, log port and version. Add `"start": "node src/server.js"`.
4. Check by hand: `curl -i localhost:3000/healthz`, a `POST` with `-d '{"name":"x"}'`, `curl -i localhost:3000/nope` (must be JSON), and `PORT=4000 APP_VERSION=1.2.3 npm start` + `curl localhost:4000/version`.
5. Commit (`feat(app): items API, version and JSON 404`) and push.

### M3: tests + coverage (1 h 30 min) → commit + push

1. Replace every remaining `test.todo` with a real test (13 names provided; ≥ 10 passing, none skip/todo).
2. Reset the store in `beforeEach`. For `/version` tests, set/unset `process.env.APP_VERSION` inside the test and restore it.
3. Add `"test:coverage": "jest --coverage"` with `collectCoverageFrom` limited to `src/` (decide whether `server.js` is excluded or tested, and say why in the README).
4. ≥ 80 % lines → commit (`test(app): full API test suite with coverage`) and push.

### M4: lint + docs (1 h) → commit + push

1. `npm i -D eslint @eslint/js globals`, create `eslint.config.js` (flat config, Node + Jest globals), add `"lint": "eslint ."`, fix until 0 problems.
2. Fill the `Sample app` section of `thesis-pipeline/README.md`; mark step 1 done in the pipeline table.
3. Clean check: `rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage`.
4. Commit (`chore(app): eslint config and README`) and push. Then write "review now task/2026-11-05" in Agent Hub if it's before 21:12.

Milestones map to criteria: M1 → 1, 2 (partly), 12 (first code commit); M2 → 6, 7, 8, 9; M3 → 2, 3, 4; M4 → 5, 10, 11, 12.

## Acceptance criteria (graded in the evening review)

- [ ] `thesis-pipeline/app/package.json` and `package-lock.json` exist; `cd thesis-pipeline/app && npm ci` succeeds on a clean checkout.
- [ ] `npm test` runs Jest and exits `0`.
- [ ] `tests/app.test.js` has **at least 10 passing tests** covering every row of the API table (including 400, 404 and the unknown-route case). No `test.skip` / `test.todo` left.
- [ ] `npm run test:coverage` reports **≥ 80% line coverage** for `src/`.
- [ ] `npm run lint` runs ESLint and exits `0` with no warnings.
- [ ] `src/app.js` exports the app **without** calling `listen()`; `src/server.js` is the only file that calls `listen()`.
- [ ] `PORT=4000 npm start` serves on port 4000, and `APP_VERSION=1.2.3 npm start` makes `GET /version` return `{"version":"1.2.3"}` (and `"dev"` when unset).
- [ ] Unknown routes return a **JSON** 404, not HTML.
- [ ] `POST /api/items` returns `400` for a missing, empty, non-string or >100-char `name`.
- [ ] `node_modules/` and `coverage/` are not committed (`.gitignore` present).
- [ ] `thesis-pipeline/README.md` documents how to install, run, test and lint, the env vars and the endpoints.
- [ ] At least **3 commits** of your own on `task/2026-11-05`, all code written by you (no TODO-only files left in `src/` or `tests/`).

## Stretch goals

- Structured JSON request logging to stdout (method, path, status, duration ms). Pays off in step 7.
- Graceful shutdown on `SIGTERM` (close the server, then exit). Kubernetes sends `SIGTERM` when a pod stops.
- A `/readyz` endpoint distinct from `/healthz`, plus one README sentence on liveness vs readiness.
- Peek ahead at step 2: read the Docker multi-stage build docs (link below) so tomorrow starts faster.

## Resources (official docs)

- Docker multi-stage builds (preview for step 2): https://docs.docker.com/build/building/multi-stage/

- Express routing and error handling: https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started and configuration (coverage): https://jestjs.io/docs/getting-started, https://jestjs.io/docs/configuration#collectcoveragefrom-array
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
- Node.js `crypto.randomUUID()`: https://nodejs.org/api/crypto.html#cryptorandomuuidoptions
- The Twelve-Factor App, Config: https://12factor.net/config

## Hints (not solutions)

- Supertest takes the app object directly (`request(app)`), so tests need no port.
- Express's built-in 404 is HTML. A catch-all middleware registered **after** your routes fixes that.
- `typeof name === 'string'` plus a `trim()` length check covers most of the 400 cases; think about what `{"name": 123}` and `{}` should do.
- With Express 5, a `DELETE` that responds `res.status(204).end()` sends no body, which is what the spec wants.
- Pick CommonJS or ES modules once (the `"type"` field in `package.json`) and stay consistent. Jest works out of the box with CommonJS.
- Stuck for more than 20 minutes on one thing? Commit what you have, push, and write the question in Agent Hub. Partial work still gets real feedback.
