#!/bin/bash
# 2026-10-18: OpenRouter models via the alt-model runner, on the same stripped copy of 919c4b4 as the 2026-10-16 rows
# (tree 3a5bd791; capability subsystem removed by hand, checked per ALT-EVAL-REC-005).
# Each argument is one lane: a comma-separated list of models run in turn. At most 3 lanes on the colima VM.
# Per model: core 0-3 x10, coach 10,11,15,16 x10, update-lid all x1. Effort medium (runner default).
T=<lid-evalstrip-1016 checkout>
LOG=<workspace>/roster/logs-1018
mkdir -p $LOG
[ $# -le 3 ] || { echo "at most 3 lanes" >&2; exit 2; }
lane() {
  for m in $(echo "$1" | tr ',' ' '); do
    s=$(echo $m | tr '/' '_')
    ( cd $T && python3 tools/alt-model-evals/run_eval.py linked-intent-dev 0-3 $m --runs 10 ) > $LOG/$s-core.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py lid-coach 10,11,15,16 $m --runs 10 ) > $LOG/$s-coach.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py update-lid all $m --runs 1 ) > $LOG/$s-update.log 2>&1
    echo "$(date '+%F %T') lane done $m" >> $LOG/progress.log
  done
}
for l in "$@"; do lane "$l" & done
wait
echo "$(date '+%F %T') RUNNER ROSTER DONE: $*" >> $LOG/progress.log
