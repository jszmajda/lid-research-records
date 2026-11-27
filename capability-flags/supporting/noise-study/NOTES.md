# Noise study: design-contradicts-own-tenet detection (capability-flag candidate)

Run 2026-09-25. Skill: lid-coach with the row-only Decisions sweep. Harness: `claude -p --setting-sources project`, opaque scratch dirs, 10 runs per (model, fixture). Graded blind: a grader that could not see which model wrote each report scored one criterion, whether the report connects the mechanism to the project's own tenet or goal. Inputs are archived here: `noise.sh`, `tenet_fixture.json`, `blind_key.json`, `blind_grades.json`.

Fixtures:
- **printfarm** is eval 11: the in-memory queue drops jobs on restart, against "a submitted job is a promise".
- **shelfwise** was authored blind for this study: a branch-first hold allocation serves later local patrons first, against "waiting is honored in sequence". Its wording avoids overlap between tenet and mechanism.

| Model | printfarm | shelfwise |
|---|---|---|
| claude-sonnet-4-5 | 4/10 (Wilson 95%: 0.17–0.69) | 0/10 (0.00–0.28) |
| claude-sonnet-5 | 10/10 (0.72–1.00) | 9/10 (0.60–0.98) |
| Fisher exact p | 0.011 | 0.0001 |

The evidence bar is met on all three points: at least 10 runs per configuration; on each fixture the two models' intervals do not overlap, so the gap exceeds same-model spread; and the gap holds on 2 fixtures.

The noise itself: claude-sonnet-4-5 on printfarm is genuinely stochastic. Earlier pilots scored it 0/3 and 1/3, and this study 4/10. Its passes also tend to be weaker, e.g. one low-priority finding and one tension mentioned inside another finding's detail. Runs of 3 could not have separated these models. Runs of 10 do, because the gap is large.

## Baselines across all reachable models (2026-09-25)

Same protocol, 8 more models, 10 runs × 2 fixtures each. All 200 reports were re-graded blind by 4 graders, 50 reports each. The re-grade matched the first 40 grades exactly (40/40). `claude-opus-4-20250514` and `claude-opus-4-1` were not run: the CLI accepts those names but silently runs `claude-opus-5-5` (checked via `modelUsage`). One `claude-fable-5-1` run (printfarm run-6) included a small `claude-opus-5-5` side call, about 5% of that run's cost.

| Model | printfarm | shelfwise |
|---|---|---|
| claude-haiku-4-5 | 0/10 | 0/10 |
| claude-sonnet-4-5 | 4/10 | 0/10 |
| claude-sonnet-4-6 | 4/10 | 0/10 |
| claude-opus-4-5 | 0/10 | 0/10 |
| claude-opus-4-6 | 5/10 | 0/10 |
| claude-sonnet-5 | 10/10 | 9/10 |
| claude-opus-5 | 10/10 | 10/10 |
| claude-opus-5-5 | 10/10 | 10/10 |
| claude-fable-5 | 10/10 | 10/10 |
| claude-fable-5-1 | 10/10 | 10/10 |

The split is by model generation, not size tier. Every 4.x model misses, including the large ones; every 5.x model catches it, including the mid-tier one. Total cost of the 160 new runs: about $124.

## Opus 4.7 and 4.8 (2026-09-27, claude -p)

Same protocol, run against the skill text pinned at d65815bc. Graded blind with 20 earlier reports mixed in as controls; the grader agreed with all 20 earlier grades.

| Model | printfarm | shelfwise |
|---|---|---|
| claude-opus-4-7 (2026-04) | 1/10 | 1/10 (3/10 if lenient) |
| claude-opus-4-8 (2026-05) | 5/10 | 6/10 (8/10 if lenient) |

"If lenient" counts 4 close calls: reports that tie the branch-first rule to the tenet but never describe the later-patron-first case the criterion requires. Opus 4.8 sits between the two groups, so the picture is not a clean generational step: capability rises through the late 4.x models.

## GLM 5.3 family (2026-09-27, alt-model runner: opencode-ai@1.18.32)

Run against commit 48f1218e (plugins tree 6c8c0029), which **adds coach dimension 19, Tenet cascade**, an explicit instruction to check leaf designs against HLD tenets. Evals 11 and 15, 10 runs each; 59 completed and 1 harness error (5.3-prime, eval 15). Every assertion was graded blind; grades are in `glm-2026-09-27/`. No run modified project files.

| Model | eval 11 tenet (A5) | eval 15 tenet (A1) | eval 11 all | eval 15 all |
|---|---|---|---|---|
| z-ai/glm-5.3-prime | 10/10 | 7/9 | 55/60 | 22/27 |
| z-ai/glm-5.3 | 10/10 | 9/10 | 53/60 | 26/30 |
| z-ai/glm-5.3-flash | 9/10 | 5/10 | 46/60 | 23/30 |

**Not comparable with the Claude table.** Two things differ: the harness (opencode vs claude -p), and the skill text, since the Claude baselines ran before dimension 19 existed. Weak spots: restraint on eval 15 (flagging a second mechanism as a tenet conflict: 6–8 of 10 pass), and the smallest-capture remedy on eval 11 (A3: 4–7 of 10).
