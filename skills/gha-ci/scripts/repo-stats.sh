#!/usr/bin/env bash
# repo-stats.sh: count daily briefs and reviews in a devops-daily checkout.
#
# TODO (you write all of this; see the spec table in days/2026-11-18/TASK.md):
# - Strict mode (look up `set -Eeuo pipefail` in the Bash manual).
# - A usage() function that prints:  Usage: repo-stats.sh [--json] [--root DIR] [--help]
# - Parse arguments in a loop (`while [[ $# -gt 0 ]]; do case ... esac; done`):
#     --json        -> switch to JSON output
#     --root DIR    -> directory to count under (default: current directory)
#     -h|--help     -> usage to stdout, exit 0
#     anything else -> "unknown option: <arg>" to stderr, exit 2
# - If the root directory does not exist: message to stderr, exit 1.
# - Count <root>/days/*/TASK.md and <root>/days/*/REVIEW.md.
#   Careful: with no matches, a bare glob stays literal. `shopt -s nullglob` fixes that.
# - Text mode prints exactly two lines:  days=N  then  reviews=M
# - JSON mode prints exactly one line:   {"days":N,"reviews":M}
# - shellcheck must print nothing for this file.
