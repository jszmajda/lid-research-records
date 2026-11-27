#!/bin/bash
# claude -p eval harness for LID skills (maintainer tooling, gitignored workspace).
# Usage: suite.sh SKILL MODEL EFFORT RUNS OUTDIR TREE [EVAL_IDS...]
#   SKILL: skill dir name (linked-intent-dev, lid-coach); TREE: pinned git worktree of the repo.
# Per run: prompt.txt, raw.json, response.md, changes1.patch (after turn 1, when a follow_up exists),
# raw2.json + response2.md (follow-up turn via --resume), changes.patch (final), project/ (final tree), timing.json.
export SKILLNAME=$1 MODEL=$2 EFFORT=$3 RUNS=$4 OUT=$5 TREE=$6; shift 6
export SKILL=$TREE/plugins/linked-intent-dev/skills/$SKILLNAME
export EVALS=${EVALS_OVERRIDE:-$SKILL/evals/evals.json}
export WORK=${TMPDIR:-/tmp}/lid-suite-projects
# The model reads skills from a staged copy without evals/ or *-workspace/ dirs, so no assertion or earlier run output is reachable.
export STAGE=$WORK/plugins-$(python3 -c "import secrets;print(secrets.token_hex(4))")
mkdir -p $STAGE && rsync -a --exclude 'evals/' --exclude '*-workspace/' $TREE/plugins/ $STAGE/plugins/
export SEEN=$STAGE/plugins/linked-intent-dev/skills/$SKILLNAME
IDS="$@"; [ -z "$IDS" ] && IDS=$(python3 -c "import json;print(' '.join(str(e['id']) for e in json.load(open('$EVALS'))['evals']))")
run_one() { # id n
  local tag=$(python3 -c "import secrets;print(secrets.token_hex(5))")
  local proj=$WORK/w-$tag/project out=$OUT/eval-$1/run-$2
  [ -s $out/response.md ] && return
  rm -rf $out; mkdir -p $proj $out
  python3 - $EVALS $1 $proj $out <<'PY'
import json,os,sys
e=[x for x in json.load(open(sys.argv[1]))['evals'] if x['id']==int(sys.argv[2])][0]
for f in e.get('files',[]):
    p=os.path.join(sys.argv[3],f['path']); os.makedirs(os.path.dirname(p) or '.',exist_ok=True); open(p,'w').write(f['content'])
open(os.path.join(sys.argv[4],'prompt.txt'),'w').write(e['prompt'])
open(os.path.join(sys.argv[4],'follow_up.txt'),'w').write((e.get('follow_up') or {}).get('prompt',''))
PY
  ( cd $proj && git init -q && git add -A && git -c user.name=fixture -c user.email=f@x commit -q --allow-empty -m fixture )
  local req=$(cat $out/prompt.txt)
  local L3="Non-interactive run: where the skill would ask the user, take the skill's stated default and note it."
  [ -s $out/follow_up.txt ] && L3="The user will read your final message and reply. Where the skill directs you to ask the user, ask in your final message and stop; do not answer for them."
  local prompt="You are executing one eval run of a Claude Code skill. The current directory is the project root — treat it as the entire repository and ignore any ancestor directories' instruction files.

1. Read the skill at $SEEN/SKILL.md and any references/ files it directs you to. Sibling skills live under $STAGE/plugins/.
2. The user's request: \"$req\" Execute it per the skill against the current directory.
3. $L3 Today's date is $(date +%F).
4. Your final message must be the exact user-facing response and nothing else."
  ( cd $proj && timeout 1500 claude -p --effort $EFFORT "$prompt" --model $MODEL --setting-sources project \
      --permission-mode acceptEdits --output-format json --add-dir $STAGE/plugins > $out/raw.json 2> $out/stderr.log )
  python3 -c "import json;j=json.load(open('$out/raw.json'));open('$out/response.md','w').write(j.get('result',''))" || echo "extract fail $out"
  local fup=$(cat $out/follow_up.txt)
  if [ -n "$fup" ]; then
    ( cd $proj && git add -A >/dev/null 2>&1; git diff --cached HEAD > $out/changes1.patch )
    local sid=$(python3 -c "import json;print(json.load(open('$out/raw.json')).get('session_id',''))")
    ( cd $proj && timeout 1500 claude -p --effort $EFFORT --resume "$sid" "$fup" --model $MODEL --setting-sources project \
        --permission-mode acceptEdits --output-format json --add-dir $STAGE/plugins > $out/raw2.json 2> $out/stderr2.log )
    python3 -c "import json;j=json.load(open('$out/raw2.json'));open('$out/response2.md','w').write(j.get('result',''))" || echo "extract2 fail $out"
  fi
  ( cd $proj && git add -A >/dev/null 2>&1; git diff --cached HEAD > $out/changes.patch )
  rsync -a --exclude .git $proj/ $out/project/
  python3 -c "
import json;j=json.load(open('$out/raw.json'))
t={k:j.get(k) for k in ('duration_ms','total_cost_usd','num_turns','is_error','modelUsage')}
try: t['follow_up']={k:v for k,v in json.load(open('$out/raw2.json')).items() if k in ('duration_ms','num_turns','is_error','modelUsage')}
except Exception: pass
json.dump(t,open('$out/timing.json','w'))" || echo "timing fail $out"
  rm -rf $WORK/w-$tag
  echo "done eval-$1 run-$2"
}
export -f run_one
mkdir -p $WORK $OUT
for id in $IDS; do for n in $(seq 1 $RUNS); do echo "$id $n"; done; done | xargs -P ${PAR:-6} -L 1 bash -c 'run_one "$@"' _
rm -rf $STAGE
echo ALL DONE
