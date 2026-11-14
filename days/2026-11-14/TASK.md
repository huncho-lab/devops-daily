# Thesis step 1: REST API sample app with tests ("last weekend" edition)

- **Date:** 2026-11-14 (Saturday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours: **10 min first push**, then **C1 (30 min)**, **C2 (60 min)**, **C3 (~3.5 h, may move to Sunday)**
- **Branch:** `task/2026-11-14`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step (no commits of yours on the 31 Oct to 13 Nov branches), so the **API spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else can be copied in.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

1. **This brief is short on purpose.** The full troubleshooting table from 13 Nov is still on branch `task/2026-11-13` if a command fails. Today's brief is just: one 10-minute push, then the same three checkpoints.
2. **Three thesis-track days left (Sat 14, Sun 15, Mon 16 Nov).** The finish plan:
   - **Sat 14 Nov (today):** first push + C1 + C2, the pass line.
   - **Sun 15 Nov:** C3, the rest of step 1.
   - **Mon 16 Nov:** fixes from the review, merge step 1.
3. **From Tue 17 Nov the routine switches to the Skills track** (Docker, GitHub Actions, AWS, Kubernetes, … rotating) unless you write **"extend thesis to <date>"** in Agent Hub, thread *tasks*. Other one-liners that change tomorrow's brief: **"no time until <date>"**, **"skills track now"**, **"push fails with …"**.

## First push (10 min, no code) → criterion 0

```bash
git fetch origin && git switch task/2026-11-14
# open days/2026-11-14/NOTES.md, fill in the 3 lines at the top
git add days/2026-11-14/NOTES.md && git commit -m "notes: start 2026-11-14" && git push
```

If any command fails, paste its exact output into Agent Hub (thread *tasks* or *review*). That alone is a complete result for today: it tells us what to fix.

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

`id` is unique (e.g. `crypto.randomUUID()`), `createdAt` is an ISO-8601 string, and the server listens on `PORT` (default `3000`).

## Why it matters for DevOps jobs

Every pipeline in your thesis (and in a job like AGCO's DevOps intern role) needs something to build, test and deploy. `npm ci` / `npm test` / `npm run lint` become your CI steps (step 3), `/healthz` and `/version` become Kubernetes liveness/readiness probes and the CD smoke test (steps 4–5), and `PORT`/`APP_VERSION` from env is the Twelve-Factor config pattern every container platform expects.

## Plan

### C1: started (30 min, criteria 1 and 10) → push

```bash
cd thesis-pipeline/app
npm init -y
npm i express
npm i -D jest supertest
```
Set `"test": "jest --passWithNoTests"` for now (removed in C3). Commit `package.json` + `package-lock.json`, push.
**Check:** `git status` does not list `node_modules/`.

### C2: pass line (60 min, criteria 2, 6, 8) → push

- `src/store.js`: `list`, `create`, `reset` are enough for now.
- `src/app.js`: `/healthz`, `/version`, `GET`/`POST /api/items`, then the JSON 404 catch-all. Export the app; no `listen()`.
- `src/server.js`: the only `listen()`. Add `"start": "node src/server.js"`.
- `tests/app.test.js`: turn **3** `test.todo` lines into real tests (healthz, version `"dev"`, unknown route).

**Check:** `npm start`, then `curl -i localhost:3000/nope` shows `Content-Type: application/json`. `npm test` exits 0.

### C3: finish step 1 (~3.5 h, Sunday is fine; criteria 3, 4, 5, 7, 9, 11, 12), push after each part

- **3a. Rest of the API (45 min):** `GET`/`DELETE /api/items/:id` with 404s, full `400` validation, `PORT` from env.
- **3b. All tests + coverage (75 min):** every `test.todo` becomes a real test (≥ 10, none left), remove `--passWithNoTests`, add `"test:coverage": "jest --coverage"` with `collectCoverageFrom: ["src/**/*.js"]` (excluding `server.js` is fine).
- **3c. ESLint (30 min):** flat config with Node + Jest globals, `"lint": "eslint ."`, 0 problems.
- **3d. README + clean check (40 min):** fill the *Sample app* section of `thesis-pipeline/README.md`, then:
  ```bash
  rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage
  ```

**Stop rule:** at 20:45, push whatever you have, then write "review now task/2026-11-14" in Agent Hub.

## Acceptance criteria (graded in the evening review)

First push:

- [ ] 0. `days/2026-11-14/NOTES.md` has the 3 top lines filled in (or a failing command's error pasted), committed by you and pushed to `task/2026-11-14`.

C1, started (0 + both green = day started):

- [ ] 1. `thesis-pipeline/app/package.json` and `package-lock.json` exist, and `cd thesis-pipeline/app && npm ci` succeeds on a clean checkout.
- [ ] 10. `node_modules/` and `coverage/` are not committed (`.gitignore` present).

C2, pass line (0, 1, 10 plus these three = day passed):

- [ ] 2. `npm test` runs Jest and exits `0`.
- [ ] 6. `src/app.js` exports the app **without** calling `listen()`. `src/server.js` is the only file that calls `listen()`.
- [ ] 8. Unknown routes return a **JSON** 404, not HTML.

C3, finish (needed to merge step 1):

- [ ] 3. `tests/app.test.js` has **at least 10 passing tests** covering every row of the API table (including 400, 404 and the unknown-route case). No `test.skip` or `test.todo` left, and no `--passWithNoTests`.
- [ ] 4. `npm run test:coverage` reports **80% or more line coverage** for `src/`.
- [ ] 5. `npm run lint` runs ESLint and exits `0` with no warnings.
- [ ] 7. `PORT=4000 npm start` serves on port 4000, and `APP_VERSION=1.2.3 npm start` makes `GET /version` return `{"version":"1.2.3"}` (and `"dev"` when unset).
- [ ] 9. `POST /api/items` returns `400` for a missing, empty, non-string or over-100-character `name`.
- [ ] 11. `thesis-pipeline/README.md` documents how to install, run, test and lint, plus the env vars and the endpoints.
- [ ] 12. At least **3 commits** of your own on `task/2026-11-14`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- JSON request logging (method, path, status, ms), useful in step 7.
- Graceful `SIGTERM` shutdown: Kubernetes sends it when a pod stops.
- `/readyz` separate from `/healthz`, plus one README line on liveness vs readiness.

## Resources (official docs)

- Express hello world, routing, error handling: https://expressjs.com/en/starter/hello-world.html, https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express 5 API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started, CLI and `collectCoverageFrom`: https://jestjs.io/docs/getting-started, https://jestjs.io/docs/cli, https://jestjs.io/docs/configuration#collectcoveragefrom-array
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `init`, `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-init, https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
- GitHub credentials (if `git push` asks for a password): https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git
- The Twelve-Factor App, Config: https://12factor.net/config

## Hints (not solutions)

- Express's built-in 404 is HTML. A catch-all middleware registered **after** your routes fixes that.
- Think about what `{"name": 123}`, `{"name": "   "}` and `{}` should each return.
- `res.status(204).end()` sends no body.
- Tests need a clean store each time: that's what `reset()` in the store skeleton is for (`beforeEach`).
- Pick CommonJS or ES modules once and stay consistent. Jest works out of the box with CommonJS.
- Stuck for 20 minutes? Commit, push, ask in Agent Hub.
