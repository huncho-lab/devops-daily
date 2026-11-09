# Thesis step 1: REST API sample app with tests (Monday "one file at a time" edition)

- **Date:** 2026-11-09 (Monday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours, as 5 short stages. Each stage touches mainly **one file** and ends in a push.
- **Branch:** `task/2026-11-09`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step (the 31 Oct to 8 Nov branches have no commits of yours), so the **spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else (another branch, a local folder) can be copied in here.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

- **One file at a time.** Earlier briefs grouped the work into blocks across several files. Today each stage has one main file and one check you can run, so you always know what "done" means for the next 30–75 minutes.
- **Smallest useful start: `store.js` (30 min).** It's plain JavaScript with no Express and no HTTP, and it's the easiest file to finish.
- **Replan for the 7 days left.** 9–15 Nov leaves 7 days for 8 steps, so two steps have to be combined. Default plan (used if you don't reply):

  | Date | Step |
  |---|---|
  | Mon 9 Nov | 1. REST API + tests (today) |
  | Tue 10 Nov | 2. Dockerfile + compose |
  | Wed 11 Nov | 3. GitHub Actions CI + GHCR |
  | Thu 12 Nov | 4. Kind + manifests |
  | Fri 13 Nov | 5. CD to Kind + smoke test |
  | Sat 14 Nov | 6 + 7 combined, trimmed: Trivy scan + `/metrics` endpoint (no Grafana) |
  | Sun 15 Nov | 8. Measurements for the evaluation chapter |
  | Mon 16 Nov | buffer |

  Other options, one line in Agent Hub (thread *tasks*) is enough: **"smaller thesis tasks"** (~2–3 h/day, steps 6–7 cut to the minimum) or **"2 days per step"** (steps 1–4 only by 16 Nov, the rest after). If something other than time is blocking you (Git access, Node setup, the thesis track itself), say that instead and tomorrow's task will address it.

## Goal

Build the sample application the rest of the thesis pipeline builds, tests, containerises and deploys: a small **Node.js + Express REST API** with an in-memory "items" store, a health endpoint, a version endpoint, automated tests and a lint step.

## Why it matters for DevOps jobs

- CI gates on scripts that exit non-zero on failure. `npm test` and `npm run lint` are what your GitHub Actions workflow calls in step 3.
- `/healthz` and `/version` are what Kubernetes probes and CD smoke tests call (steps 4–5).
- 12-factor config (`PORT`, `APP_VERSION` from env) lets the same image run locally, in Docker and in Kubernetes with a ConfigMap.
- Separating `app.js` (the app) from `server.js` (the listener) lets tests hit HTTP without opening ports, which keeps CI fast and stable.

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

- `id` must be unique (e.g. `crypto.randomUUID()`), and `createdAt` must be an ISO-8601 string.
- The server listens on `PORT` (default `3000`).

## Plan

### Stage 0: setup + `package.json` (30 min) → push

```bash
node -v                      # v22 or v24
git clone https://github.com/huncho-lab/devops-daily.git   # or: cd devops-daily && git fetch origin
cd devops-daily && git switch task/2026-11-09
cd thesis-pipeline/app
npm init -y                  # then edit package.json: "private": true, "engines": {"node": ">=22"}
npm i express
npm i -D jest supertest
```

Add `start` and `test` scripts, tick the setup section of `days/2026-11-09/NOTES.md`, commit (`package.json`, `package-lock.json`, `NOTES.md`) and push.
**Check:** `git log origin/task/2026-11-09` shows your commit. If the push fails, paste the exact error into Agent Hub and stop; fixing access is today's win (auth links under Resources).

### Stage 1: `src/store.js` (30 min) → push

Implement `list`, `create`, `get`, `remove`, `reset` as described in the file's TODOs.
**Check:** `node -e "const s=require('./src/store'); const i=s.create('a'); console.log(s.get(i.id), s.list().length, s.remove(i.id), s.remove(i.id))"` prints the item, `1`, `true`, `false` (adapt if you chose a factory or ES modules).

### Stage 2: `src/app.js` + `src/server.js` (75 min) → push

Every route in the table, the name validation, and a JSON 404 catch-all registered after the routes. `app.js` exports the app with no `listen()`; `server.js` reads `PORT`, calls `listen()` and logs the port and version.
**Check:** `npm start`, then `curl -i localhost:3000/healthz` and `curl -i localhost:3000/nope` (must be JSON). Then `PORT=4000 APP_VERSION=1.2.3 npm start` and `curl localhost:4000/version`.
Earns criteria 6, 7, 8 and 9 (with 1 and 10 from stage 0).

### Stage 3: `tests/app.test.js` + coverage (90 min) → push

1. Replace every `test.todo` with a real test (13 names given; at least 10 passing, no todo/skip). Reset the store in `beforeEach`; set and restore `process.env.APP_VERSION` inside the version tests.
2. Add `"test:coverage": "jest --coverage"` with `collectCoverageFrom` limited to `src/`. Decide whether `server.js` is excluded or tested and say why in the README. Reach 80% lines or more.

**Check:** `npm test` exits 0; `npm run test:coverage` shows ≥ 80% lines.
Earns criteria 2, 3 and 4.

### Stage 4: `eslint.config.js` + README (45 min) → push

1. `npm i -D eslint @eslint/js globals`, create `eslint.config.js` (flat config, Node and Jest globals), add `"lint": "eslint ."`, fix until 0 problems.
2. Fill in the `Sample app` section of `thesis-pipeline/README.md` and mark step 1 done in the pipeline table.
3. Clean check: `rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage`.
4. Finish `days/2026-11-09/NOTES.md`, push, then write "review now task/2026-11-09" in Agent Hub if it's before 21:12.

Earns criteria 5, 11 and 12.

**Stop rule:** at 20:45, push whatever you have. Partial work gets graded feedback; an empty branch gets none.

## Acceptance criteria (graded in the evening review)

- [ ] 1. `thesis-pipeline/app/package.json` and `package-lock.json` exist, and `cd thesis-pipeline/app && npm ci` succeeds on a clean checkout.
- [ ] 2. `npm test` runs Jest and exits `0`.
- [ ] 3. `tests/app.test.js` has **at least 10 passing tests** covering every row of the API table (including 400, 404 and the unknown-route case). No `test.skip` or `test.todo` left.
- [ ] 4. `npm run test:coverage` reports **80% or more line coverage** for `src/`.
- [ ] 5. `npm run lint` runs ESLint and exits `0` with no warnings.
- [ ] 6. `src/app.js` exports the app **without** calling `listen()`. `src/server.js` is the only file that calls `listen()`.
- [ ] 7. `PORT=4000 npm start` serves on port 4000, and `APP_VERSION=1.2.3 npm start` makes `GET /version` return `{"version":"1.2.3"}` (and `"dev"` when unset).
- [ ] 8. Unknown routes return a **JSON** 404, not HTML.
- [ ] 9. `POST /api/items` returns `400` for a missing, empty, non-string or over-100-character `name`.
- [ ] 10. `node_modules/` and `coverage/` are not committed (`.gitignore` present).
- [ ] 11. `thesis-pipeline/README.md` documents how to install, run, test and lint, plus the env vars and the endpoints.
- [ ] 12. At least **3 commits** of your own on `task/2026-11-09`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- Structured JSON request logging to stdout (method, path, status, duration in ms). Pays off in step 7.
- Graceful shutdown on `SIGTERM`: close the server, then exit. Kubernetes sends `SIGTERM` when a pod stops.
- A `/readyz` endpoint separate from `/healthz`, plus one README sentence on liveness vs readiness.
- Read ahead for tomorrow's step 2: Docker multi-stage builds (link below).

## Resources (official docs)

- GitHub: caching credentials for HTTPS: https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git
- GitHub: connecting with SSH: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- GitHub CLI `gh auth login`: https://cli.github.com/manual/gh_auth_login
- Express routing and error handling: https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express 5 API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started and coverage config: https://jestjs.io/docs/getting-started, https://jestjs.io/docs/configuration#collectcoveragefrom-array
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
- Node.js `crypto.randomUUID()`: https://nodejs.org/api/crypto.html#cryptorandomuuidoptions
- The Twelve-Factor App, Config: https://12factor.net/config
- Docker multi-stage builds (preview for step 2): https://docs.docker.com/build/building/multi-stage/

## Hints (not solutions)

- Supertest takes the app object directly (`request(app)`), so tests need no port.
- Express's built-in 404 page is HTML. A catch-all middleware registered **after** your routes fixes that.
- `typeof name === 'string'` plus a `trim()` length check covers most 400 cases. Think about what `{"name": 123}` and `{}` should do.
- In Express 5, `res.status(204).end()` sends no body, which is what the spec wants for `DELETE`.
- Pick CommonJS or ES modules once (`"type"` in `package.json`) and stay consistent. Jest works out of the box with CommonJS.
- Stuck on one thing for more than 20 minutes? Commit what you have, push, and post the question in Agent Hub.
