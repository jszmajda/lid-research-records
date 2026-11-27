#!/bin/bash
# Roster, OpenRouter models via the alt-model runner, from the pinned tree. One model per lane, 3 lanes.
# Per model: core 0-3 x10, coach 10,11,15,16 x10, update-lid all x1. Effort medium (runner default).
T=<lid-evalrun12 checkout>
LOG=<workspace>/roster/logs
mkdir -p $LOG
lane() {
  for m in "$@"; do
    s=$(echo $m | tr '/' '_')
    ( cd $T && python3 tools/alt-model-evals/run_eval.py linked-intent-dev 0-3 $m --runs 10 ) > $LOG/$s-core.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py lid-coach 10,11,15,16 $m --runs 10 ) > $LOG/$s-coach.log 2>&1
    ( cd $T && python3 tools/alt-model-evals/run_eval.py update-lid all $m --runs 1 ) > $LOG/$s-update.log 2>&1
    echo "lane done $m" >> $LOG/progress.log
  done
}
lane z-ai/glm-5.3 openai/gpt-5.6-terra &
lane deepseek/deepseek-v4.1-flash openai/gpt-5.6-sol &
lane z-ai/glm-5.3-flash openai/gpt-6.1-sol &
wait
echo "RUNNER ROSTER DONE" >> $LOG/progress.log
