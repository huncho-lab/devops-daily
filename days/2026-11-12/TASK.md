# Thesis step 1: REST API sample app with tests ("first hour" edition)

- **Date:** 2026-11-12 (Thursday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours, as three checkpoints: **C1 (30 min)**, **C2 (60 min)**, **C3 (~3.5 h)**
- **Branch:** `task/2026-11-12`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step (no commits of yours on the 31 Oct to 11 Nov branches), so the **API spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else can be copied in.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

1. **The first hour is all that counts as "started".** Checkpoint C1 is 30 minutes and needs no API code at all: `npm init`, install, one command in `package.json`, push. If C1 is on GitHub tonight, the review marks the day as **started**. If C2 is there too, the day is **passed**.
2. **Honest schedule.** Thursday to Sunday (12–16 Nov) are the last thesis-track days under the default "keep 16 Nov". Step 1 can still be merged by then; steps 2–8 will not fit and continue on your own time. From 17 Nov the routine moves to the Skills track unless you write "extend thesis to <date>" in Agent Hub (thread *tasks*).
3. **One-line replies are enough.** If something is blocking you (no time this week, Git or Node setup, the thesis track itself), write one line in Agent Hub. The next brief changes to fit.

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

`npm ci`, `npm test` and `npm run lint` are exactly the commands a CI job runs (step 3). `/healthz` and `/version` are what Kubernetes probes and CD smoke tests call (steps 4–5). Reading `PORT`/`APP_VERSION` from the environment is the 12-factor config a ConfigMap sets later. In an internship interview (e.g. AGCO's IT DevOps role), "I built the app my pipeline deploys, and the pipeline tests it" is a much stronger story than a pipeline around someone else's demo.

## Plan

### C1: first push (30 min, criteria 1 and 10) → push

```bash
node -v                                   # v22 or v24
git fetch origin && git switch task/2026-11-12
cd thesis-pipeline/app
npm init -y
npm i express
npm i -D jest supertest
```
In `package.json` set `"test": "jest --passWithNoTests"` for now (you remove the flag in C3). Commit `package.json` + `package-lock.json` and push.
**Check:** `git log origin/task/2026-11-12 --oneline` shows your commit, and `git status` does not list `node_modules/`.
If `git push` fails, copy the exact error into Agent Hub: that error is today's most useful result.

### C2: the pass line (60 min, criteria 2, 6, 8) → push

- `src/store.js`: `list`, `create`, `reset` are enough for now.
- `src/app.js`: `/healthz`, `/version`, `GET`/`POST /api/items` (no validation yet), then the JSON 404 catch-all. Export the app; no `listen()` here.
- `src/server.js`: the only `listen()`. Add `"start": "node src/server.js"`.
- `tests/app.test.js`: turn **3** `test.todo` lines into real tests: healthz, version `"dev"`, unknown route → JSON 404.

**Check:** `npm start`, then `curl -i localhost:3000/healthz` and `curl -i localhost:3000/nope` (the second must say `Content-Type: application/json`). `npm test` exits 0.
That is the pass line. Write "review now task/2026-11-12" in Agent Hub if you want feedback before the evening.

### C3: finish step 1 (~3.5 h, criteria 3, 4, 5, 7, 9, 11, 12), push after each part

- **3a. Rest of the API (45 min):** `GET`/`DELETE /api/items/:id` with 404s, the full `400` validation, `PORT` from env.
- **3b. All tests + coverage (75 min):** every `test.todo` becomes a real test (≥ 10 passing, none left), remove `--passWithNoTests`, add `"test:coverage": "jest --coverage"` with `collectCoverageFrom: ["src/**/*.js"]` (excluding `server.js` is fine).
- **3c. ESLint (30 min):** flat config with Node + Jest globals, `"lint": "eslint ."`, 0 problems.
- **3d. README + clean check (40 min):** fill the *Sample app* section of `thesis-pipeline/README.md`, then:
  ```bash
  rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage
  ```

**Stop rule:** at 20:45, push whatever you have, then write "review now task/2026-11-12" in Agent Hub. Fill in `days/2026-11-12/NOTES.md` as you go (2 minutes per checkpoint).

## Acceptance criteria (graded in the evening review)

C1, started (both green = day started):

- [ ] 1. `thesis-pipeline/app/package.json` and `package-lock.json` exist, and `cd thesis-pipeline/app && npm ci` succeeds on a clean checkout.
- [ ] 10. `node_modules/` and `coverage/` are not committed (`.gitignore` present).

C2, pass line (1, 10 plus these three = day passed):

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
- [ ] 12. At least **3 commits** of your own on `task/2026-11-12`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- JSON request logging (method, path, status, ms), useful in step 7.
- Graceful `SIGTERM` shutdown: Kubernetes sends it when a pod stops.
- `/readyz` separate from `/healthz`, plus one README line on liveness vs readiness.

## Resources (official docs)

- Express hello world, routing, error handling: https://expressjs.com/en/starter/hello-world.html, https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express 5 API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started, CLI (`--passWithNoTests`) and `collectCoverageFrom`: https://jestjs.io/docs/getting-started, https://jestjs.io/docs/cli, https://jestjs.io/docs/configuration#collectcoveragefrom-array
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `init`, `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-init, https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
- Node.js `crypto.randomUUID()`: https://nodejs.org/api/crypto.html#cryptorandomuuidoptions
- Git credentials (HTTPS / SSH): https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git, https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- The Twelve-Factor App, Config: https://12factor.net/config

## Hints (not solutions)

- Express's built-in 404 is HTML. A catch-all middleware registered **after** your routes fixes that.
- Think about what `{"name": 123}`, `{"name": "   "}` and `{}` should each return.
- `res.status(204).end()` sends no body.
- Tests need a clean store each time: that's what `reset()` in the store skeleton is for (`beforeEach`).
- Pick CommonJS or ES modules once and stay consistent. Jest works out of the box with CommonJS.
- Stuck for 20 minutes? Commit, push, ask in Agent Hub.
