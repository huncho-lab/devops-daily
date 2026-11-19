#!/usr/bin/env bash
# server-audit.sh: read-only health and security audit of a Linux host,
# Nagios-style exit codes (0 OK, 1 WARN, 2 CRIT, 3 UNKNOWN).
#
# TODO (you write all of this; the full spec is in days/2026-11-19/TASK.md):
#
# Basics (C1)
# - Strict mode (`set -Eeuo pipefail`) and a usage() function that prints:
#     Usage: server-audit.sh [--json] [--only LIST] [--disk-warn N] [--disk-crit N]
#            [--df FILE] [--meminfo FILE] [--auth-log FILE] [--passwd FILE]
#            [--ss FILE] [--allow-ports LIST] [--help]
# - Argument loop (`while [[ $# -gt 0 ]]; do case "$1" in ... esac; done`).
# - Every data source has a default AND a file override, so the script can be
#   tested with the files in ../fixtures/ (this is the main design idea today):
#     disk    : `df -P`            or --df FILE
#     memory  : /proc/meminfo      or --meminfo FILE
#     ssh     : /var/log/auth.log  or --auth-log FILE
#     users   : /etc/passwd        or --passwd FILE
#     ports   : `ss -Htln`         or --ss FILE
# - check_disk:   skip tmpfs and devtmpfs; worst "Capacity" wins;
#                 >= --disk-warn (default 80) WARN, >= --disk-crit (default 90) CRIT.
#                 Detail names the worst mount and its percent, e.g. "/var 87%".
# - check_memory: MemAvailable * 100 / MemTotal (integer math is fine);
#                 < 15 WARN, < 5 CRIT. Detail e.g. "available 10%".
# - Each check prints one line:  <STATUS> <check> <detail>
#   and the last line is:        overall=<STATUS>   (worst of all checks)
# - Exit code from the overall status: OK 0, WARN 1, CRIT 2.
#   Hint: one small helper that maps a status to a rank keeps this simple.
#
# More checks + JSON (C2)
# - check_ssh:   count "Failed password" lines per source IP (awk/grep/sort/uniq);
#                worst IP >= 5 WARN, >= 20 CRIT. Detail e.g. "203.0.113.7 23 failed".
#                If the DEFAULT log is missing, status SKIP (ignored for overall);
#                if --auth-log points at a missing file, exit 3.
# - check_users: any account other than root with UID 0 is CRIT; list the names.
# - --only disk,memory   runs just the listed checks (comma-separated).
# - --json  prints ONE line of valid JSON instead of text:
#     {"overall":"CRIT","checks":[{"name":"disk","status":"CRIT","detail":"/var/log 97%"}, ...]}
#   jq is NOT allowed inside the script (it may not exist on a server); build it with printf.
# - --help/-h: usage to stdout, exit 0.
# - Unknown option: "unknown option: <arg>" to stderr, exit 3.
#   An explicit file override that doesn't exist: message to stderr, exit 3.
#
# Ports (C3)
# - check_ports: listening TCP sockets; ignore loopback (127.0.0.0/8, [::1], %lo);
#                any port not in --allow-ports (default 22,80,443) is WARN; list them.
#
# - shellcheck must print nothing for this file.
