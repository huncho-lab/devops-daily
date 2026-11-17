# Docker fundamentals: a hardened nginx status-page container

- **Date:** 2026-11-17 (Tuesday)
- **Track:** Skills track, day 1 (topic: **Docker**)
- **Estimated time:** ~5 hours: **10 min first push**, **C1 (60 min)**, **C2 (90 min)**, **C3 (~2 h 30 min)**, 10 min buffer
- **Branch:** `task/2026-11-17`
- **Work folder:** `skills/docker-statuspage/`

> The skeleton files contain only TODO comments describing *what* each file must do. You write every line of Dockerfile, nginx config, Compose file, script and page yourself. Use the official docs linked at the bottom.

## What's new

- **The thesis track ended yesterday (default), so today is the first Skills-track day.** Thesis step 1 is still waiting on `task/2026-11-16`. You can push it there any time and say `review now task/2026-11-16` in Agent Hub.
- **Want the thesis back?** Write one line in Agent Hub, thread *tasks*: **"extend thesis to <date>"** or **"thesis + skills"** (alternate days). Otherwise the skills rotation continues (GitHub Actions, AWS serverless, Kubernetes, Linux, monitoring, Azure DevOps, GCP, incident drills).
- **No Node, no npm, no tests framework today.** Only Docker, one config file, one HTML page and one bash script. It is deliberately a different, smaller toolchain, so if Node setup was what blocked you, it can't block you today.
- **No overlap with your thesis.** Thesis step 2 (Dockerfile for the thesis API) stays your own thesis work. Today's container is a separate static site.

## Goal

Build a small, production-style container image for a static status page served by nginx: non-root, pinned base image, health check, OCI labels, security headers, a read-only Compose deployment and a scripted smoke test that proves all of it.

## Why it matters for DevOps jobs

The AGCO IT DevOps intern posting (and almost every junior DevOps role) lists Docker and Linux servers. Interviewers ask exactly these questions: *Why not run as root? Why not `:latest`? What does HEALTHCHECK do and who uses it? What is the build context, and why `.dockerignore`? How do you verify a container works before you ship it?* After today you can answer each one with a repo link. The smoke script is also what a CI job runs, so it carries straight into the GitHub Actions day.

## First push (10 min, no code) → criterion 0

```bash
git fetch origin && git switch task/2026-11-17
# open days/2026-11-17/NOTES.md and fill in the 3 lines at the top
git add days/2026-11-17/NOTES.md && git commit -m "notes: start 2026-11-17" && git push
```

If any command fails, paste its exact output into Agent Hub (thread *tasks* or *review*). That counts as today's result.

### Unstick table

| Symptom | Official fix |
|---|---|
| `docker: command not found` (Windows/macOS) | Install Docker Desktop: docs.docker.com/desktop |
| `permission denied ... /var/run/docker.sock` (Linux) | Linux post-install steps (docker group): docs.docker.com/engine/install/linux-postinstall |
| No admin rights / no Docker on your laptop | Open the repo in **GitHub Codespaces** (Code → Codespaces → Create). Docker is preinstalled: docs.github.com/codespaces |
| `bind: address already in use` | Another process uses 8080. Use `-p 18080:8080` or `HOST_PORT=18080` |
| `git push` asks for a password / 403 | GitHub no longer accepts passwords. Use a personal access token or SSH: docs.github.com/authentication |
| `shellcheck: command not found` | `sudo apt install shellcheck`, `brew install shellcheck`, or run it in Codespaces |

## Plan (timed)

| Time | Block | What you do | Criteria | Push? |
|---|---|---|---|---|
| 0:00–0:10 | First push | NOTES.md, 3 lines | 0 | yes |
| 0:10–0:40 | C1a | Write `site/index.html` and `nginx/default.conf` (port 8080, `/healthz`) | 2, 3 | – |
| 0:40–1:10 | C1b | Minimal `Dockerfile`, `docker build`, `docker run -d -p 8080:8080`, `curl` both URLs | 1, 2, 3 | **yes: pass line** |
| 1:10–1:40 | C2a | Switch to a non-root nginx base pinned to an exact tag; check `id -u` | 4, 5 | yes |
| 1:40–2:10 | C2b | `HEALTHCHECK`, `ARG APP_VERSION`, OCI labels; check with `docker inspect` | 6, 8 | yes |
| 2:10–2:40 | C2c | Security headers + hidden nginx version, `.dockerignore`; check with `curl -I` | 7, 9 | yes |
| 2:40–3:20 | C3a | `compose.yaml`: build arg, `HOST_PORT`, restart, `read_only` + tmpfs, healthy | 10, 11 | yes |
| 3:20–4:20 | C3b | `scripts/smoke.sh` with `trap` cleanup, 7 checks, shellcheck clean | 12 | yes |
| 4:20–4:50 | C3c | Measure image size + build times, write README | 13, 14 | yes |
| 4:50–5:00 | Clean check | Run the clean check below from a fresh clone | 15 | yes |

**Stop rule:** at 20:45, commit and push whatever you have. The review at 21:12 grades what is on the branch.

### Clean check (run from `skills/docker-statuspage/`)

```bash
docker build --build-arg APP_VERSION=1.0.0 -t statuspage:dev .
bash scripts/smoke.sh && shellcheck scripts/smoke.sh
HOST_PORT=18081 docker compose up -d --build && sleep 20 && docker compose ps && docker compose down
```

## Acceptance criteria (the evening review grades exactly these)

All paths are relative to `skills/docker-statuspage/` unless stated.

**First push**
- [ ] **0.** `days/2026-11-17/NOTES.md` has the 3 top lines filled in (or an error pasted in Agent Hub), committed by you and pushed.

**C1, pass line**
- [ ] **1.** `docker build -t statuspage:dev .` succeeds from a clean checkout.
- [ ] **2.** With `docker run -d -p 8080:8080 statuspage:dev`, `curl -fsS localhost:8080/` returns your HTML page containing the text `devops-daily status`.
- [ ] **3.** `curl -fsS localhost:8080/healthz` returns HTTP 200 with body exactly `ok`, and `curl -o /dev/null -w '%{http_code}' localhost:8080/nope` prints `404`.

**C2, hardened image**
- [ ] **4.** The container does not run as root: `docker run --rm statuspage:dev id -u` prints a number other than `0`.
- [ ] **5.** Every `FROM` uses an exact version tag (e.g. `x.y.z-alpine`): no `latest`, no untagged image.
- [ ] **6.** The Dockerfile has a `HEALTHCHECK` that calls `/healthz`, and `docker inspect --format '{{.State.Health.Status}}' <container>` shows `healthy` within 30 s of start.
- [ ] **7.** `.dockerignore` exists and excludes at least `.git`, `README.md`, `scripts/` and `compose.yaml`.
- [ ] **8.** `docker build --build-arg APP_VERSION=1.2.3 ...` produces an image whose `org.opencontainers.image.version` label is `1.2.3` (and `dev` without the build arg). Labels `org.opencontainers.image.source` and `org.opencontainers.image.title` are set too.
- [ ] **9.** `curl -sI localhost:8080/` shows `X-Content-Type-Options: nosniff` and `X-Frame-Options: DENY`, and the `Server` header does not contain an nginx version number.

**C3, deploy + verify**
- [ ] **10.** `docker compose up -d --build` starts service `web` on host port `${HOST_PORT}` (default `8080`), passing `APP_VERSION` as a build arg (default `dev`), with `restart: unless-stopped`.
- [ ] **11.** The `web` service has `read_only: true` with tmpfs mounts only where nginx needs to write, and `docker compose ps` shows it `healthy` within 30 s.
- [ ] **12.** `bash scripts/smoke.sh` builds, starts, waits for healthy, runs all the checks listed in the script's TODO, prints one PASS/FAIL line per check, cleans up the container even on failure, and exits 0. `shellcheck scripts/smoke.sh` prints nothing.
- [ ] **13.** The image is 80 MB or smaller in `docker image ls` (the number goes in the README).
- [ ] **14.** `README.md` has every section listed in its TODO, including measurements (image size, cold vs. cached build time) and 3 "what I learned" bullets in your own words.
- [ ] **15.** At least 3 commits of your own on `task/2026-11-17`, and no TODO-only files left in `skills/docker-statuspage/`.

## Hints (no solutions)

- Start from the simplest thing that works (C1), commit, then harden one property at a time and re-run `curl` after each change.
- There are two common ways to be non-root with nginx: the official **nginx-unprivileged** image published by NGINX, or the Docker Official `nginx` image reconfigured to run as user `nginx`. The first is far less work. Read its README to learn which port it listens on and where it writes temp and PID files.
- When `read_only: true` breaks the container, `docker compose logs web` names the exact path nginx tried to write. That path is your tmpfs mount.
- `docker inspect` takes `--format` with Go templates; `.Config.Labels`, `.Config.User` and `.State.Health` are the fields you need.
- In bash, `curl -s -o /dev/null -w '%{http_code}'` gives you just the status code. `set -Eeuo pipefail` and `trap ... EXIT` are worth looking up in the Bash manual.
- `docker history statuspage:dev` shows which layer is big.

## Stretch goals (not graded, but noted in the review)

- A GitHub Actions workflow (`.github/workflows/statuspage.yml`) that runs `scripts/smoke.sh` on pushes touching `skills/docker-statuspage/**`. That is a head start on the GitHub Actions day.
- Scan the image with Trivy and get zero HIGH/CRITICAL findings, or document the ones you can't fix.
- `/version` endpoint returning `APP_VERSION` at runtime, using the nginx image's built-in **templates / envsubst** feature (described on its Docker Hub page).
- Multi-platform build (`linux/amd64,linux/arm64`) with `docker buildx`.

## Resources (official docs only)

- Dockerfile reference: https://docs.docker.com/reference/dockerfile/
- Building best practices: https://docs.docker.com/build/building/best-practices/
- Build context and `.dockerignore`: https://docs.docker.com/build/concepts/context/
- `docker inspect`: https://docs.docker.com/reference/cli/docker/inspect/
- Formatting output (Go templates): https://docs.docker.com/engine/cli/formatting/
- Compose file reference, services: https://docs.docker.com/reference/compose-file/services/
- Compose variable interpolation: https://docs.docker.com/reference/compose-file/interpolation/
- nginx Docker Official Image: https://hub.docker.com/_/nginx
- nginx-unprivileged image (by NGINX): https://github.com/nginx/docker-nginx-unprivileged
- nginx core module (`listen`, `location`, `server_tokens`): https://nginx.org/en/docs/http/ngx_http_core_module.html
- nginx `add_header`: https://nginx.org/en/docs/http/ngx_http_headers_module.html
- nginx `return`: https://nginx.org/en/docs/http/ngx_http_rewrite_module.html#return
- OCI image annotations: https://github.com/opencontainers/image-spec/blob/main/annotations.md
- Bash manual (`set`, `trap`): https://www.gnu.org/software/bash/manual/bash.html
- ShellCheck: https://github.com/koalaman/shellcheck
- GitHub Codespaces: https://docs.github.com/en/codespaces
- Docker Desktop: https://docs.docker.com/desktop/
