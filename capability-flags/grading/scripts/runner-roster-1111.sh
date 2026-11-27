#!/bin/bash
# 2026-11-11: openai/gpt-6.1-terra via the alt-model runner, on the same stripped copy of 919c4b4 as the 2026-10-16..24 rows
# (tree 3a5bd791, rebuilt in a fresh worktree from the tree object; capability check per ALT-EVAL-REC-005 rerun before launch).
# One model split across 3 lanes (colima VM limit). Each eval cell comes from one batch. Effort medium (runner default).
T=<lid-evalstrip-1109 checkout>
LOG=<workspace>/roster/logs-1111
M=openai/gpt-6.1-terra
mkdir -p $LOG
run() { local name=$1; shift; ( cd $T && python3 tools/alt-model-evals/run_eval.py "$@" ) > $LOG/$name.log 2>&1; echo "$(date '+%F %T') done $name" >> $LOG/progress.log; }
( run core01 linked-intent-dev 0,1 $M --runs 10; run coach10 lid-coach 10 $M --runs 10 ) &
( run core23 linked-intent-dev 2,3 $M --runs 10; run coach11 lid-coach 11 $M --runs 10 ) &
( run coach1516 lid-coach 15,16 $M --runs 10; run update update-lid all $M --runs 1 ) &
wait
echo "$(date '+%F %T') TERRA ROSTER DONE" >> $LOG/progress.log
