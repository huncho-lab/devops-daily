# Thesis step 1: REST API sample app with tests ("unstick" edition)

- **Date:** 2026-11-13 (Friday)
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours: **15 min unstick check**, then **C1 (30 min)**, **C2 (60 min)**, **C3 (~3.5 h)**
- **Branch:** `task/2026-11-13`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step (no commits of yours on the 31 Oct to 12 Nov branches), so the **API spec and the 12 acceptance criteria are unchanged**. Code you wrote anywhere else can be copied in.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

1. **A troubleshooting table comes first.** Thirteen briefs in a row haven't produced a push, so the likeliest problem is not the API but something before it: Node, the clone, Git login, or time. The table below maps each common blocker to the exact fix in the official docs. Spend 15 minutes on it before any code.
2. **A 3-day finish plan.** Friday to Sunday are the last thesis-track days under the default "keep 16 Nov":
   - **Fri 13 Nov (today):** C1 + C2, the pass line.
   - **Sat 14 Nov:** C3, the rest of step 1.
   - **Sun 15 Nov / Mon 16 Nov:** fixes from the review, merge step 1.
   Steps 2–8 then continue on your own time. From 17 Nov the routine moves to the Skills track unless you write "extend thesis to <date>" in Agent Hub (thread *tasks*).
3. **A one-line reply still changes everything.** "No time this week", "push fails with …", "drop the thesis track" — any of these in Agent Hub and tomorrow's brief adapts.

## Unstick check (15 min, no code) → push

Run each line. The first one that fails is today's real task:

```bash
node -v && npm -v                            # expect Node v22 or v24
git clone https://github.com/huncho-lab/devops-daily.git   # skip if already cloned
cd devops-daily && git fetch origin
git switch task/2026-11-13
git push --dry-run origin task/2026-11-13    # tests your GitHub login without changing anything
```

| Symptom | Likely cause | Fix (official docs) |
|---|---|---|
| `node: command not found` or a version below 20 | Node not installed / too old | https://nodejs.org/en/download (LTS installer, or nvm) |
| `fatal: invalid reference: task/2026-11-13` | Branch not fetched yet | `git fetch origin`, then switch again |
| `Authentication failed` / `Support for password authentication was removed` | GitHub no longer accepts passwords over HTTPS | Personal access token or credential manager: https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git |
| `Permission denied (publickey)` | SSH key not added to GitHub | https://docs.github.com/en/authentication/connecting-to-github-with-ssh |
| `remote: Permission to … denied` / `403` | Your account lacks write access to the repo | Check you're logged in as the repo owner: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/managing-teams-and-people-with-access-to-your-repository |
| `npm ERR! code EACCES` | npm writing to a root-owned folder | https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally |
| Everything works, but there's no time | — | Write "no time this week" in Agent Hub |

Tick the boxes in `days/2026-11-13/NOTES.md`, commit and push. **If any line fails, paste the exact error into Agent Hub** — that's a complete result for today.

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

Most real DevOps tickets start exactly like the unstick check: a pipeline or a colleague can't authenticate, a runner has the wrong Node version, a branch isn't fetched. Diagnosing from the exact error message is the core skill. And the app itself is what your thesis pipeline will build, test, scan and deploy: `npm ci`/`npm test`/`npm run lint` become CI steps (step 3), `/healthz` and `/version` become Kubernetes probes and CD smoke tests (steps 4–5).

## Plan

### C1: first push (30 min, criteria 1 and 10) → push

```bash
cd thesis-pipeline/app
npm init -y
npm i express
npm i -D jest supertest
```
In `package.json` set `"test": "jest --passWithNoTests"` for now (you remove the flag in C3). Commit `package.json` + `package-lock.json` and push.
**Check:** `git log origin/task/2026-11-13 --oneline` shows your commit, and `git status` does not list `node_modules/`.

### C2: the pass line (60 min, criteria 2, 6, 8) → push

- `src/store.js`: `list`, `create`, `reset` are enough for now.
- `src/app.js`: `/healthz`, `/version`, `GET`/`POST /api/items` (no validation yet), then the JSON 404 catch-all. Export the app; no `listen()` here.
- `src/server.js`: the only `listen()`. Add `"start": "node src/server.js"`.
- `tests/app.test.js`: turn **3** `test.todo` lines into real tests: healthz, version `"dev"`, unknown route → JSON 404.

**Check:** `npm start`, then `curl -i localhost:3000/healthz` and `curl -i localhost:3000/nope` (the second must say `Content-Type: application/json`). `npm test` exits 0.

### C3: finish step 1 (~3.5 h, may move to Saturday; criteria 3, 4, 5, 7, 9, 11, 12), push after each part

- **3a. Rest of the API (45 min):** `GET`/`DELETE /api/items/:id` with 404s, the full `400` validation, `PORT` from env.
- **3b. All tests + coverage (75 min):** every `test.todo` becomes a real test (≥ 10 passing, none left), remove `--passWithNoTests`, add `"test:coverage": "jest --coverage"` with `collectCoverageFrom: ["src/**/*.js"]` (excluding `server.js` is fine).
- **3c. ESLint (30 min):** flat config with Node + Jest globals, `"lint": "eslint ."`, 0 problems.
- **3d. README + clean check (40 min):** fill the *Sample app* section of `thesis-pipeline/README.md`, then:
  ```bash
  rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage
  ```

**Stop rule:** at 20:45, push whatever you have, then write "review now task/2026-11-13" in Agent Hub.

## Acceptance criteria (graded in the evening review)

Unstick (green = blocker found or ruled out):

- [ ] 0. `days/2026-11-13/NOTES.md` has the unstick boxes ticked (or the failing error pasted), committed by you and pushed to `task/2026-11-13`.

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
- [ ] 12. At least **3 commits** of your own on `task/2026-11-13`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

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
- `git push --dry-run`: https://git-scm.com/docs/git-push
- The Twelve-Factor App, Config: https://12factor.net/config

## Hints (not solutions)

- Express's built-in 404 is HTML. A catch-all middleware registered **after** your routes fixes that.
- Think about what `{"name": 123}`, `{"name": "   "}` and `{}` should each return.
- `res.status(204).end()` sends no body.
- Tests need a clean store each time: that's what `reset()` in the store skeleton is for (`beforeEach`).
- Pick CommonJS or ES modules once and stay consistent. Jest works out of the box with CommonJS.
- Stuck for 20 minutes? Commit, push, ask in Agent Hub.
