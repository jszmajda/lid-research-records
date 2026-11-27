#!/bin/bash
# 2026-11-11: rerun minimax/minimax-m3.1-flash core evals 1, 2 and 3 whole (10 runs each, one batch per eval), after
# 13 of its runs on those evals hit the 10-minute limit in the top-10 roster (the evidence bar reruns cut-short runs).
# Same stripped copy (tree 3a5bd791). Then hands off to the Step 5 Preview retry. At most 3 lanes on the colima VM.
T=<lid-evalstrip-1109 checkout>
R=<workspace>/roster
LOG=$R/logs-1111d
M=minimax/minimax-m3.1-flash
mkdir -p $LOG
run() { local name=$1; shift; ( cd $T && python3 tools/alt-model-evals/run_eval.py "$@" ) > $LOG/$name.log 2>&1; echo "$(date '+%F %T') done $name" >> $LOG/progress.log; }
run core1 linked-intent-dev 1 $M --runs 10 &
run core2 linked-intent-dev 2 $M --runs 10 &
run core3 linked-intent-dev 3 $M --runs 10 &
wait
echo "$(date '+%F %T') MINIMAX RERUN DONE" >> $LOG/progress.log
exec $R/runner-step-retry-1111.sh
