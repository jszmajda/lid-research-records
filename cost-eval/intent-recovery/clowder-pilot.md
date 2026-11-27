# The Clowder pilot: a bare agent in a repository LID built

Structural results from the cost study's Clowder pilot, run on 18 November 2026. Clowder is a game project that LID's maintainer built with LID, so its repository holds the design documents, requirements and tests LID produced over its life. Its content stays private, so this file gives only counts, shares, costs and sizes: nothing about what the changes or requirements were.

## What ran

Twelve independent changes, each started from the same snapshot, made by three approaches at two context windows, 1M and 200k tokens. **One run per cell.**

- **Bare agent, stripped copy:** the repository without its docs folder, its agent instruction files, LID's tooling, or any requirement references in the code, and with its tests thinned at random, whole files at a time, until test lines were about 0.6 times the non-test source lines. That is close to the ratio bare agents wrote for themselves on another of the study's projects.
- **Bare agent, full repository:** everything, including LID's documents, all its tests but the held-out slice below, and the repository's own instruction file, which tells agents to follow LID's workflow. The agent had no LID plugin. The study treats this cell as an inheritance check, not a baseline.
- **LID Full:** the same full repository, with LID's plugin installed.

The same 15% of test files was held out of all three, to grade whether existing behaviour was kept. Every run recorded Claude Sonnet 5.5 at medium effort, in Claude Code 2.1.323; the LID runs used LID 1.4.6.

How the variants were built is in [harness/clowder_variants.py](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/clowder_variants.py#L12-L20).

## Results

| | Bare agent, stripped copy | Bare agent, full repository | LID Full |
|---|---|---|---|
| Graded requirements met, 1M window | 26 of 33 (79%) | 29 of 33 (88%) | 32 of 33 (97%) |
| Graded requirements met, 200k window | 28 of 33 (85%) | 30 of 33 (91%) | 27 of 32 (84%); 1 couldn't be graded |
| Agent cost for the 12 changes, 1M / 200k | $4.30 / $4.03 | $12.48 / $13.61 | $18.55 / $15.74 |
| Agent cost against bare on the stripped copy, 1M / 200k | 1.0× / 1.0× | 2.9× / 3.4× | 4.3× / 3.9× |
| Changes that edited files in the docs folder, 1M / 200k | 0 / 0 of 12 (the copy had none) | 10 / 10 of 12 | 10 / 10 of 12 |
| Peak context in any one session, 1M / 200k | 98k / 76k tokens | 193k / 166k tokens | 255k / 166k tokens |

Notes:

- **Requirements met** are after the pilot's blind spot-checks: one met verdict for bare on the stripped copy at 1M was overturned, and one verdict for LID at 1M, where the grading's two steps disagreed, was ruled not met. With one run per cell, a single requirement moves a share by about 3 points, so none of these differences separates the approaches or the windows.
- **Agent cost** is what the same tokens would cost at Anthropic's published API prices. The ratios are the two cells' costs divided.
- **Docs edits** count the changes whose diff touched at least one file under the repository's docs folder.
- **Peak context** is the largest context in any session in the cell. Two of LID's 200k changes were rerun after an instrument fix, and the reruns have no context record, so LID's 200k figure covers the other ten changes.

The requirement counts and costs are also in the study's tracked log ([log-archive/2026-11.md, lines 183 to 200](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/log-archive/2026-11.md?plain=1#L183-L200)), as is the maximum peak context per approach. The per-window peak context and the docs-edit counts by window come from the runs' own records, which stay in the notebook's local `runs/` folder.
