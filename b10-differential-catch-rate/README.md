# B10: does the bidirectional differential catch planted intent gaps?

These are the raw records kept from B10, an experiment run on 2 and 3 August 2026 for the Linked-Intent Development (LID) project. B10 planted 24 known gaps between requirements and code in one segment of [portfolio-tracker](https://github.com/jszmajda/portfolio-tracker) (the `sheets-view` crate, 24 requirements) and counted how many of them LID's two-way audit, the bidirectional differential, caught. It ran as a standalone harness written for the experiment, not as the skill LID ships.

- **The report:** https://linked-intent.dev/research/differential-catch-rate/
- **Maintainer:** Jess Szmajda.

## The study's notebook, in the LID repository

The design, results and scoring live in the LID repository, beside the experiment's other files:

- [DESIGN.md](https://github.com/jszmajda/lid/blob/main/docs/research/experiments/b10-differential-catch-rate/DESIGN.md): the hypothesis, pass mark and readouts fixed before the runs, with the amendments made before seeding and after the pilot.
- [PILOT.md](https://github.com/jszmajda/lid/blob/main/docs/research/experiments/b10-differential-catch-rate/PILOT.md): the two-seed shakeout.
- [RESULTS.md](https://github.com/jszmajda/lid/blob/main/docs/research/experiments/b10-differential-catch-rate/RESULTS.md): the results as written on 3 August.
- [CRITIQUE.md](https://github.com/jszmajda/lid/blob/main/docs/research/experiments/b10-differential-catch-rate/CRITIQUE.md): a later adversarial review by model reviewers.
- [scoring-final.json](https://github.com/jszmajda/lid/blob/main/docs/research/experiments/b10-differential-catch-rate/scoring-final.json) and [scoring.json](https://github.com/jszmajda/lid/blob/main/docs/research/experiments/b10-differential-catch-rate/scoring.json): the final tallies, and the tallies from before the human adjudication pass, with per-seed outcomes, finding ranks, classification codes and stability ratings.
- [answer-key/](https://github.com/jszmajda/lid/tree/main/docs/research/experiments/b10-differential-catch-rate/answer-key): the sealed key, the seed plan, one patch per seed, the seeding sessions' self-audits, the human adjudication record, and `adjudication-mapping.json`, which maps the blind labels (`R01`, `S1` and so on) to units and arms.
- [harness/](https://github.com/jszmajda/lid/tree/main/docs/research/experiments/b10-differential-catch-rate/harness): the frozen audit prompts, the script that built the code-only audit trees, the OpenAI caller and driver, the model IDs for the GPT-5.6 arms, and the baseline record.

The fixture's baseline is portfolio-tracker commit `ba94c01af8eb725292340d83e7923d7ecc136c90`, tagged [`lid-b10-baseline`](https://github.com/jszmajda/portfolio-tracker/tree/lid-b10-baseline).

## What this folder holds

Apart from this README, every file here is model output, some of it quoting portfolio-tracker code and tests. The outputs quote the baseline commit above and the seeded clones made from it; the seeds themselves are the patches in the notebook's `answer-key/patches/`.

An **audit unit** is one requirement audited once: three A-direction runs (a fresh session given only the requirement's text writes code for it), three B-direction runs (a fresh session given only the files that implement it, with documents and requirement IDs stripped, writes the requirement it enforces), and one classifier call that compares both with the real requirement and code and lists findings, strongest first. Each unit folder holds the same seven files:

- `a-run-1.md`, `a-run-2.md`, `a-run-3.md`: the A-direction outputs.
- `b-run-1.md`, `b-run-2.md`, `b-run-3.md`: the B-direction outputs.
- `classification.json`: the classifier's output, with its classification code, its findings in order, and its stability ratings.

Unit folders are named for the requirement audited. A seed unit audits a requirement in a clone with one gap planted; a control unit audits the same requirement on the untouched baseline.

### `runs/T2/` (168 files)

The headline arm: Claude Sonnet in fresh sessions. This is the execution that was scored. It holds the **24 control units**, one per requirement: `SHEET-FORMULA-001` to `SHEET-FORMULA-005`, `SHEET-MAP-001` and `SHEET-MAP-002`, `SHEET-MARK-001` to `SHEET-MARK-008`, `SHEET-PUB-001` to `SHEET-PUB-004`, and `SHEET-TAB-001` to `SHEET-TAB-005`. Their 120 findings are the ones whose verdicts give this arm's false-alarm rate. The 24 seed units' outputs from this arm were not kept (see below).

### `runs/T2-run1-superseded/` (175 files)

An accidental first execution of the same arm, which was superseded and not scored. It holds the same 24 control units, with the same seven files each, and seven empty files directly in the folder (`a-run-1.md` to `a-run-3.md`, `b-run-1.md` to `b-run-3.md`, `classification.json`), left by a write that had no unit name. Comparing it with `runs/T2/` shows how much a unit's classification code moves between executions.

### `runs/T2CAP/` (112 files) and `runs/EXP-HAIKU/` (112 files)

Claude Opus and Claude Haiku, each in fresh sessions, on the 16-unit subset:

- **Seed units (8):** `SHEET-MAP-001`, `SHEET-PUB-002` and `SHEET-MARK-004` (unstated-intent seeds), `SHEET-TAB-003`, `SHEET-PUB-003` and `SHEET-FORMULA-005` (phantom-requirement seeds), and `SHEET-MARK-002` and `SHEET-MARK-008` (hollow-test seeds).
- **Control units (8):** `SHEET-TAB-001`, `SHEET-TAB-005`, `SHEET-FORMULA-002`, `SHEET-FORMULA-004`, `SHEET-MAP-002`, `SHEET-MARK-003`, `SHEET-MARK-006` and `SHEET-PUB-001`.

### `adjudication/pilot/` (10 files)

From the two-seed pilot, which ran on the prompts before they were frozen, so these units are shakeout and not part of the scored grid:

- `T2_U-MAP-001-findings.json`, `T2_H-MARK-002-findings.json`, `T2_CTRL-FORMULA-002-findings.json`, `T2_CTRL-TAB-001-findings.json`: the classifier's findings for the pilot's two seed units and two control units, as given to the adjudicators.
- `out-sol-real-T2_U-MAP-001.json`, `out-sol-real-T2_H-MARK-002.json`, `out-sol-real-T2_CTRL-FORMULA-002.json`, `out-sol-real-T2_CTRL-TAB-001.json`: GPT-5.6 Sol's realness verdicts on those findings, for the cross-check of the Claude adjudicator.
- `out-sol-key-U-MAP-001.json`, `out-sol-key-H-MARK-002.json`: Sol's judgement of whether each pilot seed was caught.

Each Sol file holds the response text, the token usage and latency the API reported, the model ID it echoed, and the request ID.

## What was changed

Local file paths were replaced, and nothing else was edited:

- The experiment's temporary scratch directory, which held the per-seed clones and the code-only audit trees, is written `{scratch}`. So `{scratch}/audit-baseline/crates/...` is a file in the audit tree built from the baseline, and `{scratch}/audit-U-MARK-004/...` one in the tree built from that seed's clone. Where a model had already shortened a path by eliding the scratch directory, it is written `{scratch}/...`.
- The LID checkout the harness ran from is written `{lid-checkout}`.

The files were checked for credentials and for personal details, and none were found.

## What isn't here, and why

Nothing in the copied folders was withheld. Some of the experiment's raw output was never kept, so it can't be published:

- **The fresh Sonnet arm's 24 seed units.** Its 23-of-24 result rests on the per-seed outcomes and finding ranks in `scoring.json` and the human rulings in `answer-key/human-adjudication.md`, not on raw outputs anyone can re-read.
- **The GPT-5.6 Terra and Luna arms' outputs.**
- **The grid's adjudication outputs,** from both the Claude Fable adjudicator and the Sol cross-check. Only the pilot's Sol outputs survived. The verdict tallies are in the scoring files.
- **The Claude Code workflow journals,** from which the Claude token totals were read.
- **The scratch directory itself:** the seeded clones and audit trees. The seeds can be rebuilt from the baseline commit and the patches in the notebook.

## Notes for reading the outputs

- The file lists given to the B-direction runs and the classifier named the audit tree each file came from: `{scratch}/audit-baseline/...` for a control unit, `{scratch}/audit-<seed ID>/...` for a seed unit, where the seed ID gives the kind of seed and the requirement. Some B-direction runs echo those paths, and a few use the seed ID as a heading. An auditor could therefore tell a control unit from a seed unit, though not what was planted.
- The outputs from Haiku's sessions sometimes print their working directory, which was the notebook's `answer-key` folder, where the sealed key was kept. The prompts told every session to read only its inputs, and none of the outputs shows a session opening the key. The other Claude arms ran from the same harness and may have shared that working directory.
- The B-direction runs were given the files that cite the requirement, test files included. LID's shipped skill leaves test files out of the B direction by default.
- The exact Claude model versions were not recorded.
