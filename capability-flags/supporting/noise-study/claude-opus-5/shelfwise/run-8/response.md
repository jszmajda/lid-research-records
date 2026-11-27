**Shelfwise — LID Coach Report**

## Executive summary

**Posture:** Design layer is real and readable; the arrow stops at EARS, and a tenet and the allocation rule disagree.

**Scorecard**
- ✓ LLD granularity — two leaves, one clear concern each, both reachable from the HLD's Components list
- ✓ Decision capture habit — every LLD carries a Decisions & Alternatives table with rejected options and named costs
- ⚠ Configuration — the `## LID` block declares mode and version but carries no LID directives
- ✗ Arrow completeness — no tests and no code, yet all 13 specs are marked complete
- ⚠ Tenet coherence — branch-first allocation runs against "waiting is honored in sequence"
- ⚠ LLD sufficiency — hold state, cancellation, and normal transit arrival are referenced but unspecified

**Headline:** The two leaf designs are tight, honest documents — short, current, and written with the costs of each choice on the page, which is exactly the part teams usually skip; the fastest wins are reconciling the instruction file with `/update-lid`, closing the three unspecified behaviors in hold allocation, and deciding whether the branch-preference rule or the sequencing tenet is the one you actually mean.

## Findings (14 total · 5 high · 7 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block gives `Mode: Full` and `Version: 1.4.0` but no LID directives — nothing tells a fresh session how to walk the arrow · *modes are declared, not inferred* — the mode and the working rules live in the instruction file, not in the agent's memory
- **F2 (high):** All 13 specs carry `[x]`, but the repo holds only docs — no tests, no code, no `@spec` annotation anywhere · *canonical arrow shape* and *tests before code* — the bottom two phases are where specs get checked against reality
- **F3 (high):** `HOLDALLOC-003`/`004` give the scanning branch first claim, so a later local request can be served ahead of an older county-wide one, against the tenet "nobody's wait is lengthened by a patron who asked after them" · *coherence is adjacency* — each level agrees with the one above it
- **F4 (high):** Hold state is never modeled (only the copy is `allocated`), so two copies of one title checked in together can both allocate to the same oldest hold — `HOLDALLOC-006` guards copies, not holds · *LLDs close enough of the solution space* — open edges are where an agent's guess becomes the design
- **F5 (high):** Hold cancellation is relied on by `HOLDALLOC-007` and the design prose but specified nowhere — no spec says what closing a cancelled hold does to its record or its copy · *effective intent-tree alignment* — described behavior with no spec is unnamed intent
- **F6 (medium):** The branch-first-vs-county-FIFO tradeoff — the most consequential choice in hold allocation — has no Decisions & Alternatives row naming strict FIFO as the rejected option and the queue-jump as the accepted cost · *docs carry current intent* — a cold reader should be able to reconstruct the choice
- **F7 (medium):** `pickup-notices-design.md:11` closes the hold when the window lapses; `PICKUP-004`/`005` close it when staff scan the copy off the shelf · *coherence is adjacency* — LLD and specs disagree at the seam
- **F8 (medium):** Goal 1 ("4 business hours") has no business-hours notion anywhere in the specs, and Goal 2 needs expiry counts that `PICKUP-003`/`005` delete on close · *HLD is architecture and rationale* — success metrics need a path to being measurable
- **F9 (medium):** The re-entry contract ("a released copy re-runs allocation as a check-in at its current branch") is stated three times in three phrasings across both leaves with no owning node · *intent attaches at the lowest node that dominates it* — shared substance belongs at the shared parent
- **F10 (medium):** A normal in-transit arrival has no spec — only the cancelled-hold case (`HOLDALLOC-007`) is covered, so holds-shelf placement at the destination is implied rather than stated · *arrow completeness* — a phase-level gap in a path the design describes
- **F11 (medium):** The HLD has Problem, Approach, Tenets, Goals, and Components but no target users, no non-goals, and no Key Design Decisions section · *HLD is architecture and rationale* — the omissions are where scope creep enters unchallenged
- **F12 (medium):** Tenets are unordered although at least two can collide in practice, and "Hold history is not kept" reads as a settled policy rather than a lean · *tenets capture forward-looking preference* — a tie-breaker has to say which way to lean when two of them pull apart
- **F13 (low):** Neither spec file carries `prefix:` frontmatter, so `HOLDALLOC`/`PICKUP` resolve to their leaves only by convention · *specs are grep-anchored linkage* — the prefix boundary should be machine-resolvable
- **F14 (low):** "daily exceptions list" (design) vs "that day's exceptions list" (`PICKUP-006`), and "morning pull list" has no defined cutoff · *semantic legibility as cheap linkage* — one name per thing keeps the grep cheap

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/` — the entire LID surface of the project (6 files)
- Enumerated: 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 4 tenets, 2 goals, 7 Decisions & Alternatives rows
- Linkage metric: 0 `@spec` references; 0 test files; 0 code files — the repo currently contains docs only
- Arrow-path sampling: not applicable at this size (well under the 15-LLD threshold); both segments were walked end-to-end as far as the arrow goes — HLD section → leaf design → specs, where the path ends
- Structural overlay: `docs/arrows/` is not installed, so no `index.yaml` evidence of in-flight segments or recorded drift was available; findings above come from reading, not enumeration
- Cold-read pass: performed on all four LID docs plus the HLD; a decisions-table sweep covered all 7 rows (F6 is the one row-level gap — the others reconstruct cleanly)
- Non-interactive run: dispatch matched "instruction file missing LID directives but project is LID-shaped," so the skill's default was taken — a full review anchored on the existing artifacts, with the configuration gap surfaced as F1 rather than a refusal. Mode read as declared (`Full`), so no out-of-scope section applies.

**Worth a second look:** I could not read the core skill's capability-flags reference from this session, so I am treating the flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets — F3 and F12 are my read of that, but please check all four tenets against both leaf designs yourself, particularly "Patrons hear once, clearly" against the notice, exceptions-list, and pull-list paths.

Want me to walk through the findings in detail, focus on a theme or a priority band, or work through specific items together? You can also pick a single finding — F3 and F6 are closely related and worth taking as a pair, since deciding which way you actually lean settles both.

If you have broader questions about using LID on Shelfwise — where a PRD for the circulation-system integration would sit, when a leaf like hold allocation is ready to become a sub-HLD, or whether to install the arrow overlay now that you have two segments — I can help with those too.