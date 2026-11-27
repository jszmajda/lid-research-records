#!/bin/bash
# 2026-10-14 additions: OpenRouter models via the alt-model runner, from the same pinned tree as every existing row
# (lid-evalrun12 @ 1e7ef1a, capability-flag list empty). One model per lane; at most 3 lanes on the colima VM.
# Per model: core 0-3 x10, coach 10,11,15,16 x10, update-lid all x1. Effort medium (runner default).
T=<lid-evalrun12 checkout>
LOG=<workspace>/roster/logs-1014
mkdir -p $LOG
lane() {
  for m in "$@"; do
    s=$(echo $m | tr '/' '_')
    ( cd $T && python3 tools/alt-model-evals/run_eval.py linked-intent-dev 0-3 $m --runs 10 ) > $LOG/$s-core.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py lid-coach 10,11,15,16 $m --runs 10 ) > $LOG/$s-coach.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py update-lid all $m --runs 1 ) > $LOG/$s-update.log 2>&1
    echo "$(date '+%F %T') lane done $m" >> $LOG/progress.log
  done
}
for m in "$@"; do lane $m & done
wait
echo "$(date '+%F %T') RUNNER ROSTER DONE: $*" >> $LOG/progress.log
