#!/usr/bin/env bash
# One shard through testsrc/run's own script (run.sh from testsrc/run@v1), with everything it prints kept in
# private/: the runner prints a line per case with its verdict, and the action an annotation per failing case.
# GITHUB_ACTIONS, GITHUB_STEP_SUMMARY and GITHUB_OUTPUT are pointed away, so nothing reaches the job summary,
# the annotations or the step outputs. The log shows only counts of cases and times.
set -uo pipefail
mkdir -p private
jq -r --arg p "$PLAYER" --arg s "$SHARD" '.shards[] | select(.player == $p and .name == $s) | .cases[]' speed/shards.json > private/cases.txt
n=$(wc -l < private/cases.txt)
echo "shard $SHARD: $n cases, player $PLAYER"
t0=$(date +%s)
quiet() { env -u GITHUB_ACTIONS -u GITHUB_STEP_SUMMARY GITHUB_OUTPUT="$PWD/private/outputs" "$@"; }
IN_SET="$(cat private/cases.txt)"
export IN_SET IN_PLAYER="$PLAYER" IN_SNAPSHOT=2026-11-13 IN_LOCK=private/testsrc.lock IN_RUNNER_VERSION=latest
: > private/outputs
quiet bash .testsrc-run/run.sh resolve > private/resolve.log 2>&1 || { echo "resolve failed, exit $?"; exit 1; }
while IFS='=' read -r k v; do
  case "$k" in
    snapshot) export TESTSRC_SNAPSHOT="$v" ;; runner-dir) export RUNNER_DIR="$v" ;; runner-url) export RUNNER_URL="$v" ;;
    runner-sha256) export RUNNER_SHA256="$v" ;; runner-name) export RUNNER_NAME="$v" ;; media-dir) export TESTSRC_CACHE="$v" ;;
    discard) export IN_DISCARD="$v" ;;
  esac
done < private/outputs
export IN_REPORT_ONLY=true IN_OUT=private/out
t1=$(date +%s)
quiet bash .testsrc-run/run.sh run > private/run.log 2>&1; rc=$?
t2=$(date +%s)
echo "resolve $((t1 - t0)) s"
echo "run exit $rc, $((t2 - t1)) s for $n cases (discard=$IN_DISCARD)"
printf '{"player":"%s","shard":"%s","cases":%s,"resolve_s":%s,"run_s":%s,"exit":%s}\n' "$PLAYER" "$SHARD" "$n" "$((t1 - t0))" "$((t2 - t1))" "$rc" > private/timing.json
df -h / | tail -1 | awk '{print "disk: " $3 " used, " $4 " free"}'
exit 0
