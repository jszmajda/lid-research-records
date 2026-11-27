# The four `/map-codebase` draws on openGym, counts only

Four mapping sessions ("draws") ran on openGym at the pinned commit `e4a68a9`, on 2026-11-23 (UTC). Draw 1 was set aside (see [README.md](README.md)). Draws 2 to 4 were the starting points for LID's three sets of runs on openGym in the cost study.

Every draw used the same setup: one Claude Code 2.1.323 session, Claude Sonnet 5.5 at medium effort with a 1M-token context window, LID 1.4.6 with both the `linked-intent-dev` and `arrow-maintenance` plugins, GitHub's hosts blocked, and web search and fetch denied. The prompt was `/map-codebase` plus one instruction: no owner is available; wherever the skill would ask the owner, choose the most reasonable answer, note the question and the choice outside the project, and continue. The setup is in the notebook's tracked harness, [`harness/opengym_map.py`](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/harness/opengym_map.py) (lines 55 to 72).

## The table

| Row | Draw 1 (set aside) | Draw 2 | Draw 3 | Draw 4 | Source |
|---|---|---|---|---|---|
| 1. Tree mapped | pinned tree, exercise media left out | whole pinned tree | whole pinned tree | whole pinned tree | A1, A2 |
| 2. Turns the session took | 1 | 1 | 1 | 1 | A1, A2 |
| 3. Wall time | 10.1 min | 19.6 min | 20.7 min | 12.0 min | A1, A2 |
| 4. Cost, Claude Code's estimate at list prices | $20.92 | $53.64 | $45.37 | $26.53 | A1, A2 |
| 5. Tokens, all | 55.75M | 152.5M | 128.8M | 58.9M | A1, A2 |
| 6. of which output | 0.69M | 1.47M | 1.35M | 0.90M | A1, A2 |
| 7. of which cache reads | 51.6M | 141.2M | 119.6M | 53.2M | A1, A2 |
| 8. Subagents started (survey workers and writers) | 26 | 50 | 58 | 46 | A2, A3 |
| 8a. of which survey workers / writers | 11 / 15 | 31 / 19 | 44 / 14 | 24 / 22 | A3, D |
| 9. Segments (design docs / spec files) | 15 / 15 | 19 / 19 | 14 / 14 | 22 / 22 | A2, A3, B |
| 10. Requirements (EARS) | 885 | 1,195 | 815 | 878 | A1, A2, B |
| 11. marked `[x]` / `[ ]` / `[D]` | 845 / 40 / 0 | 1,162 / 33 / 0 | 753 / 45 / 17 | 831 / 25 / 22 | A1, A2, B |
| 12. Requirements per spec file, range (median) | 58 to 60 (59) | 51 to 85 (61) | 50 to 60 (59) | 32 to 56 (40) | A2, A3, B |
| 13. Range the session's brief gave its writers | 25 to 60 | 25 to 60 | 25 to 60 | 15 to 40 | A2, A3 |
| 14. Read its own survey before choosing segments | no: a line count of the files only, none opened | no: a line count of the files only | in part: about 45 lines from 4 of its reports | in part: one short section (30 lines or fewer) of each report | A2, A3 |
| 14a. Logged, in its record of owner questions, that it accepted shallow reading in the survey | no | not noted | yes, for each shallow report | yes, as one general caveat | A2, A3 |
| 14b. Survey workers whose closing message says it read some code files only in part (by headers, exports, outlines or a skim) | 10 of 11 | 7 of 31 | 17 of 44 | 16 of 24 | D |
| 14c. Follow-up survey workers the session sent to fill gaps or read deeper | 0 | 11 | 1 | 0 | D |
| 14d. The session's brief to its writers says the survey was thin | yes | yes | brief not kept | brief not kept | D |
| 15. `@spec` annotations added to code | 0 | 0 | 0 | 0 | A2, A3 |
| 16. Code files changed | 0 | 0 | 0 | 0 | A2, A3 |
| 17. Areas the session chose to leave unmapped, and said so | – | – | 5 | – | A2 |
| 18. Source files the session found unclaimed after drafting, and assigned | – | 339 | – | – | A2 |
| 19. Source files named nowhere in the map, by whole file name, of 936 | 534 | 130 | 472 | 355 | C |
| 20. Source files named nowhere in the map, by whole name or stem, of 936 | 350 | 26 | 332 | 187 | C |
| 21. Dependencies, of 13: both sides recorded, with a line linking them | 1 | 1 | 1 | 1 | A2, A4 |
| 22. both sides recorded, joined only by a shared term | 1 | 0 | 0 | 1 | A2, A4 |
| 23. one side recorded, with a note that the logic exists twice | 0 | 1 | 0 | 0 | A2, A4 |
| 24. partly recorded, linked only through a neighbouring issue | 1 | 0 | 0 | 0 | A4 |
| 25. one side only | 8 | 10 | 8 | 7 | A2, A4 |
| 26. not recorded | 2 | 1 | 4 | 4 | A2, A4 |

A dash in rows 17 and 18 means the records note no such step for that draw. Draw 1's map does list several folders that no survey covered (review, line 44), which is a gap it noticed rather than an area it chose to leave out.

Rows 21 to 26 add up to 13 in every draw. "One side only" means one side of the dependency is in the map and nothing points from it to the other. In draw 3, one of its 8 is the relying side; the rest are the side that holds the rule.

Totals across draws 2 to 4, the three maps the study used: $125.54 (row 4), which is also in the notebook's tracked [`log.md`](https://github.com/jszmajda/lid/blob/main/docs/research/cost-eval/log.md), line 18.

## What each row means, and where it comes from

The sources are the notebook's run records, which git ignores and which stay local, because they hold openGym-derived material (see [README.md](README.md)). They are named here relative to the notebook, `docs/research/cost-eval/`.

- **A1**, each draw's `runs/opengym-map/<draw>/mapping.json`: settings, `omitted`, `turn_minutes`, `totals` (`all_tokens`, `output`, `cache_read`, `reported_cost_usd`), and for draw 1, `notes` (the marker counts). Draw 1's run line is also `runs/opengym-map/ogmap-1.log`.
- **A2**, `runs/opengym-map/draws.txt`, the draws' summary table: line 1 (draw 1 omitted the media, kept and not used), line 4 (every draw ended in its first turn), lines 12 to 20 (rows 3 to 13), lines 23 to 26 (row 14), lines 42 to 43 (row 14a), line 28 (rows 15 and 16), lines 31 to 35 (rows 21 to 26), lines 40 to 41 (row 17: draw 3 left five areas unmapped), line 43 (row 18).
- **A3**, `runs/analysis/opengym/map-review.md`, the review of draw 1 (draw 1's rows 8, 9, 12 to 16): lines 35 and 134 (row 14a: the session accepted each sampled report without logging it), 41 (no survey file opened), 50 (the brief's "25-60", all fifteen spec files at 58, 59 or 60), 53 and 107 (no annotations), and the review prompt's record of the run, `runs/analysis/opengym/map-review-prompt.md`, lines 48 and 49 (26 subagents: 11 survey workers, then 15 writers; 15 design docs and 15 spec files).
- **A4**, each draw's `runs/opengym-map/<draw>/coverage.txt`, the tally line at its end. The verdicts were written by a model session that read each map for each dependency after the mapping had finished; the map was not changed.
- **B**, recounted for this record from the spec files of each draw's map: every requirement line with an ID and a status marker, counted once per ID. The counts match A1 and A2.
- **C**, counted for this record by [`file_coverage.py`](file_coverage.py), in this folder, on the pinned checkout and each draw's exported map (its `docs/` only; the project's own `CLAUDE.md` is left out). The 936 source files are the files git tracks at the pin outside the exercise catalogue, with a JavaScript, TypeScript, Swift, Kotlin, Java or Monkey C extension, that don't look like tests. A file is "named" when its file name, extension included, appears in the map's text as a whole name, not run on into a longer one (row 19), or, more generously, when that or its name without the extension appears as a whole word (row 20). These are two rough figures, not bounds, and each both over- and under-credits. Both match on the file name alone, and 129 of the 936 files share their name with another file, so one mention credits every file of that name. Row 20 credits more, because short names ("index", or a locale's "de") match ordinary words. Neither credits a file that the map covers only by a glob or a folder name. Naming a file is not the same as describing it.
- **D**, each draw's subagent transcripts, `runs/opengym-map/<draw>/transcripts/-work/<session>/subagents/`: each subagent's `.meta.json` description, and the last message in its transcript. Writers are the subagents described as drafting a segment's documents ("Draft …" in draws 1 to 3, "Segment: …" in draw 4); the rest are survey workers. Row 14b was counted for this record by reading each survey worker's closing message. It counts only statements that some code files were read in part: by header comments, imports and exports, an outline or declaration index, or a skim. Statements only about test files (often read by their test titles), data, generated files, assets, lockfiles, stylesheets or docs are left out, so the row is conservative. Row 14c counts survey workers whose description names a gap-fill, a deeper sweep, a retry or a resweep. Row 14d: draw 2's brief to its writers, `runs/opengym-map/ogmap-2/cfg-extras/map-codebase-working/worker-brief.md` line 9, tells them to verify the code themselves because "the sweeps were partly skimmed"; draw 1's brief, `runs/opengym-map/ogmap-1/cfg-extras/map-codebase-sweeps/segment-worker-prompt.md` line 3, calls the sweep notes "leads, not proof" and says "several sweeps only read headers"; draws 3 and 4 kept no brief. These rows quote only statements about how files were read, never what the files or the map say.

## The rows the review gives for draw 1 alone

These are in `runs/analysis/opengym/map-review.md`, the review of draw 1, at the lines given.

| What | Count | Line |
|---|---|---|
| Survey workers, all told to read every non-test source file | 11 | 26 |
| Lines in the survey files, none opened by the session | 7,233 | 41 |
| Writers that reported deleting drafted requirements to fit the cap | at least 6 | 50 |
| Lines in the map saying the HLD doesn't exist, written before it was | 8 | 52 |
| Requirements and other lines in the map caused by the omitted media | 1 requirement, 5 other lines | 88 to 92 |
| Source files the review checked by name | 859 | 44 |
| Of those, named nowhere in the map | "about a third" | 44 |

The review's count of 859 and this record's 936 use different file lists; the review doesn't give its list. On its own generous match, this record's row 20 finds 350 of 936 named nowhere in draw 1, also about a third. The review's per-area figures on line 44 (for example "lib 237 of 332") are the files that *are* named; this record's stem match gives 237 of the same 332, and 51 of 132 components against the review's 55.
