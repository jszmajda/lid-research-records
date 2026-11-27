#!/bin/bash
S=<scratch>
OUT=<coach-workspace>/noise-study
EVALS=<lid checkout>/plugins/linked-intent-dev/skills/lid-coach/evals/evals.json
SKILL=<lid checkout>/plugins/linked-intent-dev/skills/lid-coach
mkdir -p $S/pn $OUT
run_one() { # model fixture n tag
  local proj=$S/pn/w-$4/project out=$OUT/$1/$2/run-$3
  rm -rf $S/pn/w-$4; mkdir -p $proj $out
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
  ( cd $proj && timeout 1200 claude -p "$prompt" --model $1 --setting-sources project \
      --permission-mode acceptEdits --output-format json --add-dir $SKILL > $out/raw.json 2> $out/stderr.log )
  python3 -c "
import json;j=json.load(open('$out/raw.json'));open('$out/response.md','w').write(j.get('result',''))
json.dump({k:j.get(k) for k in ('duration_ms','total_cost_usd','num_turns','is_error')},open('$out/timing.json','w'))" || echo "extract fail $out"
  echo "done $1 $2 run-$3"
}
t=0
for m in claude-sonnet-4-5 claude-sonnet-5; do for fx in printfarm shelfwise; do
  for n in $(seq 1 10); do t=$((t+1)); run_one $m $fx $n q$t & done; wait
done; done
echo ALL DONE
