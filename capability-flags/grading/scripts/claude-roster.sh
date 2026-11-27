#!/bin/bash
# Roster, Claude models via claude -p (suite.sh), from the pinned tree, effort medium.
# Usage: claude-roster.sh MODEL [MODEL...]   (models run one after another; PAR runs within a model)
# Low/mid tier: core 0-3 x10, coach 10,11,15,16 x10, update-lid x1. Opus/Fable: skip update-lid.
T=<lid-evalrun12 checkout>
W=<workspace>/
OUT=$W/roster/claude
mkdir -p $OUT $W/roster/logs
for m in "$@"; do
  PAR=${PAR:-6} $W/suite.sh linked-intent-dev $m medium 10 $OUT/$m/core $T > $W/roster/logs/$m-core.log 2>&1
  PAR=${PAR:-6} $W/suite.sh lid-coach $m medium 10 $OUT/$m/coach $T 10 11 15 16 > $W/roster/logs/$m-coach.log 2>&1
  case $m in *opus*|*fable*) ;; *) PAR=${PAR:-6} $W/suite.sh update-lid $m medium 1 $OUT/$m/update $T > $W/roster/logs/$m-update.log 2>&1 ;; esac
  echo "claude done $m" >> $W/roster/logs/progress.log
done
