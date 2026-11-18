# GitHub Actions CI from the browser: lint, test matrix and report for a bash tool

- **Date:** 2026-11-18 (Wednesday)
- **Track:** Skills track, day 2 (topic: **GitHub Actions**)
- **Estimated time:** ~5 hours: **10 min first push**, **C1 (60 min)**, **C2 (90 min)**, **C3 (~2 h 30 min)**, 10 min buffer
- **Branch:** `task/2026-11-18`
- **Work folders:** `skills/gha-ci/` and `.github/` (repo root)

> Skeleton files contain only TODO comments describing *what* each file must do. You write every line of YAML, bash and bats yourself. Use the official docs linked at the bottom.

## What's new

- **You can do all of today in the browser.** No Docker, no Node, no local Git needed: edit files on github.com (press `.` on the repo page for the web editor, or use Codespaces), commit to `task/2026-11-18`, and GitHub runs your pipeline for you. If local setup was the blocker on earlier days, it can't block you today.
- **The Actions tab is your test result.** Every criterion below about "a green run" is checked from the run list for `ci.yml` on this branch, so the review can grade you even if you never run anything locally.
- **Yesterday's Docker task stays on `task/2026-11-17`.** Push it there any time and say `review now task/2026-11-17` in Agent Hub. Thesis step 1 is still on `task/2026-11-16`.
- **Want lighter days, a pause or the thesis back?** One line in Agent Hub, thread *tasks*: `lighter tasks`, `pause until <date>`, `weekends only`, `extend thesis to <date>` or `thesis + skills`.

## Goal

Build a real CI pipeline in GitHub Actions for a tiny bash tool you write (`repo-stats.sh`): lint job, test job on a runner matrix, a report job with a job summary and an artifact, least-privilege permissions, SHA-pinned actions, concurrency, path filters and a reusable composite action. Then prove it can go red and back to green.

## Why it matters for DevOps jobs

The AGCO IT DevOps intern posting names GitHub Actions explicitly, and "walk me through a pipeline you built" is the standard junior DevOps interview question. Today's pipeline touches the topics interviewers probe: job dependencies (`needs`), matrices, `GITHUB_TOKEN` permissions, pinning actions against supply-chain attacks, caching/concurrency, artifacts vs. summaries, and reusing steps. The same structure carries straight into your thesis pipeline (step 3) and the Azure DevOps day.

## First push (10 min, no code) → criterion 0

Browser route: open https://github.com/huncho-lab/devops-daily, switch the branch selector to `task/2026-11-18`, open `days/2026-11-18/NOTES.md`, click the pencil, fill the 3 top lines, **Commit changes** directly to `task/2026-11-18`.

Terminal route:

```bash
git fetch origin && git switch task/2026-11-18
# edit days/2026-11-18/NOTES.md (3 lines at the top)
git add days/2026-11-18/NOTES.md && git commit -m "notes: start 2026-11-18" && git push
```

If anything fails, paste the exact error into Agent Hub (thread *tasks* or *review*). That counts as today's result.

### Unstick table

| Symptom | Official fix |
|---|---|
| Workflow doesn't appear in the Actions tab | It must live at `.github/workflows/<name>.yml` at the **repo root**, and the push must match your `on:` triggers |
| "Invalid workflow file" banner on the run | Click it: it names the line. Indentation is spaces only. Run actionlint (see Resources) |
| `refusing to allow a ... to create or update workflow` on push | Your token lacks the `workflow` scope. Use the web editor, or a fine-grained PAT with *Workflows: write* (docs.github.com/authentication) |
| Runner label "not found" / job queued forever | That runner image was retired or is a typo. Pick a current label from the runner docs (Resources) |
| `bats: command not found` / `shellcheck: command not found` in a job | Install it in a step (or in your composite action) before using it |
| Actions disabled for the repo | Settings → Actions → General → Allow actions (docs.github.com/repositories/managing-your-repositorys-settings-and-features) |

## The tool you CI today: `repo-stats.sh` (spec)

`skills/gha-ci/scripts/repo-stats.sh [--json] [--root DIR] [--help]`

| Input | Behaviour |
|---|---|
| no options | Looks in `./days/*/`. Prints two lines to stdout: `days=<number of days/*/TASK.md>` and `reviews=<number of days/*/REVIEW.md>`. Exit 0. |
| `--root DIR` | Same, but counts under `DIR/days/*/` instead of `./days/*/`. |
| `--json` | Prints one line of valid JSON instead: `{"days":N,"reviews":M}`. Exit 0. |
| `--help` / `-h` | Prints a usage line to stdout. Exit 0. |
| `--root` pointing at a missing directory | Message to stderr. Exit 1. |
| any unknown option | Message to stderr (must contain `unknown option`). Exit 2. |
| no `days/` folder (but root exists) | `days=0`, `reviews=0`. Exit 0. |

## Plan (timed)

| Time | Block | What you do | Criteria | Push? |
|---|---|---|---|---|
| 0:00–0:10 | First push | NOTES.md, 3 lines | 0 | yes |
| 0:10–0:40 | C1a | Write `repo-stats.sh` to the spec (text output + `--root` first) | 3 | yes |
| 0:40–1:10 | C1b | Move `skeleton/ci.yml` to `.github/workflows/ci.yml`; triggers + `lint` job with shellcheck; watch it go green | 1, 2, 3 | **yes: pass line** |
| 1:10–1:50 | C2a | `--json`, `--help`, error exits; 4+ bats tests in `tests/repo-stats.bats` | 4 | yes |
| 1:50–2:20 | C2b | `test` job: `needs: lint`, matrix, `fail-fast: false` | 4 | yes |
| 2:20–2:40 | C2c | `permissions`, `timeout-minutes`, `concurrency`, pin every `uses:` to a SHA | 5, 6 | yes |
| 2:40–2:50 | C2d | Break shellcheck on purpose → red run → fix → green run | 7 | yes (twice) |
| 2:50–3:30 | C3a | Composite action `.github/actions/setup-ci-tools/`, used by `lint` and `test`; add actionlint to `lint` | 10, 12 | yes |
| 3:30–4:10 | C3b | `report` job: job summary table + `repo-stats` artifact; `workflow_dispatch` input; `paths` filter | 8, 9, 11 | yes |
| 4:10–4:50 | C3c | README: job diagram, badge, measurements from 3 runs, red→green links, what I learned | 13 | yes |
| 4:50–5:00 | Clean check | Trigger the workflow once via **Run workflow**; check every job is green | 14 | yes |

**Stop rule:** at 20:45, commit and push whatever you have. The review at 21:12 grades what is on the branch and in its Actions runs.

## Acceptance criteria (the evening review grades exactly these)

Paths starting with `scripts/`, `tests/` or `README.md` are relative to `skills/gha-ci/`. `ci.yml` means `.github/workflows/ci.yml` at the repo root.

**First push**
- [ ] **0.** `days/2026-11-18/NOTES.md` has the 3 top lines filled in (or an error pasted in Agent Hub), committed by you and pushed.

**C1, pass line**
- [ ] **1.** `ci.yml` exists, has a `name:`, and triggers on `push` to branches `task/**`, on `pull_request` to `main`, and on `workflow_dispatch`.
- [ ] **2.** `ci.yml` has a job `lint` that runs on an exact runner label (e.g. `ubuntu-24.04`, **not** `ubuntu-latest`), checks out the repo and runs `shellcheck` on `skills/gha-ci/scripts/*.sh`.
- [ ] **3.** `scripts/repo-stats.sh` implements the text output and `--root` rows of the spec (`bash scripts/repo-stats.sh --root <repo root>` on this branch prints `days=1` and `reviews=0`), and the latest run of `ci.yml` on `task/2026-11-18` has conclusion **success**.

**C2, tests + hardening**
- [ ] **4.** Job `test` has `needs: lint`, a `strategy.matrix` over two different Ubuntu runner labels with `fail-fast: false`, and runs `bats` on `tests/repo-stats.bats`, which has **at least 5** tests covering: text output on a temp fixture, `--json` output that `jq` parses with the right numbers, `--help` exits 0, unknown option exits 2 with `unknown option` on stderr, missing `--root` dir exits 1. All pass on both matrix legs.
- [ ] **5.** `ci.yml` has top-level `permissions: contents: read` (no job widens it), every job has `timeout-minutes` of 10 or less, and a `concurrency` group keyed on the workflow and ref with `cancel-in-progress: true`.
- [ ] **6.** Every `uses:` that references an action outside this repo (including `actions/*`) is pinned to a full 40-character commit SHA with the version in a trailing comment (e.g. `@<sha> # v4.2.2`).
- [ ] **7.** The branch's run history for `ci.yml` shows at least one **failed** run caused by a shellcheck (or bats) failure, followed later by a **successful** run. Both run links are in the README.

**C3, reuse + reporting**
- [ ] **8.** `push` and `pull_request` triggers have a `paths:` filter that includes `skills/gha-ci/**` and `.github/**` (so a commit touching only `days/**` does not start CI).
- [ ] **9.** Job `report` (`needs: test`) runs `repo-stats.sh --json`, writes a Markdown table of the numbers to `$GITHUB_STEP_SUMMARY`, and uploads `repo-stats.json` as an artifact named `repo-stats` with `retention-days` of 7 or less. The artifact is visible on the latest green run.
- [ ] **10.** A composite action at `.github/actions/setup-ci-tools/action.yml` (with `name`, `description` and `runs.using: composite`) installs shellcheck, bats and jq (or checks they exist), and both `lint` and `test` use it via `uses: ./.github/actions/setup-ci-tools`.
- [ ] **11.** `workflow_dispatch` has a boolean input `run_report` (default `true`), and the `report` job only runs when it is true or the event is not `workflow_dispatch`. At least one manual run exists in the run history.
- [ ] **12.** The `lint` job also runs **actionlint** over `.github/workflows/`, and it passes.
- [ ] **13.** `README.md` has every section listed in its TODO, including a status badge for `ci.yml` on this branch, a measurements table with the durations of 3 runs (total and per job), the red→green run links, and 3 "what I learned" bullets in your own words.
- [ ] **14.** At least 3 commits of your own on `task/2026-11-18`, no TODO-only files left in `skills/gha-ci/`, and the `skills/gha-ci/skeleton/` folder removed (its files moved to their real places).

## Hints (no solutions)

- Get one trivial green run first (C1), then add one feature per commit. A red run after a one-line change tells you exactly what broke.
- `on.push.branches` accepts glob patterns; read the "Filter pattern cheat sheet" in the workflow syntax docs.
- The runner images page lists every current label. Two Ubuntu labels in the matrix is enough; `matrix.<name>` then feeds `runs-on`.
- `bats` and `shellcheck` are packaged for Ubuntu (`apt-get`); `jq` is already on GitHub's Ubuntu images. Your composite action is just those `run:` steps, each with an explicit `shell: bash` (composite actions require it).
- To find a commit SHA for a tag: open the action's repo → Releases/Tags → click the tag → copy the full commit hash. The "Security hardening for GitHub Actions" page explains why tags aren't enough.
- In bats, `run` captures `$status` and `$output`; `run --separate-stderr` gives you `$stderr` too. `BATS_TEST_TMPDIR` is a fresh temp dir per test: build a fake `days/` tree in it for `--root`.
- `github.workflow` and `github.ref` are the usual concurrency key parts (contexts reference).
- `$GITHUB_STEP_SUMMARY` is a file path: append Markdown to it. `if:` on a job can read `github.event_name` and `inputs.<name>`.
- The status badge URL format is on the "Adding a workflow status badge" page; it takes a `branch` query parameter.
- Durations: open a run → the summary shows total time; each job shows its own. Note whether the first run of the day (no warm runner cache) differs.

## Stretch goals (not graded, but noted in the review)

- `.github/dependabot.yml` for the `github-actions` ecosystem, so your SHA pins get update PRs.
- Pass the `days` count from `report` as a job **output** to a fourth job that fails if it is 0.
- Run the pipeline locally with `act` (nektos/act) and note what differs from GitHub's runners.
- Add a job that runs yesterday's `skills/docker-statuspage/scripts/smoke.sh` once that branch is merged.
- Open a PR from `task/2026-11-18` to `main` (don't merge) and see which triggers fire.

## Resources (official docs only)

- Workflow syntax (on, paths, jobs, needs, matrix, permissions, concurrency): https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions
- Events that trigger workflows (`workflow_dispatch` inputs): https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows
- Contexts reference (`github`, `inputs`, `matrix`): https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs
- Running variations of jobs (matrix): https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/running-variations-of-jobs-in-a-workflow
- GitHub-hosted runners (current labels): https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners/about-github-hosted-runners
- Controlling permissions for `GITHUB_TOKEN`: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token
- Security hardening (pinning to SHAs): https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
- Control concurrency: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/control-the-concurrency-of-workflows-and-jobs
- Job summaries (`GITHUB_STEP_SUMMARY`): https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-job-summary
- Storing workflow data as artifacts: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow
- Creating a composite action: https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action
- Adding a workflow status badge: https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/monitoring-workflows/adding-a-workflow-status-badge
- actions/checkout: https://github.com/actions/checkout · actions/upload-artifact: https://github.com/actions/upload-artifact
- actionlint: https://github.com/rhysd/actionlint (see `docs/usage.md` for running it in a workflow)
- ShellCheck: https://github.com/koalaman/shellcheck
- Bats-core docs: https://bats-core.readthedocs.io/
- jq manual: https://jqlang.org/manual/
- Bash manual (`case`, `getopts`, `shopt -s nullglob`, `set`): https://www.gnu.org/software/bash/manual/bash.html
- GitHub web editor (`.` key) and Codespaces: https://docs.github.com/en/codespaces/the-githubdev-web-based-editor
