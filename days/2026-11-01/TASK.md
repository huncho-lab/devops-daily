# Thesis step 1: a small REST API sample app with tests

- **Date:** 2026-11-01
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours
- **Branch:** `task/2026-11-01`
- **Work folder:** `thesis-pipeline/app/`
- **Note:** repeat of the 2026-10-31 task (not started that day), same brief and acceptance criteria.

> Own-work rule: this is your thesis implementation. The skeleton files only contain TODO comments and test *names*. You write all the code yourself.

## Goal

Build the purpose-built sample application your thesis pipeline will build, test, containerise and deploy: a small **Node.js + Express REST API** (in-memory "items" store) with a health endpoint, a version endpoint, automated tests and a lint step. Nothing fancy, but it must be **testable, configurable through environment variables, and fast to start**, because every later step (Docker, CI, Kind, CD, smoke tests, monitoring) depends on it.

## Why it matters for DevOps jobs

- A pipeline is only as good as the checks it runs. Lint and test scripts that exit non-zero on failure are what CI gates on (step 3).
- `/healthz` and `/version` are what Kubernetes probes and CD smoke tests call (steps 4–5). Building them now means you design for operability from day one.
- 12-factor config (`PORT`, `APP_VERSION` from env) is what lets the same image run locally, in Docker and in Kubernetes with a ConfigMap.
- Separating `app.js` (the app) from `server.js` (the listener) is the standard trick for testing HTTP apps without opening ports, which keeps CI fast and reliable.

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

## Step-by-step plan (timed)

1. **Setup (30 min)**
   - In `thesis-pipeline/app/`, run `npm init -y`, set `"private": true` and an `engines.node` of `>=24` (Node 24 is the current LTS).
   - Add an `.nvmrc` with `24`.
   - Install `express` as a dependency, and `jest`, `supertest`, `eslint` (plus `@eslint/js` and `globals`) as devDependencies.
   - Commit `package-lock.json`. CI will use `npm ci` later, which needs it.
2. **App skeleton (45 min)**: fill in `src/app.js` (builds and exports the Express app, no `listen`) and `src/server.js` (imports the app and listens on `PORT`). Get `/healthz` working with `curl localhost:3000/healthz`.
3. **Items resource (1 h 15 min)**: implement the store (`src/store.js`) and the `/api/items` routes, the validation and JSON 404 handler. Test manually with `curl`.
4. **Tests (1 h 30 min)**: implement every test in `tests/app.test.js` with Jest + Supertest against the exported app. Reset the store between tests so they're independent. Add a coverage run.
5. **Lint + scripts (30 min)**: create an ESLint flat config (`eslint.config.js`) and add npm scripts: `start`, `test`, `test:coverage`, `lint`. Fix all warnings.
6. **Docs + cleanup (30 min)**: fill in `thesis-pipeline/README.md` (how to run, test, lint, env vars, API table). Make sure `node_modules/` and `coverage/` are git-ignored. Push.

Commit after each step with clear messages (e.g. `feat(app): add items routes`). Small, meaningful commits are good thesis evidence.

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
- [ ] At least **3 commits** of your own on `task/2026-11-01`, all code written by you (no TODO-only files left in `src/` or `tests/`).

## Stretch goals

- Structured JSON request logging to stdout (one line per request: method, path, status, duration ms). This pays off in step 7 (monitoring).
- Graceful shutdown: handle `SIGTERM` by closing the server, then exiting. Kubernetes sends `SIGTERM` on pod termination (step 4–5).
- A `/readyz` endpoint distinct from `/healthz`, and a sentence in the README on why liveness ≠ readiness.
- Note the time each step took in `days/2026-11-01/NOTES.md`. It's raw material for your thesis's evaluation chapter (step 8).

## Resources (official docs)

- Express routing and error handling: https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started and configuration (coverage): https://jestjs.io/docs/getting-started, https://jestjs.io/docs/configuration#collectcoverage-boolean
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
- Node.js `crypto.randomUUID()`: https://nodejs.org/api/crypto.html#cryptorandomuuidoptions
- The Twelve-Factor App, Config: https://12factor.net/config

## Hints (not solutions)

- Supertest takes the app object directly (`request(app)`), so no port is needed in tests.
- Express's built-in 404 is HTML. A catch-all middleware registered **after** your routes fixes that.
- Give your store a `reset()` (or a factory function) so each test starts empty, e.g. in `beforeEach`.
- Jest coverage scope: look at `collectCoverageFrom` so the report covers `src/` only and doesn't count `server.js` against you (or test it too).
- Decide CommonJS vs ES modules once (the `"type"` field in `package.json`) and stay consistent. Jest works out of the box with CommonJS.
