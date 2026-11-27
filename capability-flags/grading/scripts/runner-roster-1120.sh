#!/bin/bash
# 2026-11-20: the three untested Gemini 4 models on OpenRouter (google/gemini-4-hydrogen, google/gemini-4-carbon,
# google/gemini-4-neon) via the alt-model runner, on the same stripped copy of 919c4b4 as the Kimi, Terra, Hy4, MiniMax
# and DeepSeek 1017 rows (tree 3a5bd791, rebuilt in a fresh worktree lid-evalstrip-1120 from the tree object; the
# ALT-EVAL-REC-005 search and diff rerun before launch). The worktree's runner is main's (11294c4: 10-minute
# inactivity limit, 30-minute run limit), copied over tools/ only, so plugins/ stays tree 3a5bd791.
# Runs in its own colima profile (lid-alt, 8 GiB, 4 CPU) so it shares no VM memory with other containers.
# Per model: core 0-3 x10, coach 10,11,15,16 x10, update-lid all x1. Effort medium (runner default).
# Work queue: 4 lanes claim batches in order (models interleaved); each eval cell comes from one batch.
T=<lid-evalstrip-1120 checkout>
LOG=<workspace>/roster/logs-1120
export DOCKER_CONTEXT=colima-lid-alt
mkdir -p $LOG
MODELS="google/gemini-4-hydrogen google/gemini-4-carbon google/gemini-4-neon"
TASKS=()
for spec in "core01|linked-intent-dev|0,1|10" "core23|linked-intent-dev|2,3|10" \
            "coach1011|lid-coach|10,11|10" "coach1516|lid-coach|15,16|10" "update|update-lid|all|1"; do
  for m in $MODELS; do TASKS+=("$m|$spec"); done
done
lane() {
  local i=0
  for t in "${TASKS[@]}"; do
    i=$((i+1))
    mkdir "$LOG/claim-$i" 2>/dev/null || continue
    IFS='|' read -r m name skill ids runs <<< "$t"
    s=$(echo $m | tr '/' '_')
    echo "$(date '+%F %T') lane $1 start $s-$name" >> $LOG/progress.log
    ( cd $T && python3 tools/alt-model-evals/run_eval.py $skill $ids $m --runs $runs ) > $LOG/$s-$name.log 2>&1
    echo "$(date '+%F %T') lane $1 done  $s-$name (exit $?)" >> $LOG/progress.log
  done
}
echo "$(date '+%F %T') start: ${#TASKS[@]} batches, 4 lanes" >> $LOG/progress.log
lane 1 & sleep 20; lane 2 & sleep 20; lane 3 & sleep 20; lane 4 &
wait
echo "$(date '+%F %T') GEMINI ROSTER DONE" >> $LOG/progress.log
