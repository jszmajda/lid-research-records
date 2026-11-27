# `/map-codebase` on openGym: records

These are the published records behind the report [Mapping a codebase LID didn't build](https://linked-intent.dev/research/mapping-an-existing-codebase/). They come from LID's cost study, a pilot study of what LID costs and what it buys, whose first results are in [What LID costs, and what it buys](https://linked-intent.dev/research/first-results/).

**What this part of the study is.** LID's way into a codebase it didn't build is `/map-codebase`, a skill in LID's `arrow-maintenance` plugin that surveys the code and writes LID's documents for it. The cost study's runs on openGym, an open-source fitness app that LID didn't build, started from maps made by that skill. This folder is about the maps themselves: four mapping sessions, the first of which was set aside, what each produced, and what a review of the first found in the skill's own text.

**What was tested.** LID 1.4.6 (both the `linked-intent-dev` and `arrow-maintenance` plugins), in Claude Code 2.1.323, on Claude Sonnet 5.5 at medium effort with a 1M-token context window. One project, openGym at commit `e4a68a9`. No owner: the session was told to answer the skill's questions itself and note each one. All four draws ran on 2026-11-23 (UTC). These are pilot results; the measures were chosen after the maps were made.

**Why draw 1 was set aside.** The study's harness left openGym's separately licensed exercise media out of the copy that draw 1 mapped, believing no test needed them. One of the project's test suites does, and the map recorded the missing media as a fact about openGym, in one requirement and five other lines. Because a setting of the study's, not the project, had shaped the map, the study set it aside and made three more draws on the whole tree, one for each set of LID runs. The review of draw 1 is still the closest look at the skill's text, and what it found there doesn't depend on the leak ([skill-text-findings.md](skill-text-findings.md)).

## What's here

| File | What it holds |
|---|---|
| [draws.md](draws.md) | A counts-only table of the four draws: time, cost, tokens, requirements written, the sessions' own caps, whether each read its survey, source files named nowhere in the map, and how many of 13 dependencies between components each map recorded, and how. Each row names the local record it comes from. |
| [skill-text-findings.md](skill-text-findings.md) | The eleven places where the review of draw 1 found the skill's own documents contradicting each other or leaving a gap, each set against the skill's public text at LID 1.4.6, with what a recheck found and which LID issue it's filed in ([#133](https://github.com/jszmajda/lid/issues/133), [#134](https://github.com/jszmajda/lid/issues/134)). |
| [file_coverage.py](file_coverage.py) | The script that counted, for each draw, how many of openGym's 936 non-test source files the map names. It prints counts only. Running it needs an openGym checkout at the pin and a draw's exported map, which stays local. |

## What's withheld, and why

- **The maps, the sessions' transcripts, their working notes and their logs of owner questions.** They are derived from openGym's code, which is licensed under the AGPL, and the study keeps everything derived from the project local. This folder publishes counts about the maps, and no text from them.
- **The 13 dependencies, and which of them each map recorded.** The study mined these rules, each held by one component and relied on by another, before any map was made, and later runs reuse them to grade changes. Publishing them, or a per-dependency verdict, would let a reader or a model learn the answer key. Only totals by kind are here.
- **The review of draw 1 in full.** It quotes the map and the transcripts. Its findings about the skill's text are restated, against that public text, in [skill-text-findings.md](skill-text-findings.md).
- **The list of source files.** [file_coverage.py](file_coverage.py) says how the list is made, so anyone with a checkout at the pin can rebuild it.

## The notebook

The cost study's notebook is [`docs/research/cost-eval/`](https://github.com/jszmajda/lid/tree/main/docs/research/cost-eval) in the LID repository. Its tracked files include the mapping harness, [`harness/opengym_map.py`](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/opengym_map.py); the dated [log](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/log.md) (the mapping is in the 2026-11-23 entry, and its one-time cost in the 2026-11-24 entry); the [decisions](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/decisions.md) (2026-11-22 and 2026-11-23 for the mapping, 2026-11-24 for the versions tested); and the openGym [seed's README](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/seeds/opengym/README.md). Its run records, which this folder summarises, are git-ignored and stay local.
