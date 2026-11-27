#!/bin/bash
# 2026-11-11: retry stepfun/step-5-preview after the top-10 roster. Through opencode, OpenRouter routes it only to
# Featherless (StepFun's own endpoint rejects tool_choice), and Featherless was at capacity when the roster started.
# Waits for the roster to finish, polls Featherless's endpoint status every 5 minutes for up to 3 hours, then runs
# Step's full roster in 3 lanes on the same stripped copy (tree 3a5bd791). Effort medium.
T=<lid-evalstrip-1109 checkout>
LOG=<workspace>/roster/logs-1111c
M=stepfun/step-5-preview
mkdir -p $LOG
until grep -q "MINIMAX RERUN DONE" $LOG/../logs-1111d/progress.log 2>/dev/null; do sleep 30; done
up() { curl -s -m 30 https://openrouter.ai/api/v1/models/$M/endpoints | python3 -c 'import json,sys; e=[x for x in json.load(sys.stdin)["data"]["endpoints"] if x["provider_name"]=="Featherless"]; sys.exit(0 if e and e[0].get("status")==0 and (e[0].get("uptime_last_30m") or 0)>=50 else 1)'; }
for i in $(seq 1 36); do up && break; echo "$(date '+%F %T') Featherless still down" >> $LOG/progress.log; sleep 300; done
up || { echo "$(date '+%F %T') GAVE UP: Featherless down for 3 hours" >> $LOG/progress.log; exit 1; }
echo "$(date '+%F %T') Featherless up; starting Step" >> $LOG/progress.log
run() { local name=$1; shift; ( cd $T && python3 tools/alt-model-evals/run_eval.py "$@" ) > $LOG/$name.log 2>&1; echo "$(date '+%F %T') done $name" >> $LOG/progress.log; }
( run core01 linked-intent-dev 0,1 $M --runs 10; run coach10 lid-coach 10 $M --runs 10 ) &
( run core23 linked-intent-dev 2,3 $M --runs 10; run coach11 lid-coach 11 $M --runs 10 ) &
( run coach1516 lid-coach 15,16 $M --runs 10; run update update-lid all $M --runs 1 ) &
wait
echo "$(date '+%F %T') STEP RETRY DONE" >> $LOG/progress.log
