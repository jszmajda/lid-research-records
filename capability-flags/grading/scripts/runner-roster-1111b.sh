#!/bin/bash
# 2026-11-11: the four untested models in OpenRouter's weekly top 10 (data through 2026-11-10), via the alt-model runner,
# on the same stripped copy of 919c4b4 as the Kimi and Terra rows (tree 3a5bd791 in lid-evalstrip-1109).
# Waits for the Terra roster to finish (it holds all 3 lanes the colima VM allows), then runs one lane per argument:
# a comma-separated list of models run in turn. Per model: core 0-3 x10, coach 10,11,15,16 x10, update-lid all x1. Effort medium.
T=<lid-evalstrip-1109 checkout>
R=<workspace>/roster
LOG=$R/logs-1111b
mkdir -p $LOG
until grep -q "TERRA ROSTER DONE" $R/logs-1111/progress.log 2>/dev/null; do sleep 30; done
echo "$(date '+%F %T') start (Terra done)" >> $LOG/progress.log
lane() {
  for m in $(echo "$1" | tr ',' ' '); do
    s=$(echo $m | tr '/' '_')
    ( cd $T && python3 tools/alt-model-evals/run_eval.py linked-intent-dev 0-3 $m --runs 10 ) > $LOG/$s-core.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py lid-coach 10,11,15,16 $m --runs 10 ) > $LOG/$s-coach.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py update-lid all $m --runs 1 ) > $LOG/$s-update.log 2>&1
    echo "$(date '+%F %T') lane done $m" >> $LOG/progress.log
  done
}
lane tencent/hy4,deepseek/deepseek-v4.1-flash-1017 &
lane stepfun/step-5-preview &
lane minimax/minimax-m3.1-flash &
wait
echo "$(date '+%F %T') TOP10 ROSTER DONE" >> $LOG/progress.log
