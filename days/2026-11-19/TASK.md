# Linux server admin: a read-only audit script with Nagios exit codes and a systemd timer

- **Date:** 2026-11-19 (Thursday)
- **Track:** Skills track, day 3 (topic: **Linux server administration**)
- **Estimated time:** ~5 hours: **10 min first push**, **20 min setup**, **C1 (60 min)**, **C2 (110 min)**, **C3 (~100 min)**
- **Branch:** `task/2026-11-19`
- **Work folder:** `skills/linux-audit/` (+ `.github/workflows/` at the repo root in C3)

> Skeleton files contain only TODO comments describing *what* each file must do. You write every line of bash, bats, unit files and YAML yourself. The `fixtures/` folder is test data (saved `df`, `/proc/meminfo`, `auth.log`, `/etc/passwd`, `ss` output), not solutions.

## What's new

- **One bash script, no Docker, no cloud account.** Everything runs in a GitHub Codespace (browser), WSL or any Linux VM. If Docker or Node setup is what stopped the earlier days, it can't stop this one.
- **Fixtures make it testable anywhere.** Each check reads a real system source by default *or* a file you pass in, so your tests (and the evening review) give the same result on every machine.
- **Earlier branches stay open.** Docker (`task/2026-11-17`), GitHub Actions (`task/2026-11-18`) and thesis step 1 (`task/2026-11-16`) are parked. Push to any of them and say `review now task/<date>` in Agent Hub.
- **Days not fitting right now?** One line in Agent Hub, thread *tasks*: `lighter tasks`, `pause until <date>`, `weekends only`, `extend thesis to <date>` or `thesis + skills`. The next brief adapts.

## Goal

Write `server-audit.sh`, a read-only host audit an on-call admin or a cron/systemd timer can run: disk, memory, failed SSH logins, extra UID-0 accounts and unexpected listening ports, each with OK/WARN/CRIT, Nagios-style exit codes and a JSON mode. Test it with bats against fixtures, then schedule it with a hardened systemd service + timer and verify both in CI.

## Why it matters for DevOps jobs

The AGCO IT DevOps intern posting asks for Linux/Windows server work and monitoring. Interviews for those roles ask: *A disk is filling up, what do you run? How do you find brute-force SSH attempts? Why would a second UID 0 account scare you? What's listening on this box? cron or systemd timers, and why?* The exit-code convention (0/1/2/3) is what Nagios, Icinga and many Zabbix/Prometheus exporters' check scripts use, so a script that follows it plugs straight into real monitoring. Writing scripts that take their inputs as files (so they can be tested) is the habit that separates "works on my server" from code a team can trust.

## First push (10 min, no code) → criterion 0

Browser route: on https://github.com/huncho-lab/devops-daily switch to `task/2026-11-19`, open `days/2026-11-19/NOTES.md`, click the pencil, fill the 3 top lines, **Commit changes** to `task/2026-11-19`.

Terminal route:

```bash
git fetch origin && git switch task/2026-11-19
# edit days/2026-11-19/NOTES.md (3 lines at the top)
git add days/2026-11-19/NOTES.md && git commit -m "notes: start 2026-11-19" && git push
```

If anything fails, paste the exact error into Agent Hub (thread *tasks* or *review*). That counts as today's result.

## Setup (20 min)

1. **Codespace (recommended):** repo page → **Code** → **Codespaces** → create on branch `task/2026-11-19`. Free accounts get a monthly Codespaces quota; stop the codespace when you're done.
2. Install the tools: `sudo apt-get update && sudo apt-get install -y shellcheck bats jq` (WSL/Ubuntu VM: the same).
3. Check: `bash --version`, `shellcheck --version`, `bats --version` (1.5+ for `run --separate-stderr`), `jq --version`.

### Unstick table

| Symptom | Official fix |
|---|---|
| `Permission denied` running the script | `chmod +x scripts/server-audit.sh` and commit it (Git stores the executable bit), or run `bash scripts/...` |
| `$'\r': command not found` | Windows line endings. Set your editor to LF, or `git config core.autocrlf input` (git-scm.com/docs/git-config) |
| `bats: command not found` / old bats without `--separate-stderr` | Install bats-core from its repo (bats-core.readthedocs.io, "Installation") |
| `ss: command not found` in a container | `sudo apt-get install -y iproute2` (or test with `--ss fixtures/ss-ok.txt`) |
| `/var/log/auth.log` missing (Codespaces, many containers) | Expected: the default-source ssh check reports `SKIP`. Use `--auth-log fixtures/auth.log` to test it |
| `systemd-analyze` missing or "System has not been booted with systemd" | Codespaces doesn't run systemd. Verify the units in the GitHub Actions job (C3) instead; Ubuntu runners have it |
| Workflow doesn't start | It must live at `.github/workflows/` at the repo root and the push must match its `paths:` filter (see yesterday's brief) |

## The tool: `server-audit.sh` (spec)

`skills/linux-audit/scripts/server-audit.sh [options]`

### Checks

| Check | Default source | Override | OK | WARN | CRIT |
|---|---|---|---|---|---|
| `disk` | `df -P` | `--df FILE` | worst use < warn | worst use ≥ `--disk-warn` (default 80) | worst use ≥ `--disk-crit` (default 90) |
| `memory` | `/proc/meminfo` | `--meminfo FILE` | available ≥ 15% | available < 15% | available < 5% |
| `ssh` | `/var/log/auth.log` | `--auth-log FILE` | worst IP < 5 `Failed password` lines | worst IP ≥ 5 | worst IP ≥ 20 |
| `users` | `/etc/passwd` | `--passwd FILE` | only `root` has UID 0 | – | any other UID-0 account |
| `ports` (C3) | `ss -Htln` | `--ss FILE` | every non-loopback listening port is allowed | any other port | – |

- `disk` ignores `tmpfs` and `devtmpfs` and reports the worst remaining mount: detail like `/var 87%`.
- `memory` = `MemAvailable * 100 / MemTotal` (integer math is fine): detail like `available 10%`.
- `ssh` counts only lines containing `Failed password` (with or without `invalid user`), grouped by source IP: detail like `203.0.113.7 23 failed`. If the **default** log doesn't exist, status `SKIP` (doesn't affect overall).
- `users` detail lists the extra names, e.g. `uid0: backup2 toor`.
- `ports` ignores loopback listeners (`127.x.x.x`, `[::1]`, `%lo`). Allowed list: `--allow-ports` (default `22,80,443`). Detail lists unexpected ports in ascending order, e.g. `unexpected: 5432 8080`.

### Output and exit codes

| Mode / case | Behaviour |
|---|---|
| default (text) | One line per check: `<STATUS> <check> <detail>`, then `overall=<STATUS>` (worst of all checks, `SKIP` ignored) |
| `--json` | Exactly one line of valid JSON: `{"overall":"WARN","checks":[{"name":"disk","status":"WARN","detail":"/var 87%"},...]}`, checks in the order disk, memory, ssh, users, ports. Built without `jq` |
| `--only LIST` | Runs only the comma-separated checks, e.g. `--only disk,memory` |
| exit code | `0` overall OK, `1` WARN, `2` CRIT (same in text and JSON mode) |
| `--help` / `-h` | Line starting with `Usage:` to stdout, exit 0 |
| unknown option | Message containing `unknown option` to stderr, exit **3** |
| an override file that doesn't exist (`--df`, `--meminfo`, `--auth-log`, `--passwd`, `--ss`) | Message to stderr, exit **3** |

## Plan (timed)

| Time | Block | What you do | Criteria | Push? |
|---|---|---|---|---|
| 0:00–0:10 | First push | NOTES.md, 3 lines | 0 | yes |
| 0:10–0:30 | Setup | Codespace, tools, read `fixtures/README.md` | – | – |
| 0:30–1:30 | C1 | `usage`, argument loop, `check_disk`, `check_memory`, text output, overall + exit code | 1–4 | **yes: pass line** |
| 1:30–2:10 | C2a | `check_ssh` (awk or `grep \| sort \| uniq -c`), `check_users` (`awk -F:`) | 5, 6 | yes |
| 2:10–2:40 | C2b | `--only`, `--json` with `printf`, exit-3 errors | 7, 8 | yes |
| 2:40–3:20 | C2c | 10+ bats tests, shellcheck clean | 9 | yes |
| 3:20–3:45 | C3a | `check_ports` + `--allow-ports` | 10 | yes |
| 3:45–4:20 | C3b | systemd service + timer | 11 | yes |
| 4:20–4:45 | C3c | Move `skeleton/linux-audit.yml` to `.github/workflows/`, get it green | 12 | yes |
| 4:45–5:10 | C3d | README; remove `skeleton/` | 13, 14 | yes |

**Stop rule:** at 20:45, commit and push whatever you have. The review at 21:12 grades what is on the branch.

## Acceptance criteria (the evening review grades exactly these)

All commands run from `skills/linux-audit/`; `S=scripts/server-audit.sh`, `F=fixtures`.

**First push**
- [ ] **0.** `days/2026-11-19/NOTES.md` has the 3 top lines filled in (or an error pasted in Agent Hub), committed by you and pushed.

**C1, pass line**
- [ ] **1.** `bash $S --help` exits 0 and prints a line starting with `Usage:`.
- [ ] **2.** `bash $S --only disk --df $F/df-ok.txt` prints a line starting `OK disk` and `overall=OK`, exit 0. With `$F/df-warn.txt`: `WARN disk` with `/var 87%`, exit 1. With `$F/df-crit.txt`: `CRIT disk` with `/var/log 97%`, exit 2.
- [ ] **3.** `bash $S --only memory --meminfo $F/meminfo-ok` → `OK memory`, exit 0; `meminfo-low` → `WARN memory`, exit 1; `meminfo-crit` → `CRIT memory`, exit 2.
- [ ] **4.** Thresholds work: `--only disk --df $F/df-ok.txt --disk-warn 60` → WARN (`/var 64%`), exit 1; adding `--disk-crit 60` → CRIT, exit 2.

**C2, more checks + JSON + tests**
- [ ] **5.** `--only ssh --auth-log $F/auth.log` → `CRIT ssh` whose detail contains `203.0.113.7` and `23`, exit 2; with `$F/auth-calm.log` → `OK ssh`, exit 0. Running `--only ssh` on a machine without `/var/log/auth.log` → `SKIP ssh` and `overall=OK`, exit 0.
- [ ] **6.** `--only users --passwd $F/passwd-uid0` → `CRIT users` naming `backup2` and `toor` (not `root`), exit 2; `$F/passwd-ok` → `OK users`, exit 0.
- [ ] **7.** `bash $S --json --only disk,memory,ssh,users --df $F/df-warn.txt --meminfo $F/meminfo-ok --auth-log $F/auth-calm.log --passwd $F/passwd-uid0` prints one line that `jq` parses, with `.overall == "CRIT"`, `[.checks[].name] == ["disk","memory","ssh","users"]`, `.checks[0].status == "WARN"`, and exit code 2. The script itself doesn't call `jq`.
- [ ] **8.** An unknown option (e.g. `--bogus`) exits 3 with `unknown option` on stderr and nothing on stdout; `--auth-log /no/such/file` exits 3.
- [ ] **9.** `bats tests/` runs **at least 10** tests, all passing, covering criteria 2, 3, 5, 6, 7 and 8, using only fixtures or temp files (no dependence on the host). `shellcheck $S` prints nothing and exits 0.

**C3, ports + systemd + CI + docs**
- [ ] **10.** `--only ports --ss $F/ss-extra.txt` → `WARN ports` with `5432 8080` (and not 53, 6379 or 9100), exit 1; `$F/ss-ok.txt` → `OK ports`, exit 0; `--allow-ports 22,80,443,5432,8080` with `ss-extra.txt` → OK.
- [ ] **11.** `systemd/server-audit.service`: `Type=oneshot`, `ExecStart=/usr/local/bin/server-audit.sh --json`, `SuccessExitStatus=1`, at least 5 hardening directives from `systemd.exec` (e.g. `NoNewPrivileges=yes`, `ProtectSystem=strict`, `ProtectHome=read-only`, `PrivateTmp=yes`, `PrivateDevices=yes`), no `[Install]` section. `systemd/server-audit.timer`: an `OnCalendar=` that `systemd-analyze calendar` resolves to 06:15 daily, `Persistent=true`, `RandomizedDelaySec=` ≤ 10 min, `WantedBy=timers.target`. `systemd-analyze verify` passes on both (shown in the CI job's log).
- [ ] **12.** `.github/workflows/linux-audit.yml` (from the skeleton) runs on this branch: exact runner label, `timeout-minutes` ≤ 10, `permissions: contents: read`, checkout pinned to a 40-char SHA with a version comment, shellcheck + bats + `systemd-analyze verify` + a real `--json` run written as a Markdown table to `$GITHUB_STEP_SUMMARY`. The latest run on `task/2026-11-19` is green.
- [ ] **13.** `skills/linux-audit/README.md` has every section from its TODO, including real output on a non-fixture host and 3 "what I learned" bullets in your own words.
- [ ] **14.** At least 3 commits of your own on `task/2026-11-19`, no TODO-only files left in `skills/linux-audit/`, `skills/linux-audit/skeleton/` removed, `scripts/server-audit.sh` committed as executable (`git ls-files -s` shows mode `100755`), and the `fixtures/` files unchanged.

## Hints (no solutions)

- Build it in layers: the argument loop and one check first, print the line, then compute the exit code. Push after every check that works.
- `df -P` gives one line per filesystem with no wrapping, which is exactly why scripts use it. `awk 'NR>1 { ... }'` skips the header; `$1` is the filesystem, `$5` the capacity with a `%`, `$6` the mount point.
- `awk` can match a key and print its value: look for the `MemTotal:` and `MemAvailable:` lines in `/proc/meminfo` (`man 5 proc` explains the difference between MemFree and MemAvailable; the README should too).
- For the ssh check, a pipeline of `grep` → extract the field after `from` → `sort` → `uniq -c` → `sort -rn` → `head -n 1` gives the worst IP. Watch out: the word position differs between `Failed password for root from ...` and `Failed password for invalid user admin from ...`.
- `/etc/passwd` is colon-separated: `awk -F:` with field 3 for the UID.
- In `ss -Htln` output the local address is column 4; the port is everything after the **last** colon. `sort -n -u` gives ascending unique ports.
- JSON by hand: build each check object with `printf '{"name":"%s","status":"%s","detail":"%s"}'`, join with commas. Your details contain no quotes, so no escaping is needed, but say in the README why real tools escape.
- `set -e` and checks that "fail" on purpose don't mix well: a command that returns non-zero inside a function can end the script. Read the `set -e` section of the Bash manual and plan where the exit code is decided (at the very end).
- bats: `run --separate-stderr bash "$SCRIPT" --bogus` gives `$status`, `$output`, `$stderr`. For JSON, pipe `$output` to `jq -e '<expression>'` (exit 0 only if true).
- `systemd-analyze calendar 'Mon..Sun *-*-* 06:15'` and `'*-*-* 06:15:00'` are both valid forms; try them. `systemd-analyze verify` needs the `ExecStart` binary to exist, which is why the CI job copies the script to `/usr/local/bin` first (with `sudo install -m 0755`).
- `SuccessExitStatus=` takes a list of extra exit codes that count as success (see `systemd.service`).

## Stretch goals (not graded, but noted in the review)

- `--format nagios`: one line `DISK WARNING - /var 87% | ...` with performance data after the `|` (Nagios plugin guidelines).
- An `inodes` check using `df -Pi`, with its own fixture.
- Install the timer on a real systemd machine (an Ubuntu VM or a cloud free-tier instance), let it fire, and paste `systemctl list-timers` and `journalctl -u server-audit.service` output in the README.
- Ship the JSON line to a file that yesterday's GitHub Actions `report` job pattern could pick up as an artifact.
- A `logrotate` config for a log file the service writes, checked with `logrotate -d`.

## Resources (official docs only)

- GNU Bash manual (`set`, `case`, `[[ ]]`, arrays, `printf`): https://www.gnu.org/software/bash/manual/bash.html
- GNU Awk manual: https://www.gnu.org/software/gawk/manual/gawk.html
- GNU coreutils (`df`, `sort`, `uniq`, `install`): https://www.gnu.org/software/coreutils/manual/coreutils.html
- `proc(5)` / `/proc/meminfo`: https://man7.org/linux/man-pages/man5/proc_meminfo.5.html
- `passwd(5)`: https://man7.org/linux/man-pages/man5/passwd.5.html
- `ss(8)`: https://man7.org/linux/man-pages/man8/ss.8.html
- systemd.service: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
- systemd.exec (sandboxing options): https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html
- systemd.timer: https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html
- systemd.time (calendar syntax): https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html
- systemd-analyze (`verify`, `calendar`, `security`): https://www.freedesktop.org/software/systemd/man/latest/systemd-analyze.html
- Nagios plugin return codes: https://nagios-plugins.org/doc/guidelines.html#AEN78
- ShellCheck: https://github.com/koalaman/shellcheck · Bats-core: https://bats-core.readthedocs.io/ · jq manual: https://jqlang.org/manual/
- GitHub Codespaces: https://docs.github.com/en/codespaces · GitHub Actions workflow syntax: https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions
- Job summaries: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-job-summary
