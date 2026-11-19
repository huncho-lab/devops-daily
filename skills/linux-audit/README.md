# linux-audit: a read-only server audit script with a systemd timer

<!-- TODO (criterion 13): write every section below in your own words, then delete these comments. -->

## What it checks
<!-- TODO: table with one row per check: data source, file override option, WARN rule, CRIT rule -->

## Usage and exit codes
<!-- TODO: options, the 0/1/2/3 exit codes and why monitoring tools (Nagios, Icinga, Zabbix agents) use that convention -->

## Example output
<!-- TODO: paste real text output and real --json output for fixtures/df-crit.txt + auth.log + passwd-uid0 -->

## Run it on a real host
<!-- TODO: output of the script on your Codespace / WSL / VM (no fixtures), and one thing it found -->

## Install as a systemd timer
<!-- TODO: the exact commands (install script, copy units, daemon-reload, enable --now the timer,
     list-timers, start the service by hand, journalctl -u to read the result).
     Explain SuccessExitStatus, Persistent=true and why the service has no [Install] section. -->

## Manual equivalents
<!-- TODO: for each check, the one-liner an admin would type by hand (df -h, free -m, journalctl/grep, awk -F:, ss -tlnp) -->

## What I learned
<!-- TODO: 3 bullets -->
