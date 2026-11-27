# ReleaseDesk growth trial: results at changes 10 and 20

These are the results tables of the cost study's M2e run, copied from the study's generated report for it. That report is kept in the notebook's local `runs/` folder, which isn't published while the study is running. The tables are copied unchanged, except that:

- the table separator rows are corrected so that each table renders;
- the per-fork listings under "Working around rot" are left out, and only their totals are kept;
- an oracle item's ID in the symptom-report table is replaced by "one row".

**What ran.** ReleaseDesk, a small release-approval service, grown from its brief through 20 changes by three approaches, one trajectory each (replicate g-r1): a bare agent (`bare`), the checklist arm (`checklist`), and LID Full (`lid-full`). Changes 11 to 13 and 16 to 18 are changes of direction ("course changes"). Every run used Claude Sonnet 5.5 at medium effort in Claude Code 2.1.323, and the LID runs used LID 1.4.6. Single runs: pilot observations, not evidence.

**How the tables are made.** `render_growth` in [harness/report.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/report.py) writes them; the intent-from-tests rows come from [harness/intent_from_tests.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/intent_from_tests.py).

Means over trajectories (per trajectory in brackets); counts summed. With one trajectory per arm, each mean is that trajectory's figure.

- Latent: every kind of item that isn't stated (askable, recognized on sight, emerging, realized on a symptom). "Latent disclosed in every arm" keeps to the latent items every arm of the replicate had heard by then.
- Keeping: items met at the previous checkpoint that are still graded and still met.
- Flips: each retirement, reversal, re-reversal and rescope, the retired rule failing after it and the new rule before it. An emerging change's new rule, checked before it, counts as anticipated, never as a flip.
- Course forks behave when the new rule holds and the retired one fails at the fork's end.
- Reliance forks run each course change's reliance request from the trajectory's snapshot after its lag. Displaced-rule rate: forks that followed the displaced rule, of those that followed the current rule, the displaced one, or neither. A fork that met both frozen outcomes is inconsistent: counted apart, outside the rate, and listed for a spot-check.
- Stale files (forks): the first figure is the stale-intent audit of the trajectory itself at the checkpoint, as files judged stale over files judged stale, current or mixed, summed over the course changes (a file relevant to two course changes counts twice). The figure in brackets is the number of files judged stale in the audits of the 18 course forks, summed. [releasedesk-rot-checks.md](releasedesk-rot-checks.md) breaks both down.
- Owner-hours at 238 words a minute; fidelity per owner-hour and per dollar count items met.
- A row realized on a symptom is graded in force from its change, as the oracle's lifetime says, whether or not its report fired; the owner holds it only once the report was delivered. Symptom reports: the scheduled reports that fired by each checkpoint, and the rows graded though their report never fired.
- Probes are at version 4, which adds clock steps to 30 probes and 4 setups. The instrument gate validated version 3 and wasn't rerun, because its reference volumes had been deleted to free disk.
- The intent-from-tests rows still use the version-3 verdicts for which items a build meets. Under version 4, LID's build meets one more item, so LID's "recall of met" figures are over one item fewer than they would be now.

## Change 10

| Arm | Stated | Latent | Latent disclosed in every arm | Keeping | Displaced-rule rate | Flips behaving | Anticipated | Course forks behaving | Stale files (forks) | Cost per change | Owner-hours | Met per owner-hour | Met per $ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bare | 100% [100%] | 75% [75%] | 100% [100%] | – | – | – | – | – | 0/0 (0) | $0.38 | 0.44 | 123.8 | 13.04 |
| lid-full | 92% [92%] | 100% [100%] | 100% [100%] | – | – | – | – | – | 0/0 (0) | $1.81 | 4.06 | 12.8 | 2.61 |
| checklist | 98% [98%] | 75% [75%] | 100% [100%] | – | – | – | – | – | 0/0 (0) | $0.38 | 0.94 | 56.4 | 12.84 |

## Change 20

| Arm | Stated | Latent | Latent disclosed in every arm | Keeping | Displaced-rule rate | Flips behaving | Anticipated | Course forks behaving | Stale files (forks) | Cost per change | Owner-hours | Met per owner-hour | Met per $ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| bare | 98% [98%] | 67% [67%] | 100% [100%] | 49/49 | 0/18 | 8/8 | 1/2 | 18/18 | 1/12 (6) | $0.29 | 0.58 | 102.6 | 9.63 |
| lid-full | 93% [93%] | 100% [100%] | 100% [100%] | 46/48 | 0/18 | 8/8 | 0/1 | 18/18 | 4/64 (18) | $1.59 | 6.64 | 8.9 | 1.77 |
| checklist | 98% [98%] | 78% [78%] | 100% [100%] | 48/48 | 0/18 | 8/8 | 1/2 | 18/18 | 0/13 (1) | $0.34 | 1.47 | 40.9 | 8.32 |

## Symptom reports

| Arm | Checkpoint | Reports fired | Graded though never reported |
|---|---|---|---|
| bare | 10 | 0/1 | – |
| lid-full | 10 | 0/1 | – |
| checklist | 10 | 0/1 | – |
| bare | 20 | 0/2 | one row |
| lid-full | 20 | 0/2 | one row |
| checklist | 20 | 0/2 | one row |

## Intent from tests and docs

A fresh reader given only the build's tests (as written, or with names, comments and docstrings replaced) or its docs, scored against the intent in force (intent_from_tests.py). Means over trajectories.

| Change | Arm | Source | Recall of met | Latent of met | Minus brief baseline | Stale claims /rule | Retired stated |
|---|---|---|---|---|---|---|---|
| 10 | bare | tests | 59% | 100% | 1% | 0.00 | 0% |
| 10 | bare | tests, names replaced | 62% | 100% | 3% | 0.00 | 0% |
| 10 | lid-full | tests | 83% | 94% | 27% | 0.00 | 0% |
| 10 | lid-full | tests, names replaced | 79% | 94% | 24% | 0.00 | 0% |
| 10 | lid-full | docs | 87% | 100% | 31% | 0.00 | 0% |
| 10 | checklist | tests | 52% | 100% | 1% | 0.00 | 0% |
| 10 | checklist | tests, names replaced | 55% | 100% | 4% | 0.00 | 0% |
| 10 | checklist | docs | 85% | 100% | 34% | 0.00 | 0% |
| 20 | bare | tests | 61% | 100% | 10% | 0.04 | 19% |
| 20 | bare | tests, names replaced | 60% | 89% | 9% | 0.06 | 29% |
| 20 | lid-full | tests | 83% | 93% | 35% | 0.04 | 29% |
| 20 | lid-full | tests, names replaced | 80% | 93% | 33% | 0.04 | 29% |
| 20 | lid-full | docs | 83% | 100% | 36% | 0.02 | 29% |
| 20 | checklist | tests | 56% | 100% | 6% | 0.04 | 14% |
| 20 | checklist | tests, names replaced | 48% | 83% | -2% | 0.09 | 29% |
| 20 | checklist | docs | 92% | 100% | 42% | 0.01 | 5% |

## Reliance forks by course change

| Course change | Arm | Current | Displaced | Neither | Both | Undetermined | No probe | Displaced-rule rate |
|---|---|---|---|---|---|---|---|---|
| 11 | bare | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 11 | lid-full | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 11 | checklist | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 12 | bare | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 12 | lid-full | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 12 | checklist | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 13 | bare | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 13 | lid-full | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 13 | checklist | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 16 | bare | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 16 | lid-full | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 16 | checklist | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 17 | bare | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 17 | lid-full | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 17 | checklist | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 18 | bare | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 18 | lid-full | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |
| 18 | checklist | 3 | 0 | 0 | 0 | 0 | 0 | 0/3 |

## Repair forks

For each latent item (any kind but stated) a checkpoint's grading has as not met, one fork from that checkpoint's snapshot, with the trajectory's owner as it stood there, opened by the owner's repair report for the item (run_repair_forks.py). An item the grader couldn't exercise isn't counted as missed.

- Each fork is graded again by a full regrade at the checkpoint's change: every probe in force there (recorded: full).
- Fixed: the item is met in that regrade. Share fixed: of the forks with a decided verdict for the item.
- Cost per fix: the agent cost of each fork that fixed its item.
- Keeping breaks: items met at the checkpoint and not met in the fork's regrade.
- Break-even: the agent cost of every repair fork at the checkpoint, fixed or not, against the arm's agent cost to the checkpoint and its premium over bare on the same replicate. The arm's premium is paid back on rework when bare's repair cost less the arm's is at least the premium; that difference is left blank until both have repaired every miss. Agent costs only, on both sides; the simulated owner's cost is left out.

| Arm | Checkpoint | Missed | Repaired | Fixed | Share fixed | Cost per fix, mean | Cost per fix, median | Keeping breaks |
|---|---|---|---|---|---|---|---|---|
| bare | 10 | 2 | 2 | 2 | 100% | $0.21 | $0.21 | none |
| bare | 20 | 3 | 3 | 3 | 100% | $0.13 | $0.12 | 1 item in 1 of 3 forks |
| lid-full | 10 | 0 | 0 | 0 | – | – | – | none |
| lid-full | 20 | 0 | 0 | 0 | – | – | – | none |
| checklist | 10 | 2 | 2 | 2 | 100% | $0.25 | $0.25 | none |
| checklist | 20 | 2 | 2 | 2 | 100% | $0.28 | $0.28 | 1 item in 1 of 2 forks |

| Arm | Checkpoint | Misses | Fixed | Repair cost, all misses | Agent cost to checkpoint | Premium over bare | Bare's repair cost less the arm's |
|---|---|---|---|---|---|---|---|
| bare | 10 | 2 | 2 | $0.42 | $2.70 | – | – |
| bare | 20 | 3 | 3 | $0.39 | $4.00 | – | – |
| lid-full | 10 | 0 | 0 | $0.00 | $15.23 | $12.53 | $0.42 |
| lid-full | 20 | 0 | 0 | $0.00 | $23.20 | $19.20 | $0.39 |
| checklist | 10 | 2 | 2 | $0.50 | $2.74 | $0.04 | $-0.08 |
| checklist | 20 | 2 | 2 | $0.55 | $4.58 | $0.58 | $-0.17 |

## Working around rot

What each fork's agent spent, set against whether it read a file the stale-intent audit flagged for the fork's course change.

- Files read: the distinct repository files a Read returned or a Bash read named (a partial read included; searches left out). A Bash glob read counts the files of the joined audit it matches, since a fork's workspace isn't kept to list.
- Flagged, in two cuts with neither preferred: files the audit judged "stale" for the fork's course change, and files it judged "stale" or "mixed". A reliance fork takes the trajectory's audit at the nearest checkpoint that covers its course change ("away" counts changes between the fork's snapshot and that checkpoint); a course fork takes its own.
- A reliance fork's audit is of the files as they stand at that checkpoint, which can be several changes after the fork's snapshot, so a flag says the file was stale there, not necessarily when the fork read it.
- Turns: the fork's owner rounds, each one session turn. Model calls: the main thread's API calls over them.
- Cost ÷ R+: the fork's agent cost over R+'s reliance fork for the same request (g-ref-correct). R+ is a clean-build reference on a different codebase, its own build made with every held rule stated, so the ratio sets each fork against a build with no rot, not against the same files.

R+'s reliance forks (a different codebase):

| Course change | Cost | Turns | Files read |
|---|---|---|---|
| 11 | $0.11 | 1 | 6 |
| 12 | $0.07 | 1 | 3 |
| 13 | $0.08 | 1 | 3 |
| 16 | $0.11 | 1 | 4 |
| 17 | $0.11 | 1 | 4 |
| 18 | $0.11 | 1 | 5 |

### bare

| Reliance forks | Forks | Cost, mean | Cost, median | Turns, mean | Turns, median | Model calls, mean | Model calls, median | Files read, mean | Files read, median | Cost ÷ R+, median | Current | Displaced | Neither | Other |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| read a stale file | 3 | $0.14 | $0.08 | 1.3 | 1.0 | 12.7 | 11.0 | 3.7 | 3.0 | 0.8× | 3 | 0 | 0 | 0 |
| read no stale file | 15 | $0.13 | $0.10 | 1.3 | 1.0 | 12.3 | 11.0 | 4.1 | 4.0 | 1.0× | 15 | 0 | 0 | 0 |
| read a stale or mixed file | 9 | $0.12 | $0.11 | 1.1 | 1.0 | 11.3 | 11.0 | 3.9 | 3.0 | 1.0× | 9 | 0 | 0 | 0 |
| read no stale or mixed file | 9 | $0.14 | $0.09 | 1.6 | 1.0 | 13.3 | 10.0 | 4.2 | 4.0 | 1.0× | 9 | 0 | 0 | 0 |

| Course forks | Forks | Cost, mean | Cost, median | Turns, mean | Turns, median | Model calls, mean | Model calls, median | Files read, mean | Files read, median | Behaved | Didn't | Undetermined |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| read a stale file | 3 | $0.13 | $0.13 | 1.0 | 1.0 | 10.0 | 10.0 | 4.7 | 5.0 | 3 | 0 | 0 |
| read no stale file | 15 | $0.22 | $0.15 | 1.3 | 1.0 | 14.3 | 11.0 | 4.5 | 5.0 | 15 | 0 | 0 |
| read a stale or mixed file | 6 | $0.13 | $0.13 | 1.0 | 1.0 | 10.2 | 10.0 | 4.7 | 5.0 | 6 | 0 | 0 |
| read no stale or mixed file | 12 | $0.24 | $0.17 | 1.4 | 1.0 | 15.3 | 15.0 | 4.4 | 4.5 | 12 | 0 | 0 |

### lid-full

| Reliance forks | Forks | Cost, mean | Cost, median | Turns, mean | Turns, median | Model calls, mean | Model calls, median | Files read, mean | Files read, median | Cost ÷ R+, median | Current | Displaced | Neither | Other |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| read a stale file | 1 | $0.52 | $0.52 | 6.0 | 6.0 | 32.0 | 32.0 | 12.0 | 12.0 | 4.8× | 1 | 0 | 0 | 0 |
| read no stale file | 17 | $0.48 | $0.46 | 6.3 | 6.0 | 26.0 | 24.0 | 7.6 | 7.0 | 4.8× | 17 | 0 | 0 | 0 |
| read a stale or mixed file | 9 | $0.52 | $0.49 | 6.6 | 6.0 | 29.0 | 29.0 | 8.7 | 8.0 | 5.4× | 9 | 0 | 0 | 0 |
| read no stale or mixed file | 9 | $0.45 | $0.46 | 6.0 | 6.0 | 23.7 | 24.0 | 7.1 | 7.0 | 4.3× | 9 | 0 | 0 | 0 |

| Course forks | Forks | Cost, mean | Cost, median | Turns, mean | Turns, median | Model calls, mean | Model calls, median | Files read, mean | Files read, median | Behaved | Didn't | Undetermined |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| read a stale file | 7 | $1.19 | $1.05 | 8.1 | 9.0 | 41.9 | 40.0 | 15.0 | 15.0 | 7 | 0 | 0 |
| read no stale file | 11 | $1.07 | $0.91 | 8.6 | 8.0 | 43.0 | 40.0 | 14.2 | 14.0 | 11 | 0 | 0 |
| read a stale or mixed file | 10 | $1.25 | $1.07 | 8.6 | 9.0 | 44.8 | 40.5 | 16.2 | 16.0 | 10 | 0 | 0 |
| read no stale or mixed file | 8 | $0.94 | $0.74 | 8.2 | 8.0 | 39.8 | 32.5 | 12.4 | 11.0 | 8 | 0 | 0 |

### checklist

| Reliance forks | Forks | Cost, mean | Cost, median | Turns, mean | Turns, median | Model calls, mean | Model calls, median | Files read, mean | Files read, median | Cost ÷ R+, median | Current | Displaced | Neither | Other |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| read no stale file | 18 | $0.14 | $0.14 | 2.1 | 2.0 | 10.9 | 10.0 | 3.7 | 4.0 | 1.4× | 18 | 0 | 0 | 0 |
| read a stale or mixed file | 8 | $0.14 | $0.14 | 2.1 | 2.0 | 10.8 | 10.5 | 4.1 | 4.0 | 1.4× | 8 | 0 | 0 | 0 |
| read no stale or mixed file | 10 | $0.15 | $0.15 | 2.0 | 2.0 | 11.1 | 10.0 | 3.4 | 3.5 | 1.5× | 10 | 0 | 0 | 0 |

| Course forks | Forks | Cost, mean | Cost, median | Turns, mean | Turns, median | Model calls, mean | Model calls, median | Files read, mean | Files read, median | Behaved | Didn't | Undetermined |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| read a stale file | 1 | $0.16 | $0.16 | 2.0 | 2.0 | 14.0 | 14.0 | 6.0 | 6.0 | 1 | 0 | 0 |
| read no stale file | 17 | $0.21 | $0.16 | 2.3 | 2.0 | 14.7 | 13.0 | 4.8 | 4.0 | 17 | 0 | 0 |
| read a stale or mixed file | 8 | $0.20 | $0.16 | 1.9 | 2.0 | 14.2 | 13.5 | 4.8 | 4.5 | 8 | 0 | 0 |
| read no stale or mixed file | 10 | $0.20 | $0.17 | 2.6 | 2.0 | 15.0 | 12.5 | 4.9 | 4.5 | 10 | 0 | 0 |
