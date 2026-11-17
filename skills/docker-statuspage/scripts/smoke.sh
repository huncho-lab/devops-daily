#!/usr/bin/env bash
# TODO (you write this script): end-to-end smoke test for the image (criterion 12).
#
# Usage: bash scripts/smoke.sh        (run from skills/docker-statuspage/)
#
# Steps it must perform, in order:
#   1. fail fast: exit on any error, on unset variables and on failures inside pipes
#   2. build the image with APP_VERSION=smoke
#   3. start ONE container in the background on a free host port (e.g. 18080)
#   4. always clean up the container on exit, success or failure (look up `trap`)
#   5. wait up to 30 s until `docker inspect` reports the container as healthy
#   6. check: GET / -> 200 and body contains "devops-daily status"
#   7. check: GET /healthz -> 200 and body is exactly "ok"
#   8. check: GET /does-not-exist -> 404
#   9. check: both security headers are present on GET /
#  10. check: the image's org.opencontainers.image.version label equals "smoke"
#  11. check: `id -u` inside the container is not 0
#  12. print one PASS/FAIL line per check, exit 0 only if every check passed
#
# It must pass `shellcheck scripts/smoke.sh` with no warnings.
