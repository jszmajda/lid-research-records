# Harness comparison: claude-sonnet-4-5 under claude -p vs opencode (2026-09-28)

Same model, same pinned tree (48f1218e, which includes coach dimension 19), evals 11 and 15, 10 runs each per harness. Also compared: the earlier opencode eval-11 runs on d65815bc (no dimension 19) against the `claude -p` noise-study runs on near-identical text. All 70 reports were graded blind in one batch, with 10 controls; the grader agreed with all 10 control grades. No run modified project files. Grades are in this directory.

| Config | eval 11 A1 capture | A2 separate | A3 remedy | A4 restraint | A5 tenet | eval 15 tenet | eval 15 restraint |
|---|---|---|---|---|---|---|---|
| claude -p, new tree | 1 | 1 | 0 | 5 | **7** | 0 | 9 |
| opencode, new tree | 0 | 0 | 0 | 6 | **0** | 0 | 9 |
| claude -p, old tree | 5 | 5 | 0 | 4 | 3 | — | — |
| opencode, old tree | 0 | 0 | 0 | 6 | 0 | — | — |

(out of 10 each)

Cost for 20 runs: claude -p $9.63, opencode $3.96.

Known mechanical difference: opencode's `read` tool caps output at 50 KB (the model does page on to the rest) and **truncates any line longer than 2000 characters**. Coach SKILL.md line 123 (principle body, *Docs carry current intent*) is 3136 characters, so opencode loses its tail: the landed-state test, the row-default remedy, the decision-doc reserve bar, and the cold-read-pass audit signal. That plausibly explains the capture gap on the old tree (5 vs 0). It does not obviously explain the tenet gap (7 vs 0), because dimension 19 sits on a line under 2000 characters.

Side finding (claude -p): adding dimension 19 moved Sonnet 4.5's tenet detection on eval 11 from 3 to 7, while its decision-capture finding fell from 5 to 1. This looks like the displacement pattern again: the tenet finding replaces the capture finding rather than standing beside it. On eval 15, dimension 19 left tenet detection at 0/10.

## Follow-ups (2026-09-28): the runner fix, then reasoning

Every batch was graded blind with 10 controls mixed in; the grader agreed with every earlier grade across 171 control assertion checks. Grades and keys are in `followups/`.

| Sonnet 4.5, eval 11, tree 6c8c0029 | A1 capture | A4 restraint | A5 tenet |
|---|---|---|---|
| claude -p (Claude Code default, **thinking on**) | 1 | 5 | **7** |
| claude -p, `MAX_THINKING_TOKENS=0` (**thinking off**) | 1 | 3 | **0** |
| opencode, native skill tool (fa65c5b1), reasoning default (off) | 1 | 5 | 0 |
| opencode, native skill tool, `--variant high` (about 80 reasoning tokens per run) | 0 | 3 | 0 |

On eval 15, both harnesses score 0/10 on the tenet assertion (thinking on, opencode default).

Reading:
1. **The harness delta is small once reasoning matches.** With thinking off, claude -p matches opencode on every assertion. The large gap was Claude Code's default extended thinking against OpenRouter's reasoning-off default.
2. **The file-read line cut was a runner artifact, now fixed.** Loading through opencode's skill tool closes the capture gap (0 to 1, matching claude -p). The skill tool still caps output at 51,200 bytes, which drops the last ~6 KB of the 57 KB coach SKILL.md (report-format sections). Real opencode users hit that too.
3. **`--variant high` does not reproduce Claude Code's thinking** for anthropic/claude-sonnet-4.5 via OpenRouter: median reasoning tokens stayed near 80.
4. **The capability-flag evidence depends on reasoning.** Every claude -p baseline ran with Claude Code's default thinking. For Sonnet 4.5 on eval 11, thinking is the difference between 7/10 and 0/10. On eval 15 it fails even with thinking on.
