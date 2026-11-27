#!/bin/bash
# 2026-10-24: Claude models via claude -p (suite.sh), effort medium, on the stripped copy of 919c4b4 (tree 3a5bd791).
# suite.sh gives the model a staged copy without evals/ or *-workspace/ dirs.
# Usage: claude-roster-1024.sh MODEL [MODEL...]   (models run one after another; PAR runs within a model)
# Per model: core 0-3 x10, coach 10,11,15,16 x10, update-lid x1. Opus/Fable: skip update-lid.
T=<lid-evalstrip-1016 checkout>
W=<workspace>/
OUT=$W/roster/claude-1024
LOG=$W/roster/logs-1024
mkdir -p $OUT $LOG
for m in "$@"; do
  PAR=${PAR:-6} $W/suite.sh linked-intent-dev $m medium 10 $OUT/$m/core $T > $LOG/$m-core.log 2>&1
  PAR=${PAR:-6} $W/suite.sh lid-coach $m medium 10 $OUT/$m/coach $T 10 11 15 16 > $LOG/$m-coach.log 2>&1
  case $m in *opus*|*fable*) ;; *) PAR=${PAR:-6} $W/suite.sh update-lid $m medium 1 $OUT/$m/update $T > $LOG/$m-update.log 2>&1 ;; esac
  echo "$(date '+%F %T') claude done $m" >> $LOG/progress.log
done
echo "$(date '+%F %T') CLAUDE ROSTER DONE: $*" >> $LOG/progress.log
