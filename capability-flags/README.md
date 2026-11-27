# Capability flags: the first 29 model configurations

These are the raw records behind the first 29 rows of the capability-flag list in the Linked-Intent Development (LID) project, run between 10 October and 20 November 2026 (UTC). A capability flag records a kind of judgment that a model configuration (a model at a reasoning effort) is known to miss, so that LID brings that judgment to the user instead of letting the model settle it alone. Each configuration ran eight of LID's shipped eval fixtures 10 times each, at `medium` effort, and every run was graded blind.

- **The report:** https://linked-intent.dev/research/judgment-across-models/
- **Maintainer:** Jess Szmajda.

The list is maintained in the LID repository and gains rows as models are tested. These records cover the 29 configurations named in the report and are not updated.

## The study's files in the LID repository

- [capability-flags.md](https://github.com/jszmajda/lid/blob/main/plugins/linked-intent-dev/skills/linked-intent-dev/references/capability-flags.md): the living list, with its evidence tables and notes.
- [linked-intent-dev-design.md](https://github.com/jszmajda/lid/blob/main/docs/intent/linked-intent-dev/linked-intent-dev-design.md), section *Capability Flags*: what a flag is, the evidence bar, and the decisions behind it, including the 70% line.
- [core-design.md](https://github.com/jszmajda/lid/blob/main/docs/intent/linked-intent-dev/core/core-design.md), *What still reaches the human*: the kinds of judgment a flag can name, and what the workflow does with a flag.
- [alt-model-evals-design.md](https://github.com/jszmajda/lid/blob/main/docs/intent/alt-model-evals/alt-model-evals-design.md): the runner for non-Claude models, its sandbox, outputs, and recording rules.
- [run_eval.py](https://github.com/jszmajda/lid/blob/main/tools/alt-model-evals/run_eval.py) and [rosters.json](https://github.com/jszmajda/lid/blob/main/tools/alt-model-evals/rosters.json): the runner and its `capability` roster preset.
- The fixtures, prompts, and assertions: [linked-intent-dev evals.json](https://github.com/jszmajda/lid/blob/main/plugins/linked-intent-dev/skills/linked-intent-dev/evals/evals.json) (core evals 0 to 3) and [lid-coach evals.json](https://github.com/jszmajda/lid/blob/main/plugins/linked-intent-dev/skills/lid-coach/evals/evals.json) (evals 10, 11, 15 and 16). Their `tested_with` lists record the same runs.

## The two skill trees

Every batch ran against one of two copies of the `plugins/` tree:

- **Tree A**, `317e8c20456c3c378cd913349b2d6455754c7aa7`: the `plugins/` tree of commit `1e7ef1a4435a9140019eaa0bf3bf7792152d092e`, unmodified. Its `capability-flags.md` was in place but listed no flags. The 13 configurations of the first round ran on it.
- **Tree B**, `3a5bd791ca773e215b506752985d4e08c519972f`: the `plugins/` tree of commit `919c4b4bae2de396603e0b52794ddbb6c52dcf6a` with the capability-flag subsystem removed by hand. The other 16 configurations ran on it. `stripped-tree.diff` is that removal: applying it to a checkout of `919c4b4` gives tree `3a5bd791` exactly. It deletes `capability-flags.md` and the passages that mention the list in five other files (three skills, the vendored workflow doc, and the plugin's changelog), and touches no eval definition.

Both trees' plugin manifests say version 1.4.0.

## What this folder holds

- `index.csv`: one row per batch (75 rows). For each: the model, effort, harness, the first and last run times in UTC, the tree, the source commit, the skill, the batch's eval IDs and the ones it contributes as evidence, the runs it holds and the runs graded, the runs' statuses, whether the batch record was written by the runner or rebuilt here, the grading round, and the rows of `capability-flags.md` it supports, by line number.
- `configurations.csv`: one row per configuration (29 rows), with its eight evidence cells, its result in each of the three tables, its grading round, and the grader model where the record survives.
- `cells.csv`: the 232 evidence cells (29 configurations times 8 fixtures), the rule each cell is scored by, whether it counts as a miss at the 70% line, and the line of `capability-flags.md` that publishes it.
- `assertions.csv`: pass counts for every assertion of every fixture, per configuration, with the assertion text.
- `line-sensitivity.csv`: the results that would change with a 60% or 80% line, or with one run in one cell going the other way.
- `check.py`: recomputes every cell and the *Output per run* medians from the run records and compares them with a copy of `capability-flags.md`. Run it as `python3 check.py path/to/capability-flags.md`. On the copy on lid `main` dated 2026-11-20, all 232 cells match, and every median matches except the three Gemini 4 rows, whose token records were lost (see below).
- `stripped-tree.diff`: tree B against its source commit.

### `runs/`

`runs/<model>/<suite>/<batch>/eval-<id>-<name>/run-<n>/`, where `<suite>` is `core` (the `linked-intent-dev` skill) or `coach` (`lid-coach`). OpenRouter batches keep the runner's batch name, which carries the batch's start date in US Eastern time. Claude batches are named `claude-p-<date>-<model>`, by UTC date. A graded run holds:

- `response.md`, and `response2.md` for two-turn evals: the model's final message in each turn.
- `grading.json`: the de-blinded grade, in the `expectations` / `summary` shape `skill-creator`'s grader writes, with each assertion's text, verdict, and the grader's quoted evidence. `blind` names the grading round, blind batch, and blind ID; `evidence_cell` names the cell the run counts toward, the rule, and the result.
- `changes.patch`, and `changes1.patch` for two-turn evals: every change from the fixture, at the end of the run and at the end of the first turn.
- `timing.json`: as the runner wrote it, with status, duration, and token counts.
- `git-log.txt` (OpenRouter runs): the project's history; the fixture commit's time is the run's start.
- `usage.json` (Claude runs): the `usage` and `modelUsage` fields of each turn's `claude -p` JSON output, which the *Output per run* medians use.
- `batch.json`, one per batch: the runner's record for OpenRouter batches. The Claude runner wrote none, and the 20 November records were lost, so those batches carry a rebuilt record whose `reconstructed` field says what it rests on.

Runs that didn't finish (a timeout or a host error) keep only `timing.json`. So do the runs of an eval that a later batch reran whole: the first MiniMax M3.1 Flash core batch (evals 1 to 3), the 18 October MiMo v2.6 Flash core batch (eval 3), and the 18 October Gemini 3.8 Flash coach batch (eval 16).

### `grading/`

- `keys/`: the blind keys for the eight grading rounds (round 8 in four parts, `grade-roster8a` to `8d`). Each maps a blind ID to its run in `runs/`, or says why the run isn't published.
- `blind/`: what the graders wrote, by round and blind batch: `evals.json` (the prompts and assertion text the grader was given), `grades.json`, and, where a batch was regraded, the superseded grades. `blind/grade-roster2/regrade/` holds round 2's regrade of some round-1 assertions with revised wording; no evidence cell uses those assertions.
- `controls.csv`: every control planted in a blind batch: a run from an earlier round with a known grade on the assertion it was chosen for. It says which assertion that was, what was expected, what the grader gave, and whether they matched. From round 3 on, 190 of the 192 planted controls came back as expected. Round 2 regraded 8 round-1 runs as its check, and round 1 mixed in 2 pilot runs with no recorded grade.
- `grader-models.csv`: the model each grader ran on, for the batches whose grading-session records survive (rounds 6 to 8).
- `prompts/`: the grader prompts.
- `scripts/`: the scripts that launched the runs and built, tallied, and de-blinded the blind batches. Local paths in them are replaced with placeholders such as `<workspace>`, `<scratch>`, and `<lid-evalstrip-1109 checkout>`.

### `supporting/`

Two small studies run before the roster, on Claude Code's default effort and earlier skill text:

- `noise-study/`: 10 Claude models on two coach fixtures, 10 runs each, on 25 and 27 September. Its `NOTES.md` is the study's own write-up. The keys' paths are relative to this folder. `tenet_fixture.json` is the "shelfwise" fixture, an early version of lid-coach eval 15; the other fixture is lid-coach eval 11.
- `harness-compare/`: Claude Sonnet 4.5 under Claude Code and under opencode on the same two fixtures, and with Claude Code's thinking on and off, on 28 September. Its `NOTES.md` is the study's own write-up. The keys' paths are relative to this folder; the earlier noise-study runs it regraded are in `../noise-study/`.

## What was withheld, and why

- **Full transcripts** (the opencode event streams, about 265 MB): over this folder's size budget. Each run's final messages, changes, and token counts are here.
- **Each run's final project folder:** the patches carry every change, and the starting files are in the eval definitions on lid `main`.
- **The Claude runs' raw `claude -p` output:** it holds local paths. Its final text is `response.md` and its token counts are `usage.json`.
- **update-lid runs:** the roster ran them for that suite's `tested_with` entry. They aren't capability-flag evidence, so their runs and blind batches are left out, and the keys mark them as not published.
- **Pilot, probe, and abandoned runs:** cost probes, identity probes, pilots mixed into round 1 as checks, and a StepFun Step 5 Preview batch that stopped after two host errors. None is behind a row.
- **Grading sessions:** the sessions that ran the graders are private working sessions. Only each grader's model is extracted, in `grading/grader-models.csv`.
- **The noise study's GLM 5.3 runs:** not used by the report.
- **Operational logs:** runner progress logs, which add nothing to the records here.

### What was lost

- **The 20 November runs** (Gemini 4 Carbon, Hydrogen, and Neon) were made in a checkout that has since been deleted. Their final messages and patches survive as the copies made for blind grading, and are published here. Their `batch.json`, `timing.json`, `git-log.txt`, and transcripts did not survive, so their run times are known only to the day, and their *Output per run* medians can't be checked from these records.
- **The Claude Code version** isn't stored in the Claude runs' records. The versions given (2.1.296 for the runs of 10 October, 2.1.310 for 24 October) come from `capability-flags.md`.
- **The grading model for rounds 1 to 5**, which cover 21 of the 29 configurations, isn't recorded anywhere that survives. Rounds 6 to 8 were graded by Claude Sonnet 5.5 (`claude-sonnet-5-5`).
