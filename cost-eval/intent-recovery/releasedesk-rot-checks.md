# ReleaseDesk: stale files and whether they misled a later agent

Counts from the cost study's growth trial on ReleaseDesk, grown through 20 changes once by each of three approaches (replicate g-r1): a bare agent, the checklist arm, and LID Full. Six of changes 11 to 20 are changes of direction ("course changes": changes 11, 12, 13, 16, 17 and 18). The counts are summed from the stale-intent audits and fork records in the notebook's local `runs/` folder, which isn't published while the study is running. The audit's verdicts and reasons quote the system's rules, so only the counts are here.

## The stale-intent audit

A blind reader looked at every test and doc that a course change touched, or should have touched, and judged whether anything in its names, comments or assertions contradicts current intent: **stale** (it does), **mixed** (partly), **current** (it doesn't), or **unrelated** (it turns out not to bear on the rule). Arm labels never reached the reader, and LID's own vocabulary (spec IDs, `@spec` annotations, EARS, HLD, LLD, the `docs/intent` tree) was stripped from what it read, so LID's files read like any other approach's. The audit is in [harness/costeval/stale_audit.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/costeval/stale_audit.py).

**On the main line, at change 20.** Each course change's files as they stood at change 20, summed over the six course changes, so a file relevant to two course changes counts twice:

| Approach | Stale | Mixed | Current | Unrelated | Stale, of files judged stale, mixed or current |
|---|---|---|---|---|---|
| bare | 1 | 3 | 8 | 0 | 1 of 12 (8%) |
| checklist | 0 | 4 | 9 | 11 | 0 of 13 (0%) |
| LID Full | 4 | 3 | 57 | 71 | 4 of 64 (6%) |

LID's four stale files fell under three of the six course changes; bare's one under one.

**In the course forks.** Each course change was also rerun three times from the snapshot before it (18 forks per approach), and each fork's files were audited right after it:

| Approach | Stale | Mixed | Current | Unrelated | Stale, of files judged stale, mixed or current | Forks that left at least one stale file |
|---|---|---|---|---|---|---|
| bare | 6 | 3 | 25 | 2 | 6 of 34 (18%) | 4 of 18 |
| checklist | 1 | 10 | 30 | 31 | 1 of 41 (2%) | 1 of 18 |
| LID Full | 18 | 10 | 158 | 218 | 18 of 186 (10%) | 12 of 18 |

Every course fork of every approach behaved: the new rule held and the retired one no longer did at the fork's end (18 of 18 each).

The trial's results table ([releasedesk-m2e.md](releasedesk-m2e.md), column "Stale files (forks)") shows the main-line figure first and the course forks' stale count in brackets: 1/12 (6), 4/64 (18) and 0/13 (1).

## Reliance forks: did a stale file mislead the next change?

Each course change has a reliance request: an ordinary request in the overturned rule's area that never mentions the rule, whose correct outcome differs under the current rule and the displaced one. It ran three times per course change (18 forks per approach), each from the trajectory's own snapshot two to five changes after the course change, and was then discarded.

| Approach | Forks | Followed the current rule | Followed the displaced rule | Neither | Forks that read a file the audit judged stale | Of those, followed the current rule |
|---|---|---|---|---|---|---|
| bare | 18 | 18 | 0 | 0 | 3 | 3 |
| checklist | 18 | 18 | 0 | 0 | 0 | – |
| LID Full | 18 | 18 | 0 | 0 | 1 | 1 |

A reliance fork's audit is of the files at change 20, which can be several changes after the fork's snapshot, so "read a stale file" means the file was stale at change 20, not necessarily when the fork read it.

## The instrument's own check

Before any approach ran, stale tests were planted in a correct reference build's tests, and the same readers used for intent-from-tests had to name them. At change 20 they caught 83% of planted rules when the tests were read as written, and 33% of the plants carried only by test names once names and comments were replaced, as expected. These figures are tracked in the notebook's log ([log-archive/2026-11.md, lines 148 to 157](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/log-archive/2026-11.md?plain=1#L148-L157)).
