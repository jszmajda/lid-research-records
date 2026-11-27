# Intent recovery: what the next reader can recover from each approach's files

This folder holds the aggregate records behind one report from LID's cost study: **[What each approach leaves for the next reader](https://linked-intent.dev/research/intent-recovery/)**.

The cost study asks what LID (Linked-Intent Development) costs compared with other ways of working with a coding agent, and what it buys. Its research notebook is [`docs/research/cost-eval/`](https://github.com/jszmajda/lid/tree/main/docs/research/cost-eval) in the LID repository: the design, the decisions and who made them, a dated log, and the code that ran the study. Its first report is [What LID costs, and what it buys: first results](https://linked-intent.dev/research/first-results/).

This report asks a narrower question. After a few changes, what can someone who comes to a project cold, a person or an agent, recover of the owner's intent from what each approach left behind: its tests, or its documents?

## What was tested

Every run behind these records used Claude Sonnet 5.5 at medium effort, in Claude Code 2.1.323. Runs that followed LID used LID 1.4.6. The readers and judges that scored intent recovery were also Claude Sonnet 5.5 at medium effort, in Claude Code 2.1.323. These are pilot results: nothing was pre-registered.

## What's here

| File | What it holds |
|---|---|
| [benchtime-intent-recall.md](benchtime-intent-recall.md) | BenchTime at change 10, three builds per approach (bare agent, cheap discipline, LID Full): how much of the owner's intent a fresh reader recovered from each build's tests, its tests with names and comments replaced, or its docs, against a reader given only the brief. |
| [releasedesk-intent-recall.md](releasedesk-intent-recall.md) | The same measure on ReleaseDesk at changes 10 and 20, one build per approach (bare agent, checklist arm, LID Full), with item counts, the spread between readings, whole-item recall, input sizes, and which retired rules the readers still stated, under letters. |
| [releasedesk-m2e.md](releasedesk-m2e.md) | The results tables of ReleaseDesk's growth trial (the study's M2e run) at changes 10 and 20: requirements met, keeping, reliance forks, flip checks, course forks, stale files, cost, owner reading, intent recovery, repairs, and the cost of working around stale files. |
| [releasedesk-rot-checks.md](releasedesk-rot-checks.md) | The stale-intent audit's counts on the main line and in the course forks, the reliance forks' outcomes, and the instrument's own check on planted stale tests. |
| [clowder-pilot.md](clowder-pilot.md) | The Clowder pilot, structural numbers only: a bare agent on a stripped copy of a repository LID built, a bare agent on the full repository, and LID Full, at two context windows, one run per cell. |

## How the numbers were made

- The intent-recovery figures come from the summaries that [harness/intent_from_tests.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/intent_from_tests.py) writes, scored as [harness/costeval/intent_recall.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/costeval/intent_recall.py) defines. The reader's instructions are [harness/prompts/intent-from-tests.md](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/prompts/intent-from-tests.md) and the judge's are [harness/prompts/intent-match.md](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/prompts/intent-match.md).
- The growth trial's tables come from `render_growth` in [harness/report.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/report.py). The stale-intent audit is [harness/costeval/stale_audit.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/costeval/stale_audit.py).
- Figures not in a generated table (whole-item recall, input sizes, item counts, the retired-rule letters, the audit breakdowns, the Clowder docs edits and per-window context) were summed from the runs' own records in the notebook's local `runs/` folder, and each file says which.
- The checklist arm's whole instruction is [harness/arms/checklist-AGENTS.md](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/arms/checklist-AGENTS.md), and cheap discipline's is [harness/arms/cheap-discipline-AGENTS.md](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/arms/cheap-discipline-AGENTS.md).

## What was withheld, and why

- **The seeds' hidden material:** each project's oracle (the owner's requirements, including the retired ones), its change script, its probes, and the simulated owner's prompts. The study is still running, and later comparisons reuse these seeds, so they stay out of public view until the runs that use them finish ([decisions.md, line 29](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/decisions.md?plain=1#L29)). For the same reason the retired rules appear here as letters, not IDs.
- **The run records:** the agents' transcripts, each reader's written rules, the judge's mappings, and the stale-intent audit's verdicts and reasons. Each of them quotes or paraphrases the oracle, which is why the study keeps them in its git-ignored `runs/` folder ([decisions.md, line 55](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/decisions.md?plain=1#L55)). Only counts, shares, costs and sizes computed from them are here.
- **Per-fork listings** in the growth trial's report, which list each fork's cost and token counts. Their totals are kept, so this folder holds aggregates only.
- **Clowder's content.** Clowder's code, documents, requirements and change requests are private, so its file gives only structural numbers. The study also read some of Clowder's own tests and documents with the intent-recovery measure; those results aren't here, because they can't be reported without describing what is in the project.

## Changes from the notebook's own copies

- The growth trial's generated tables had separator rows one column too wide, which stops them rendering as tables; they are corrected here.
- The notebook's log labels the growth trial's stale-file figures (1 of 12, 4 of 64) as found "in course forks". They come from the audit of each approach's main line at change 20; the course forks' own audits are the figures in brackets. [releasedesk-rot-checks.md](releasedesk-rot-checks.md) gives both.
