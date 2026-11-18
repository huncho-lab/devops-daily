#!/usr/bin/env bats
# Tests for scripts/repo-stats.sh (bats-core).
#
# TODO (you write all of this; at least 5 tests, criterion 4):
# - setup(): resolve the script path relative to this file
#   (bats gives you BATS_TEST_DIRNAME) and build a fake repo tree in
#   BATS_TEST_TMPDIR, e.g. days/a/TASK.md, days/b/TASK.md, days/b/REVIEW.md.
# - Test 1: text output with --root <fixture> prints days=2 and reviews=1, exit 0.
# - Test 2: --json output parses with jq and has the right numbers.
# - Test 3: --help exits 0 and prints the usage line.
# - Test 4: an unknown option exits 2 and stderr contains "unknown option"
#           (hint: `run --separate-stderr`, needs bats-core 1.5+; check the version apt gives you).
# - Test 5: --root pointing at a missing directory exits 1.
# - Optional: a root with no days/ folder prints days=0 and reviews=0.
