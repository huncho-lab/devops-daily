# Fixtures (test data, not solutions)

Saved command output and system files from an imaginary host `web01`, so the audit
script can be tested the same way on any machine. Pass them with the file-override
options (`--df`, `--meminfo`, `--auth-log`, `--passwd`, `--ss`).

| File | Simulates | What's in it |
|---|---|---|
| `df-ok.txt` | `df -P` | worst real filesystem 64% (`/var`); a `tmpfs` at 100% that must be ignored |
| `df-warn.txt` | `df -P` | worst real filesystem 87% (`/var`) |
| `df-crit.txt` | `df -P` | worst real filesystem 97% (`/var/log`); `/` at 86%; a `tmpfs` at 100% |
| `meminfo-ok` | `/proc/meminfo` | MemAvailable is 50% of MemTotal |
| `meminfo-low` | `/proc/meminfo` | MemAvailable is 10% of MemTotal |
| `meminfo-crit` | `/proc/meminfo` | MemAvailable is just under 4% of MemTotal |
| `auth.log` | `/var/log/auth.log` | 31 `Failed password` lines: 23 from 203.0.113.7, 6 from 198.51.100.23, 2 from 192.0.2.44; also accepted logins, `Connection closed` and CRON lines that must NOT be counted |
| `auth-calm.log` | `/var/log/auth.log` | 3 `Failed password` lines, at most 2 from one IP |
| `passwd-ok` | `/etc/passwd` | only `root` has UID 0 |
| `passwd-uid0` | `/etc/passwd` | `backup2` and `toor` also have UID 0 |
| `ss-ok.txt` | `ss -Htln` | public listeners on 22, 80, 443 only; 53, 6379 and 9100 are loopback-only |
| `ss-extra.txt` | `ss -Htln` | same plus public listeners on 8080 and 5432 |

IP addresses are from the documentation ranges (RFC 5737), so they are not real hosts.
Don't edit these files: the review runs your script against them.
