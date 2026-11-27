# LID research records

The records behind the reports in the research section of the Linked-Intent Development site, [linked-intent.dev/research](https://linked-intent.dev/research/): run outputs, grades, and tallies that every number in a report traces to.

They live here, not in the [LID repository](https://github.com/jszmajda/lid), so that people who clone LID to use or contribute to it don't download them. Each study's notebook (its design, plan, and write-ups) stays in the LID repository under `docs/research/`; this repository holds what is too large or too raw for that.

## Studies

| Folder | Report | Notebook in the LID repository |
|---|---|---|
| [`b10-differential-catch-rate/`](b10-differential-catch-rate/) | [Does the bidirectional differential catch planted gaps?](https://linked-intent.dev/research/differential-catch-rate/) | [`docs/research/experiments/b10-differential-catch-rate/`](https://github.com/jszmajda/lid/tree/main/docs/research/experiments/b10-differential-catch-rate) |
| [`capability-flags/`](capability-flags/) | [Which judgments a model can be left to make: the first 29 configurations](https://linked-intent.dev/research/judgment-across-models/) | [`capability-flags.md`](https://github.com/jszmajda/lid/blob/main/plugins/linked-intent-dev/skills/linked-intent-dev/references/capability-flags.md) and [`docs/intent/alt-model-evals/`](https://github.com/jszmajda/lid/tree/main/docs/intent/alt-model-evals) |
| [`cost-eval/intent-recovery/`](cost-eval/intent-recovery/) | [What each approach leaves for the next reader](https://linked-intent.dev/research/intent-recovery/) | [`docs/research/cost-eval/`](https://github.com/jszmajda/lid/tree/main/docs/research/cost-eval) |
| [`cost-eval/map-codebase-opengym/`](cost-eval/map-codebase-opengym/) | [Mapping a codebase LID didn't build: a first look](https://linked-intent.dev/research/mapping-an-existing-codebase/) | [`docs/research/cost-eval/`](https://github.com/jszmajda/lid/tree/main/docs/research/cost-eval) |

Each folder's README lists what it holds and what was withheld, and why.

## What is never here

- **Source code from private projects.** Where a study ran on one, its records give counts and descriptions, not code.
- **A running study's oracle.** The cost study's seed projects are still in use, so their rules, owner prompts, and full trajectories stay private until the runs that depend on them finish. Their records here are aggregates.
- **Local paths, keys, and personal details.** Paths on the machine that ran a study are replaced with neutral placeholders, and each folder says where.

## Licence

MIT, as for LID itself; see [`LICENSE`](LICENSE).
