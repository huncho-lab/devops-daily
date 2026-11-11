# Thesis step 1: REST API sample app with tests ("pass line" edition)

- **Date:** 2026-11-11 (Wednesday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours: a **2-hour pass line** first, then 3 hours to finish
- **Branch:** `task/2026-11-11`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step (no commits of yours on the 31 Oct to 10 Nov branches), so the **spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else can be copied in.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

1. **A pass line.** Earlier briefs asked for all 12 criteria in one day. Today the evening review marks the day as **passed** as soon as the 5 pass-line criteria (1, 2, 6, 8, 10) are green. That takes about 2 hours: a running app with a few real tests. The other 7 criteria are still graded, but they're the "finish" part.
2. **Default schedule decision.** You haven't replied yet, so the default is now **"keep 16 Nov"**: through 16 Nov the routine keeps setting the next unmerged thesis step, and from 17 Nov it switches to the Skills track. Whatever isn't merged by then you finish on your own. To change that, write one line in Agent Hub (thread *tasks*): "extend thesis to <date>" or "smaller thesis tasks". If something is blocking you (Git access, Node setup, time), one line saying what is enough.

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

`npm test` and `npm run lint` are exactly what CI runs (step 3). `/healthz` and `/version` are what Kubernetes probes and CD smoke tests call (steps 4–5). `PORT`/`APP_VERSION` from the environment is the 12-factor config a ConfigMap sets later. In interviews, "I built the app my pipeline deploys, and the pipeline tests it" is a far stronger story than a pipeline around someone else's demo.

## Plan

### Part 1: the pass line (~2 h, criteria 1, 2, 6, 8, 10)

**1a. Setup (20 min) → push**
```bash
node -v                                   # v22 or v24
git fetch origin && git switch task/2026-11-11
cd thesis-pipeline/app
npm init -y && npm i express && npm i -D jest supertest
```
Set `"test": "jest"` in `package.json`. Commit `package.json` + `package-lock.json` (the `.gitignore` already excludes `node_modules/`), push.
**Check:** `git log origin/task/2026-11-11` shows your commit.

**1b. `src/store.js` + `src/app.js` + `src/server.js` (60 min) → push**
Start with just `/healthz`, `/version`, `GET`/`POST /api/items` and the JSON 404 catch-all. Only `server.js` calls `listen()`.
**Check:** `npm start` (add the script), then `curl -i localhost:3000/healthz` and `curl -i localhost:3000/nope` (must be JSON).

**1c. First 4 real tests (40 min) → push**
Turn 4 of the `test.todo` lines into real Supertest tests (healthz, version "dev", POST creates, unknown route 404). Delete the remaining `test.todo` lines for now, or leave them: `todo` doesn't fail `npm test`.
**Check:** `npm test` exits 0. **That's the pass line.** Write "review now task/2026-11-11" in Agent Hub if you want feedback straight away.

### Part 2: finish (~3 h, criteria 3, 4, 5, 7, 9, 11, 12)

- **2a. Rest of the API (45 min) → push:** `GET`/`DELETE /api/items/:id` with 404s, the full 400 validation, `PORT`/`APP_VERSION` from env.
- **2b. All tests + coverage (75 min) → push:** every `test.todo` becomes a real test (≥ 10 passing, none left). Add `"test:coverage": "jest --coverage"` and `collectCoverageFrom: ["src/**/*.js"]` with `server.js` excluded if you like (it only calls `listen()`).
- **2c. ESLint + README + clean check (60 min) → push:** flat config with Node + Jest globals, `"lint": "eslint ."`, 0 problems. Fill the *Sample app* section of `thesis-pipeline/README.md`. Then:
  ```bash
  rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage
  ```

**Stop rule:** at 20:45, push whatever you have, then write "review now task/2026-11-11" in Agent Hub. Fill in `days/2026-11-11/NOTES.md` as you go.

## Acceptance criteria (graded in the evening review)

Pass line (all 5 green = day passed):

- [ ] 1. `thesis-pipeline/app/package.json` and `package-lock.json` exist, and `cd thesis-pipeline/app && npm ci` succeeds on a clean checkout.
- [ ] 2. `npm test` runs Jest and exits `0`.
- [ ] 6. `src/app.js` exports the app **without** calling `listen()`. `src/server.js` is the only file that calls `listen()`.
- [ ] 8. Unknown routes return a **JSON** 404, not HTML.
- [ ] 10. `node_modules/` and `coverage/` are not committed (`.gitignore` present).

Finish (needed to merge step 1):

- [ ] 3. `tests/app.test.js` has **at least 10 passing tests** covering every row of the API table (including 400, 404 and the unknown-route case). No `test.skip` or `test.todo` left.
- [ ] 4. `npm run test:coverage` reports **80% or more line coverage** for `src/`.
- [ ] 5. `npm run lint` runs ESLint and exits `0` with no warnings.
- [ ] 7. `PORT=4000 npm start` serves on port 4000, and `APP_VERSION=1.2.3 npm start` makes `GET /version` return `{"version":"1.2.3"}` (and `"dev"` when unset).
- [ ] 9. `POST /api/items` returns `400` for a missing, empty, non-string or over-100-character `name`.
- [ ] 11. `thesis-pipeline/README.md` documents how to install, run, test and lint, plus the env vars and the endpoints.
- [ ] 12. At least **3 commits** of your own on `task/2026-11-11`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- JSON request logging (method, path, status, ms), useful in step 7.
- Graceful `SIGTERM` shutdown: Kubernetes sends it when a pod stops.
- `/readyz` separate from `/healthz`, plus one README line on liveness vs readiness.

## Resources (official docs)

- Express hello world, routing, error handling: https://expressjs.com/en/starter/hello-world.html, https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express 5 API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started and `collectCoverageFrom`: https://jestjs.io/docs/getting-started, https://jestjs.io/docs/configuration#collectcoveragefrom-array
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
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
