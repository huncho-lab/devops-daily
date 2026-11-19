#!/usr/bin/env bats
# Tests for scripts/server-audit.sh (bats-core).
#
# TODO (you write all of this; at least 10 tests by the end of C2, criterion 9):
# - setup(): SCRIPT and FIX paths resolved from BATS_TEST_DIRNAME
#   (../scripts/server-audit.sh and ../fixtures).
# - Always pass fixture files (--df, --meminfo, --auth-log, --passwd, --ss) or --only,
#   so the tests never depend on the machine they run on.
#
# Test names to implement (one @test each; add more if you like):
#   disk: df-ok.txt -> OK, exit 0 (and the 100% tmpfs is ignored)
#   disk: df-warn.txt -> WARN on /var 87%, exit 1
#   disk: df-crit.txt -> CRIT on /var/log 97%, exit 2
#   disk: --disk-warn 40 makes df-ok.txt WARN
#   memory: meminfo-ok -> OK, meminfo-low -> WARN, meminfo-crit -> CRIT
#   ssh: auth.log -> CRIT, detail names 203.0.113.7 and 23
#   ssh: auth-calm.log -> OK
#   users: passwd-uid0 -> CRIT naming backup2 and toor; passwd-ok -> OK
#   json: output parses with jq, .overall and .checks[].name are right
#   cli: --help exits 0; unknown option exits 3 with "unknown option" on stderr
#   cli: --auth-log /no/such/file exits 3
#   (C3) ports: ss-extra.txt -> WARN listing 5432 and 8080; ss-ok.txt -> OK
