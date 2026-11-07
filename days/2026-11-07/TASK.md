# Thesis step 1: REST API sample app with tests (weekend ladder edition)

- **Date:** 2026-11-07 (Saturday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours, as a ladder of 5 rungs. Every rung ends with a push, and every rung unlocks graded criteria on its own.
- **Branch:** `task/2026-11-07`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step. The 31 Oct to 6 Nov branches have no commits of yours, so the **spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else (older branch, another folder) can be copied in here.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

- **A ladder, not a plan.** Each rung is small, ends in a push, and is useful even if you stop right after it. Rung 1 takes 15 minutes. The evening review gives real feedback on whatever rung you reach.
- **Saturday, so one long session is possible.** Suggested: rungs 1–3 before lunch, rungs 4–5 in the afternoon.
- **Schedule check (9 days to 16 Nov).** If step 1 is merged today, steps 2–8 run 8–14 Nov at one a day, with 2 buffer days. If it slips to tomorrow, there is 1 buffer day. From 9 Nov on, two steps have to be combined or shortened. Reply in Agent Hub (thread *tasks*) with "1 step per day", "smaller thesis tasks" or "2 days per step" and the next brief adapts. Without a reply, tomorrow's brief is decided by tonight's review.

## Goal

Build the sample application the rest of your thesis pipeline will build, test, containerise and deploy: a small **Node.js + Express REST API** with an in-memory "items" store, a health endpoint, a version endpoint, automated tests and a lint step. Docker (step 2), CI (step 3), Kind (step 4), the CD smoke test (step 5) and monitoring (step 7) all build on it.

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

## The ladder

### Rung 1: first push (15 min, no code)

```bash
node -v                      # v22 or v24
git clone https://github.com/huncho-lab/devops-daily.git   # or: cd devops-daily && git fetch origin
cd devops-daily && git switch task/2026-11-07
```

Fill in `days/2026-11-07/NOTES.md` (tick the boxes, one line on what's been in the way), then:

```bash
git add days/2026-11-07/NOTES.md
git commit -m "docs: day log for thesis step 1"
git push
```

If the push fails, paste the exact error into Agent Hub and stop. Fixing access is the win for today (see the GitHub auth links under Resources).

### Rung 2: first green test (45 min) → push

1. In `thesis-pipeline/app`: `npm init -y`, set `"private": true` and `"engines": {"node": ">=22"}`, then `npm i express` and `npm i -D jest supertest`. Add `"start"` and `"test"` scripts.
2. Write `GET /healthz` in `src/app.js` (export the app, no `listen()`).
3. Turn the first `test.todo` into a real Supertest test. `npm test` green → **commit and push**.

Unlocks criteria 1, 6 and 10, and starts 2 and 12.

### Rung 3: the whole API (75 min) → push

1. `src/store.js`: list, create, get, remove, reset.
2. The remaining routes in `src/app.js`, the name validation, and a JSON 404 catch-all registered after all routes.
3. `src/server.js`: read `PORT`, `listen()`, log the port and version.
4. Check by hand: `curl -i localhost:3000/nope` must be JSON; `PORT=4000 APP_VERSION=1.2.3 npm start` then `curl localhost:4000/version`.
5. **Commit and push.**

Unlocks criteria 7, 8 and 9.

### Rung 4: proven (90 min) → push

1. Replace every remaining `test.todo` with a real test (13 names given; at least 10 passing, no todo or skip). Reset the store in `beforeEach`; set and restore `process.env.APP_VERSION` inside the version tests.
2. Add `"test:coverage": "jest --coverage"` with `collectCoverageFrom` limited to `src/`. Decide whether `server.js` is excluded or tested and say why in the README. Reach 80% lines or more.
3. `npm i -D eslint @eslint/js globals`, create `eslint.config.js` (flat config, Node and Jest globals), add `"lint": "eslint ."`, fix until 0 problems.
4. **Commit and push.**

Unlocks criteria 2, 3, 4 and 5.

### Rung 5: documented and clean (45 min) → push

1. Fill in the `Sample app` section of `thesis-pipeline/README.md` and mark step 1 done in the pipeline table.
2. Clean check: `rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage`.
3. **Commit and push**, then write "review now task/2026-11-07" in Agent Hub if it's before 21:12.

Unlocks criteria 11 and 12.

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
- [ ] 12. At least **3 commits** of your own on `task/2026-11-07`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- Structured JSON request logging to stdout (method, path, status, duration in ms). Pays off in step 7.
- Graceful shutdown on `SIGTERM`: close the server, then exit. Kubernetes sends `SIGTERM` when a pod stops.
- A `/readyz` endpoint separate from `/healthz`, plus one README sentence on liveness vs readiness.
- Read ahead for step 2: Docker multi-stage builds (link below).

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
