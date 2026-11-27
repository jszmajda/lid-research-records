# LID Coach — Shelfwise

## Executive summary

**Posture:** Clear, well-reasoned design layer; one design works against a tenet, and the arrow stops at the specs.

**Scorecard**
- ✓ Doc hygiene — the HLD and both LLDs read cold as current intent, with no history residue or implementation detail in the HLD
- ✓ Spec quality — 13 EARS specs with clean triggers, unique stable IDs, and prefixes (`HOLDALLOC`, `PICKUP`) that map one-to-one onto the two components
- ✓ Decision capture in pickup notices — every row names what was given up, and the expiry row records its cost against Goal 1
- ⚠ Tenet cascade — hold allocation's branch-first rule works against "Waiting is honored in sequence", with no recorded exception
- ✗ Arrow completeness — every spec is marked `[x]`, but the repository has no tests and no code
- ⚠ Configuration — `CLAUDE.md` declares mode and version but carries no LID directives

**Headline:** The design tree is small, well-shaped and unusually honest about its tradeoffs. The most valuable next step is to settle whether branch-first allocation is a deliberate exception to your first tenet, and record it either way.

## Findings (7 total · 4 high · 2 medium · 1 low)

- **F1 (high):** Branch-first allocation lets a later hold at the scanning branch receive a copy ahead of an older hold elsewhere in the county (`hold-allocation-design.md:11`, HOLDALLOC-003/004). That works against the tenet "nobody's wait is lengthened by a patron who asked after them". The same rule is re-applied on expiry and cancelled-transit reallocation (PICKUP-005, HOLDALLOC-007). · *tenet cascade* — leaf designs should lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The branch-first choice has no Decisions & Alternatives row. Its only rationale is one clause of body prose ("keeps most copies off the courier van"), with no rejected alternative, no named tenet traded against, and no accepted cost. · *docs carry current intent, written to be read cold* — a choice a cold reader would question needs its reasoning on the page.
- **F3 (high):** All 13 specs are marked `[x]`, yet there are no test or code files and no `@spec` annotations anywhere. Either the implementation lives somewhere the docs don't name, or the markers are ahead of reality. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present so intent can be walked down to the behaviour.
- **F4 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full, Version 1.4.0) but none of the linked-intent-dev directives, so future sessions are not told to follow the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is where the methodology is switched on.
- **F5 (medium):** Hold cancellation has no spec of its own. It appears only as a precondition in HOLDALLOC-007. Cancelling a waiting hold, or one whose copy is already on the holds shelf, is undesigned. Nothing commits to deleting a cancelled hold's record, which the "Hold history is not kept" tenet requires. · *LLDs close enough of the solution space* — edges left open are filled by guesswork.
- **F6 (medium):** The pickup-notices LLD reads as though the hold closes when the window lapses (`pickup-notices-design.md:11`), while PICKUP-004/005 close it only when staff scan the copy off the shelf. Whether a patron can still check out a lapsed copy before the morning pull is open. · *coherence is adjacency* — each level agrees with the one next to it.
- **F7 (low):** The four tenets are an unordered list, so there is no stated winner when they pull against each other. "Staff attention goes to exceptions" also reads closer to a value than a tie-breaker. · *tenets capture forward-looking preference* — a tenet is a lean for decisions no spec covers, ordered when leans can collide.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions rows.
- Code and tests: none in the repository, so there was nothing to sample and no `@spec` references to count.
- Arrow overlay: `docs/arrows/` is not present, so no structural audit inputs were available.
- Dispatch: the instruction file lacks LID directives but the project is plainly LID-shaped, so this was a full review in Full mode with the configuration gap raised as F4.
- Non-interactive run: no questions arose that needed a default, and nothing was edited or written to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.