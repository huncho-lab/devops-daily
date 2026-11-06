# Thesis step 1: REST API sample app with tests (unblock edition)

- **Date:** 2026-11-06
- **Track:** Thesis track (step 1 of 8)
- **Estimated time:** ~5 hours, as a 20-min setup check followed by two 2-hour blocks and a 40-min finish. Each block ends with a push.
- **Branch:** `task/2026-11-06`
- **Work folder:** `thesis-pipeline/app/`
- **Status:** step 1 is still the next unmerged step. The 31 Oct to 5 Nov branches have no commits of yours, so the **spec and the 12 acceptance criteria are unchanged**. If you wrote code on an older branch or outside the repo, copy it in here.

> Own-work rule: this is your thesis implementation. The skeleton files contain only TODO comments and test *names*. You write all the code yourself.

## What's different today

Six briefs in a row have had zero pushes. That usually means something before the coding is blocking you: setup, Git access, or how big the task feels. So today starts by **proving the push path works**, and then the API work is split into two blocks with a push after each.

1. **Setup check, 20 min, needs no code.** Confirm Node, the clone, the branch and that `git push` works. If something fails, write the exact error in Agent Hub (thread *tasks*). Fixing it is today's real win.
2. **Two blocks instead of four milestones.** Block A ("it runs") covers 6 of the 12 criteria. Block B ("it's proven") covers the rest.
3. **Still on schedule.** If step 1 is merged today, one step a day puts step 8 on 13 Nov with 3 buffer days (step 2 on 7 Nov, step 3 on 8 Nov … step 8 on 13 Nov). If you can't do 5 h a day, reply in Agent Hub with "smaller thesis tasks" or "2 days per step". Without a reply, tomorrow stays at 1 step per day.

## Goal

Build the sample application the rest of your thesis pipeline will build, test, containerise and deploy. It's a small **Node.js + Express REST API** with an in-memory "items" store, a health endpoint, a version endpoint, automated tests and a lint step. It must be testable, configured through environment variables and quick to start, because Docker (step 2), CI (step 3), Kind (step 4), the CD smoke test (step 5) and monitoring (step 7) all build on it.

## Why it matters for DevOps jobs

- CI gates on scripts that exit non-zero on failure. `npm test` and `npm run lint` are exactly what your GitHub Actions workflow will call in step 3.
- `/healthz` and `/version` are what Kubernetes probes and CD smoke tests call (steps 4–5).
- 12-factor config (`PORT` and `APP_VERSION` from env) lets the same image run locally, in Docker, and in Kubernetes with a ConfigMap.
- Keeping `app.js` (the app) separate from `server.js` (the listener) lets you test HTTP without opening ports, which keeps CI fast and stable.

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

### 0. Setup check (20 min) → push

```bash
node -v            # want v24.x (LTS); v22 also works for this step
git --version
git clone https://github.com/huncho-lab/devops-daily.git   # or: cd devops-daily && git fetch origin
cd devops-daily && git switch task/2026-11-06
```

1. Fill in `days/2026-11-06/NOTES.md`: tick the setup checks and write one line on what blocked the earlier days.
2. `git add days/2026-11-06/NOTES.md && git commit -m "docs: setup check for thesis step 1" && git push`
3. **If the push fails** (authentication, "permission denied", "rejected"), copy the exact error into Agent Hub and stop here until it's fixed. Common fixes: sign in with `gh auth login` or a personal access token (HTTPS), or add an SSH key. See the GitHub links under Resources.

### Block A: "it runs" (~2 h) → commit + push after each numbered item

1. In `thesis-pipeline/app`, run `npm init -y`, set `"private": true` and `"engines": {"node": ">=22"}`, then `npm i express` and `npm i -D jest supertest`. Add the scripts `"start"` and `"test"`.
2. Write `GET /healthz` in `src/app.js` and turn the first `test.todo` into a real Supertest test. Once `npm test` is green, **commit and push**. That's your first code commit.
3. Write `src/store.js` (list, create, get, remove, reset), the rest of the routes, the name validation and a JSON 404 catch-all in `src/app.js`. Then write `src/server.js` (read `PORT`, `listen()`, log the port and version). **Commit and push.**
4. Check by hand: `curl -i localhost:3000/healthz`, `curl -i -X POST -H 'Content-Type: application/json' -d '{"name":"x"}' localhost:3000/api/items`, `curl -i localhost:3000/nope` (must be JSON), and `PORT=4000 APP_VERSION=1.2.3 npm start` followed by `curl localhost:4000/version`.

Block A covers criteria 1, 6, 7, 8, 9 and 10 (and starts 12).

### Block B: "it's proven" (~2 h) → commit + push

1. Replace every remaining `test.todo` with a real test (13 names are given; you need at least 10 passing and no todo or skip left). Reset the store in `beforeEach`. For `/version`, set or unset `process.env.APP_VERSION` inside the test and restore it afterwards. **Commit and push.**
2. Add `"test:coverage": "jest --coverage"` with `collectCoverageFrom` limited to `src/`. Decide whether `server.js` is excluded or tested, and say why in the README. Get to 80% lines or more.
3. Run `npm i -D eslint @eslint/js globals`, create `eslint.config.js` (flat config, Node and Jest globals), add `"lint": "eslint ."` and fix until there are 0 problems. **Commit and push.**

Block B covers criteria 2, 3, 4 and 5.

### Finish (~40 min) → commit + push

1. Fill in the `Sample app` section of `thesis-pipeline/README.md` and mark step 1 done in the pipeline table.
2. Clean check: `rm -rf node_modules coverage && npm ci && npm run lint && npm test && npm run test:coverage`.
3. **Commit and push**, then write "review now task/2026-11-06" in Agent Hub if it's before 21:12.

**Stop rule:** at 20:45, push whatever you have, finished or not. Partial work gets real feedback. An empty branch gets none.

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
- [ ] 12. At least **3 commits** of your own on `task/2026-11-06`, with all code written by you and no TODO-only files left in `src/` or `tests/`.

## Stretch goals

- Structured JSON request logging to stdout (method, path, status, duration in ms). This pays off in step 7.
- Graceful shutdown on `SIGTERM`: close the server, then exit. Kubernetes sends `SIGTERM` when a pod stops.
- A `/readyz` endpoint separate from `/healthz`, plus one README sentence on liveness vs readiness.
- Read ahead for step 2: Docker multi-stage builds (link below).

## Resources (official docs)

- GitHub: authenticating with Git over HTTPS (tokens): https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git
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
- `typeof name === 'string'` plus a `trim()` length check covers most of the 400 cases. Think about what `{"name": 123}` and `{}` should do.
- In Express 5, `res.status(204).end()` sends no body, which is what the spec wants for `DELETE`.
- Choose CommonJS or ES modules once (the `"type"` field in `package.json`) and stay consistent. Jest works out of the box with CommonJS.
- Stuck on one thing for more than 20 minutes? Commit what you have, push, and post the question in Agent Hub.
