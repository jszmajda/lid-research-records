# ReleaseDesk: what a fresh reader recovered at changes 10 and 20

Aggregates of the cost study's intent-from-tests readings on ReleaseDesk, a small release-approval service, grown from its brief through 20 changes once by each of three approaches (replicate g-r1): a bare agent, the checklist arm, and LID Full. They are computed from the summaries the study's harness wrote for six plans (`intent_from_tests.py summarize`, plans `growth-g-<arm>-1-c10` and `growth-g-<arm>-1-c20`), which sit in the notebook's local `runs/` folder with the readers' own outputs. Neither is published while the study is running. [releasedesk-m2e.md](releasedesk-m2e.md) has the same headline figures in the trial's results table.

**What was read.** Each approach's build at change 10 and at change 20, one build per approach. A fresh reader saw one source and nothing else:

- **tests:** every file under the build's test folders, as written;
- **tests, names replaced:** the same tests with test names, comments and docstrings replaced by placeholders;
- **docs:** the build's prose files outside its tests, without agent instruction files. For the checklist arm that was its `SPEC.md` and README; for LID, its design documents, requirement files and README. The bare agent kept only a README, so its docs weren't read.

Spec-ID pointers were stripped from every input. A brief-only reader, who saw only the brief all three approaches built from, gives the baseline; each approach's plan ran its own brief-only reader.

**How it was scored.** The reader wrote down the system's current rules, and a judge mapped each rule to the oracle, the owner's intent known at that change. At change 10 that was 60 items in force and 2 retired; at change 20, 67 in force and 7 retired, one of them a first request that a change of mind replaced. Reader and judge were both Claude Sonnet 5.5 at medium effort, in Claude Code 2.1.323. Each input was read three times.

- **Recall of met:** of the items in force that the build meets, the share that at least one of the reader's rules agrees with, in whole or in part. At change 10 the builds met 54 (bare), 53 (checklist) and 51 (LID) items; at change 20, 59, 60 and 58. These counts use the probes' version-3 verdicts; under version 4, LID's build at change 20 meets one more item.
- **Brief-only reader, same items:** the brief-only reader's recall over the same items.
- **Above the brief:** recall of met minus that baseline, in points.
- **Whole-item recall:** of all items in force, the share that a single rule states in full. The reader was told to write one behaviour per rule, so a long item is usually matched in parts.
- **Retired rules stated:** of the retired items, the share that some rule states as current, averaged over the three readings.
- **Spread between readings:** the gap between the highest and lowest of the three readings' recall of met.
- **Input size:** files and estimated tokens (4 bytes a token).

## At change 10

| Arm | Source | Readings | Rules written, mean | Recall of met | Spread between readings | Brief-only reader, same items | Above the brief | Whole-item recall | Retired rules stated | Retired rules stated, per reading | Input size, files / tokens |
|---|---|---|---|---|---|---|---|---|---|---|---|
| bare | tests | 3 | 31 | 59% | 7 points | 59% | +1 | 13% | 0% | 0, 0, 0 of 2 | 1 / 7,522 |
| bare | tests, names replaced | 3 | 34 | 62% | 6 points | 59% | +3 | 12% | 0% | 0, 0, 0 of 2 | 1 / 6,956 |
| checklist | tests | 3 | 37 | 52% | 9 points | 51% | +1 | 16% | 0% | 0, 0, 0 of 2 | 1 / 7,115 |
| checklist | tests, names replaced | 3 | 30 | 55% | 6 points | 51% | +4 | 2% | 0% | 0, 0, 0 of 2 | 1 / 6,647 |
| checklist | docs | 3 | 63 | 85% | 6 points | 51% | +34 | 26% | 0% | 0, 0, 0 of 2 | 2 / 8,613 |
| LID Full | tests | 3 | 98 | 83% | 4 points | 56% | +27 | 8% | 0% | 0, 0, 0 of 2 | 13 / 74,804 |
| LID Full | tests, names replaced | 3 | 74 | 79% | 4 points | 56% | +24 | 1% | 0% | 0, 0, 0 of 2 | 13 / 66,981 |
| LID Full | docs | 3 | 90 | 87% | 6 points | 56% | +31 | 5% | 0% | 0, 0, 0 of 2 | 20 / 43,197 |

Brief-only readers, each scored over all items in force:

| Plan | Readings | Rules written, mean | Recall of all items in force | Whole-item recall | Retired rules stated |
|---|---|---|---|---|---|
| bare | 3 | 23 | 56% | 48% | 0% |
| checklist | 3 | 22 | 48% | 48% | 0% |
| LID Full | 3 | 23 | 53% | 51% | 0% |

## At change 20

| Arm | Source | Readings | Rules written, mean | Recall of met | Spread between readings | Brief-only reader, same items | Above the brief | Whole-item recall | Retired rules stated | Retired rules stated, per reading | Input size, files / tokens |
|---|---|---|---|---|---|---|---|---|---|---|---|
| bare | tests | 3 | 32 | 61% | 14 points | 51% | +10 | 14% | 19% | 2, 1, 1 of 7 | 1 / 8,714 |
| bare | tests, names replaced | 3 | 34 | 60% | 10 points | 51% | +9 | 9% | 29% | 2, 2, 2 of 7 | 1 / 8,075 |
| checklist | tests | 3 | 37 | 56% | 3 points | 50% | +6 | 3% | 14% | 1, 1, 1 of 7 | 1 / 9,719 |
| checklist | tests, names replaced | 3 | 31 | 48% | 10 points | 50% | -2 | 3% | 29% | 2, 2, 2 of 7 | 1 / 9,041 |
| checklist | docs | 3 | 73 | 92% | 7 points | 50% | +42 | 11% | 5% | 0, 0, 1 of 7 | 2 / 13,345 |
| LID Full | tests | 3 | 85 | 83% | 3 points | 48% | +35 | 7% | 29% | 2, 2, 2 of 7 | 18 / 90,413 |
| LID Full | tests, names replaced | 3 | 77 | 80% | 9 points | 48% | +33 | 5% | 29% | 2, 2, 2 of 7 | 18 / 80,752 |
| LID Full | docs | 3 | 85 | 83% | 5 points | 48% | +36 | 14% | 29% | 2, 2, 2 of 7 | 20 / 54,229 |

Brief-only readers, each scored over all items in force:

| Plan | Readings | Rules written, mean | Recall of all items in force | Whole-item recall | Retired rules stated |
|---|---|---|---|---|---|
| bare | 3 | 24 | 48% | 44% | 0% |
| checklist | 3 | 23 | 48% | 43% | 0% |
| LID Full | 3 | 24 | 49% | 42% | 0% |

## Which retired rules the readers stated, at change 20

The seven retired rules are given letters here instead of their IDs; their text stays private. Each cell counts the readings, of three, in which some rule stated that retired rule as current. Rules E, F and G were stated in no reading.

| Retired rule | bare tests | bare tests, names replaced | checklist tests | checklist tests, names replaced | checklist docs | LID tests | LID tests, names replaced | LID docs | All readings, of 24 |
|---|---|---|---|---|---|---|---|---|---|
| A | 3 | 3 | 3 | 3 | 1 | 3 | 3 | 3 | 22 |
| B | 0 | 0 | 0 | 0 | 0 | 3 | 3 | 3 | 9 |
| C | 0 | 3 | 0 | 3 | 0 | 0 | 0 | 0 | 6 |
| D | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |

Rule A was stated from every approach's tests, so it may say more about that rule, or about the judge, than about any approach. Rule B was stated only from LID's files, in all nine of their readings. No brief-only reading stated any retired rule.

## Cost of the readings

Notional cost at Anthropic's list prices, readers and judges together: $2.14 (bare), $2.91 (checklist) and $6.71 (LID) at change 10; $1.72, $3.21 and $7.19 at change 20.
