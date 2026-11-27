# BenchTime: what a fresh reader recovered at change 10

Aggregates of the cost study's intent-from-tests readings on BenchTime, a small reservation service. They are computed from the summary the study's harness wrote for this plan (`intent_from_tests.py summarize`, plan `benchtime-c10`), which sits in the notebook's local `runs/` folder with the readers' own outputs. Neither is published while the study is running.

**What was read.** The builds at change 10 of the nine BenchTime trajectories the study ran on 17 November 2026 under the simulated owner with imperfect attention: three each for a bare agent, cheap discipline, and LID Full. For each build, a fresh reader saw one source and nothing else:

- **tests:** every file under the build's test folders, as written;
- **tests, names replaced:** the same tests with test names, comments and docstrings replaced by placeholders;
- **docs:** the build's prose files outside its tests (Markdown or reStructuredText), without agent instruction files. For the bare agent that was its README alone; for cheap discipline, its notes file and README.

Spec-ID pointers were stripped from every input. A brief-only reader, who saw only the brief all three approaches built from, gives the baseline.

**How it was scored.** The reader wrote down the system's current rules, and a judge mapped each rule to the oracle, the owner's intent known at change 10: 52 items in force and 2 retired. Reader and judge were both Claude Sonnet 5.5 at medium effort, in Claude Code 2.1.323. Each input was read twice.

- **Recall of met:** of the items in force that the build meets (46 to 50 per build), the share that at least one of the reader's rules agrees with, in whole or in part.
- **Brief-only reader, same items:** the brief-only reader's recall over the same items.
- **Above the brief:** recall of met minus that baseline, in points.
- **Whole-item recall:** of all items in force, the share that a single rule states in full. The reader was told to write one behaviour per rule, so a long item is usually matched in parts.
- **Retired rules stated:** of the 2 retired items, the share that some rule states as current.
- **Spread between readings:** the gap between the two readings of the same input, in points, averaged over the three builds.
- **Input size:** files and estimated tokens (4 bytes a token), the mean over the three builds.

Means are over the three trajectories, each the mean of its two readings.

| Arm | Source | Trajectories | Readings | Rules written, mean | Recall of met | Spread between readings | Brief-only reader, same items | Above the brief | Whole-item recall | Retired rules stated | Input size, files / tokens (mean) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| bare | tests | 3 | 6 | 45 | 83% | 1 points | 29% | +55 | 26% | 0% | 1 / 10,610 |
| bare | tests, names replaced | 3 | 6 | 41 | 76% | 3 points | 29% | +47 | 19% | 0% | 1 / 9,830 |
| bare | docs | 3 | 6 | 41 | 80% | 3 points | 29% | +51 | 30% | 0% | 1 / 2,722 |
| cheap discipline | tests | 3 | 6 | 53 | 89% | 1 points | 29% | +60 | 29% | 0% | 14 / 18,991 |
| cheap discipline | tests, names replaced | 3 | 6 | 53 | 82% | 2 points | 29% | +53 | 8% | 8% | 14 / 17,268 |
| cheap discipline | docs | 3 | 6 | 60 | 87% | 1 points | 29% | +57 | 23% | 17% | 2 / 5,461 |
| LID Full | tests | 3 | 6 | 79 | 93% | 4 points | 29% | +64 | 10% | 0% | 14 / 39,300 |
| LID Full | tests, names replaced | 3 | 6 | 56 | 84% | 2 points | 29% | +56 | 8% | 0% | 14 / 35,311 |
| LID Full | docs | 3 | 6 | 85 | 94% | 2 points | 29% | +66 | 29% | 0% | 12 / 33,711 |
| brief only | brief | 1 | 2 | 29 | 28% of all items in force | 2 points | – | – | 15% | 50% | 1 / 1,192 |

The brief-only reader's 50% is one of the two retired rules, which the brief itself states: it is the owner's original version.

## Per trajectory

Recall of met items, for each of the three builds per arm:

| Arm | Tests | Tests, names replaced | Docs |
|---|---|---|---|
| bare | 79%, 85%, 86% | 79%, 73%, 75% | 87%, 64%, 88% |
| cheap discipline | 92%, 87%, 90% | 81%, 79%, 85% | 92%, 83%, 85% |
| LID Full | 89%, 92%, 97% | 79%, 88%, 86% | 92%, 93%, 98% |

## Cost of the readings

Notional cost at Anthropic's list prices: $22.48 for the whole plan, readers and judges together.
