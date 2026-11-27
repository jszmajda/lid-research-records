#!/bin/bash
# 2026-10-19: finish the 2026-10-18 roster after a network outage (~00:58) stopped two lanes.
# Same stripped copy of 919c4b4 (tree 3a5bd791). Partial evals rerun whole (10 runs) so each eval cell comes from one batch.
# At most 3 lanes on the colima VM.
T=<lid-evalstrip-1016 checkout>
LOG=<workspace>/roster/logs-1019
mkdir -p $LOG
run() { local name=$1; shift; ( cd $T && python3 tools/alt-model-evals/run_eval.py "$@" ) > $LOG/$name.log 2>&1; echo "$(date '+%F %T') done $name" >> $LOG/progress.log; }
( run google_gemini-3.8-flash-coach16 lid-coach 16 google/gemini-3.8-flash --runs 10
  run google_gemini-3.8-flash-update update-lid all google/gemini-3.8-flash --runs 1 ) &
( run xiaomi_mimo-v2.6-flash-core3 linked-intent-dev 3 xiaomi/mimo-v2.6-flash --runs 10
  run xiaomi_mimo-v2.6-flash-update update-lid all xiaomi/mimo-v2.6-flash --runs 1 ) &
( run xiaomi_mimo-v2.6-flash-coach lid-coach 10,11,15,16 xiaomi/mimo-v2.6-flash --runs 10 ) &
wait
echo "$(date '+%F %T') RESUME DONE" >> $LOG/progress.log
