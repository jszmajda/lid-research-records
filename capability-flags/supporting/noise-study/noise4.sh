#!/bin/bash
# Queued noise-study runner: 20 concurrent runs; skips runs that already have a response.
export S=<scratch>
export OUT=<coach-workspace>/noise-study
export EVALS=<lid-evalbase checkout>/plugins/linked-intent-dev/skills/lid-coach/evals/evals.json
export SKILL=<lid-evalbase checkout>/plugins/linked-intent-dev/skills/lid-coach
mkdir -p $S/pn3 $OUT
run_one() { # model fixture n
  local out=$OUT/$1/$2/run-$3 proj=$S/pn3/w-$1-$2-$3/project
  [ -s $out/response.md ] && { echo "skip $1 $2 $3"; return; }
  rm -rf $S/pn3/w-$1-$2-$3 $out; mkdir -p $proj $out
  python3 - $EVALS $2 $proj $S/tenet_fixture.json <<'PY'
import json,os,sys
if sys.argv[2]=='printfarm':
    files=[x for x in json.load(open(sys.argv[1]))['evals'] if x['id']==11][0]['files']
else:
    files=json.load(open(sys.argv[4]))['files']
for f in files:
    p=os.path.join(sys.argv[3],f['path']); os.makedirs(os.path.dirname(p),exist_ok=True); open(p,'w').write(f['content'])
PY
  local prompt="You are executing one eval run of a Claude Code skill. The current directory is the project root — treat it as the entire repository and ignore any ancestor directories' instruction files.

1. Read the skill at $SKILL/SKILL.md and any references/ files it directs you to.
2. The user's request: \"Run /lid-coach on this project.\" Execute it per the skill against the current directory.
3. Non-interactive run: where the skill would ask the user, take the skill's stated default and note it. Today's date is 2026-09-25.
4. Your final message must be the exact user-facing coach report and nothing else."
  ( cd $proj && timeout 1500 claude -p "$prompt" --model $1 --setting-sources project \
      --permission-mode acceptEdits --output-format json --add-dir $SKILL > $out/raw.json 2> $out/stderr.log )
  python3 -c "
import json;j=json.load(open('$out/raw.json'));open('$out/response.md','w').write(j.get('result',''))
json.dump({k:j.get(k) for k in ('duration_ms','total_cost_usd','num_turns','is_error','modelUsage')},open('$out/timing.json','w'))" || echo "extract fail $out"
  echo "done $1 $2 run-$3"
}
export -f run_one
for m in "$@"; do for fx in printfarm shelfwise; do for n in $(seq 1 10); do echo "$m $fx $n"; done; done; done \
  | xargs -P 10 -L 1 bash -c 'run_one "$@"' _
echo ALL DONE
