# Thesis step 1: REST API sample app with tests ("start from the official docs" edition)

- **Date:** 2026-11-10 (Tuesday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours (timed stages below). The first 45 minutes need no thesis code at all.
- **Branch:** `task/2026-11-10`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step (no commits of yours on the 31 Oct to 9 Nov branches), so the **spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else can be copied in.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

1. **Start from the official docs, not a blank file.** Stage 0 is: follow Express's own "Hello world" page and Jest's own "Getting started" page inside `thesis-pipeline/app/`. Typing in the official examples is fine (they're the docs, not thesis code), and when you're done you have a running server and a green test. Then you change them into the thesis app.
2. **Shorter brief.** Spec, plan, criteria. Everything else from earlier briefs is still valid but not repeated.
3. **A decision only you can make (one line in Agent Hub, thread *tasks*).** 10–16 Nov leaves 7 days, including today. The routine switches to the **Skills track on 17 Nov**, so without a reply the thesis steps after 16 Nov won't be scheduled. Pick one:
   - **"extend thesis to 30 Nov"** (or any date): one thesis step per day continues until then.
   - **"smaller thesis tasks"**: ~2–3 h per day; steps 6–8 trimmed to the minimum by 16 Nov.
   - **"keep 16 Nov"**: whatever is merged by 16 Nov is what the routine covers; you finish the rest on your own.
   - Or say what's actually blocking you (Git access, Node setup, time, the thesis track itself) and tomorrow's task will deal with that instead.

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

`npm test` / `npm run lint` are what CI runs (step 3); `/healthz` and `/version` are what Kubernetes probes and CD smoke tests call (steps 4–5); `PORT`/`APP_VERSION` from env is the 12-factor config a ConfigMap sets later. Every later thesis step builds on this app.

## Plan

### Stage 0: official examples (45 min) → push

```bash
node -v                                   # v22 or v24
git fetch origin && git switch task/2026-11-10
cd thesis-pipeline/app
npm init -y && npm i express && npm i -D jest supertest
```

1. Follow https://expressjs.com/en/starter/hello-world.html in a scratch file, run it, open `localhost:3000`. Then delete the scratch file.
2. Follow https://jestjs.io/docs/getting-started (the `sum` example) and make `npm test` green. Delete the example files after.
3. Commit `package.json` + `package-lock.json` (not `node_modules/`), push, tick stage 0 in `days/2026-11-10/NOTES.md`.

**Check:** `git log origin/task/2026-11-10` shows your commit. If the push fails, paste the exact error into Agent Hub. That *is* today's win.

### Stage 1: `src/store.js` (30 min) → push
Plain JavaScript, no HTTP. **Check:** create an item from `node -e`, then `get`, `list().length`, `remove` twice → item, `1`, `true`, `false`.

### Stage 2: `src/app.js` + `src/server.js` (75 min) → push
All routes, the 400 validation, a JSON 404 catch-all after the routes. Only `server.js` calls `listen()`.
**Check:** `curl -i localhost:3000/nope` is JSON; `PORT=4000 APP_VERSION=1.2.3 npm start` then `curl localhost:4000/version`.

### Stage 3: `tests/app.test.js` + coverage (90 min) → push
Turn the 13 `test.todo` names into real Supertest tests (`request(app)`, no port). Add `test:coverage` with `collectCoverageFrom` limited to `src/`. **Check:** ≥ 10 passing, ≥ 80% lines.

### Stage 4: ESLint + README (40 min) → push
Flat config with Node + Jest globals, `"lint": "eslint ."`, 0 problems. Fill the `Sample app` section of `thesis-pipeline/README.md`. Clean check: `rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage`.

**Stop rule:** at 20:45, push whatever you have, then write "review now task/2026-11-10" in Agent Hub.

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
- [ ] 12. At least **3 commits** of your own on `task/2026-11-10`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- JSON request logging (method, path, status, ms) — useful in step 7.
- Graceful `SIGTERM` shutdown — Kubernetes sends it when a pod stops.
- `/readyz` separate from `/healthz`, with one README line on liveness vs readiness.

## Resources (official docs)

- Express hello world, routing, error handling: https://expressjs.com/en/starter/hello-world.html, https://expressjs.com/en/guide/routing.html, https://expressjs.com/en/guide/error-handling.html
- Express 5 API (`express.json()`): https://expressjs.com/en/5x/api.html
- Jest getting started and `collectCoverageFrom`: https://jestjs.io/docs/getting-started, https://jestjs.io/docs/configuration#collectcoveragefrom-array
- Supertest: https://github.com/forwardemail/supertest#readme
- ESLint flat config: https://eslint.org/docs/latest/use/configure/configuration-files
- npm `ci` and scripts: https://docs.npmjs.com/cli/commands/npm-ci, https://docs.npmjs.com/cli/using-npm/scripts
- Node.js `crypto.randomUUID()`: https://nodejs.org/api/crypto.html#cryptorandomuuidoptions
- Git over HTTPS / SSH: https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git, https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- The Twelve-Factor App, Config: https://12factor.net/config

## Hints (not solutions)

- Express's built-in 404 is HTML; a catch-all middleware registered **after** your routes fixes that.
- Think about what `{"name": 123}`, `{"name": "   "}` and `{}` should each return.
- `res.status(204).end()` sends no body.
- Pick CommonJS or ES modules once and stay consistent; Jest works out of the box with CommonJS.
- Stuck for 20 minutes? Commit, push, ask in Agent Hub.
