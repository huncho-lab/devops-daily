# Thesis step 1: REST API sample app with tests (milestone edition)

- **Date:** 2026-11-03
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours, split into 4 milestones you push one by one
- **Branch:** `task/2026-11-03`
- **Work folder:** `thesis-pipeline/app/`
- **Note:** step 1 is still the next unmerged thesis step (nothing has been pushed on the 31 Oct, 1 Nov or 2 Nov branches), so it carries over with the **same spec and the same 12 acceptance criteria**. What's new today: the work is cut into 4 small milestones, each ending in a commit + push, so every hour you put in is visible to the review. Older `task/2026-10-31`, `-11-01` and `-11-02` branches can be ignored. If you already wrote code locally on one of them, just copy it into this branch and keep going.

> Own-work rule: this is your thesis implementation. The skeleton files only contain TODO comments and test *names*. You write all the code yourself.

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

## Plan: 4 milestones, push after each one

Start with:

```bash
git fetch origin && git switch task/2026-11-03
cd thesis-pipeline/app
```

### Milestone 1: first green test (45 min) → commit + push

1. `npm init -y`, then set `"private": true` and `"engines": {"node": ">=24"}` in `package.json`. Add `.nvmrc` containing `24`.
2. `npm i express` and `npm i -D jest supertest`.
3. In `src/app.js`, write only `GET /healthz` and export the app.
4. In `tests/app.test.js`, turn the first `test.todo` into a real Supertest test. Delete or keep the other todos for now.
5. Add a `"test": "jest"` script. `npm test` passes →
   `git add . && git commit -m "feat(app): health endpoint and first test" && git push -u origin task/2026-11-03`

**Done when:** the branch on GitHub has your first commit and `npm test` is green.

### Milestone 2: the whole API (1 h 30 min) → commit + push

1. `src/store.js`: list / create / get / remove / reset.
2. `src/app.js`: `/version`, the four `/api/items` routes, the name validation and a JSON 404 catch-all registered after all routes.
3. `src/server.js`: read `PORT` (default 3000), call `listen()`, log the port and version.
4. Add `"start": "node src/server.js"`. Check by hand:
   - `curl -i localhost:3000/healthz`
   - `curl -i -X POST localhost:3000/api/items -H 'Content-Type: application/json' -d '{"name":"x"}'`
   - `curl -i localhost:3000/nope` (must be JSON, not HTML)
   - `PORT=4000 APP_VERSION=1.2.3 npm start`, then `curl localhost:4000/version`
5. Commit (e.g. `feat(app): items API, version and JSON 404`) and push.

### Milestone 3: tests + coverage (1 h 30 min) → commit + push

1. Replace every remaining `test.todo` with a real test (13 names are provided; you need at least 10 passing, none skipped/todo).
2. Reset the store in `beforeEach` so tests are independent. For the two `/version` tests, set/unset `process.env.APP_VERSION` inside the test and restore it afterwards.
3. Add `"test:coverage": "jest --coverage"` and configure `collectCoverageFrom` so only `src/` counts (decide whether `server.js` is excluded or tested).
4. Coverage ≥ 80% lines → commit (e.g. `test(app): full API test suite with coverage`) and push.

### Milestone 4: lint + docs (1 h) → commit + push

1. `npm i -D eslint @eslint/js globals`, create `eslint.config.js` (flat config, Node + Jest globals), add `"lint": "eslint ."` and fix everything until it exits 0 with no warnings.
2. Fill in the `Sample app` section of `thesis-pipeline/README.md`: prerequisites, install (`npm ci`), run, test, coverage, lint, env vars with defaults, the endpoint table. Mark step 1 as done in the pipeline table.
3. Final check from a clean state: `rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage`.
4. Commit (e.g. `chore(app): eslint config and README`) and push.

Leave ~15 min buffer for fixes. Small, meaningful commits are also good evidence of independent work for your thesis.

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
- [ ] At least **3 commits** of your own on `task/2026-11-03`, all code written by you (no TODO-only files left in `src/` or `tests/`).

Milestones map to criteria: M1 → 1, 2 (partly), 12 (first commit); M2 → 6, 7, 8, 9; M3 → 2, 3, 4; M4 → 5, 10, 11, 12.

## Stretch goals

- Structured JSON request logging to stdout (one line per request: method, path, status, duration ms). Pays off in step 7.
- Graceful shutdown: on `SIGTERM`, close the server, then exit. Kubernetes sends `SIGTERM` when a pod stops.
- A `/readyz` endpoint distinct from `/healthz`, plus one README sentence on why liveness ≠ readiness.
- Record how long each milestone took in `days/2026-11-03/NOTES.md`. That's raw data for your evaluation chapter (step 8).

## Resources (official docs)

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
