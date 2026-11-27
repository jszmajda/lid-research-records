# LID Coach: Visit Planner

## Executive summary

**Posture:** Clean, well-shaped design tree; one leaf design leans against the top tenet, and the arrow stops at specs.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent, with no history or planning residue
- ✓ LLD granularity — Intake and Fulfillment are two real components, each with one design and one spec file
- ⚠ Tenet cascade — the near-term cancellation path works against "First asked, first served"
- ⚠ Decision capture — existing rows are good, but the most questionable choices have no row
- ✗ Arrow completeness — no tests or code in the repo, yet all 15 specs are checked `[x]`
- ⚠ Configuration — `CLAUDE.md` has the mode marker but not the LID directive block

**Headline:** The docs are tight, and the Decisions tables name a rejected alternative and an accepted cost on every row. The most valuable next step is to settle how the 20-minute open-claim window squares with "First asked, first served", then record that choice.

## Findings (12 total · 4 high · 4 medium · 4 low)

- **F1 (high):** For openings 36 hours or less away, Fulfillment publishes to portal search for 20 minutes before consulting the waiting list (`fulfillment-design.md:9`, FILL-003/004/005). Any signed-in account can therefore claim ahead of a patient who asked weeks earlier, and callers who rely on staff cannot compete at all. This cuts against the tenet "an earlier request is never passed by one made after it", and nothing records the exception. · *tenet cascade* (leaf designs lean the way the HLD's tenets say to lean)
- **F2 (high):** The 36-hour split, the 20-minute open window and the search-before-waitlist order have no Decisions row. A cold reader cannot tell what was given up or why. · *decision capture* (a choice a reader would question carries its reasoning on the page)
- **F3 (high):** `CLAUDE.md` has the `## LID` block with `Mode: Full` but no linked-intent-dev directives, so a fresh session is not told to follow the workflow. Consider running `/update-lid` to reconcile. · *modes are declared, not inferred* (configuration lives in the instruction file)
- **F4 (high):** The repo has no tests and no code, yet every spec is marked `[x]`. Either the markers are ahead of reality or the implementation lives elsewhere without saying so. Either way, the arrow cannot be walked past the specs. · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code, with each phase present)
- **F5 (medium):** The Fulfillment design leaves several edges open:
  - how an offer is accepted;
  - what "compatible" checks, and whether Intake's accessibility needs feed it;
  - how long an offer lasts on an opening only a few hours away;
  - whether an offered opening stays visible in search.
  
  · *LLDs close enough of the solution space* (two agents reading it would build compatible things)
- **F6 (medium):** Two design statements have no spec. The two-hour offer length is in the LLD but not in FILL-001. The HLD's "staff may act for patients who call" has no spec in either file; INTAKE-001 and FILL-004 name only authenticated or signed-in accounts. · *coherence is adjacency* (each level agrees with the one next to it)
- **F7 (medium):** FILL-002 ("when an offer expires… run matching again") reads as universal but sits beside two paths. It does not say whether a near-term opening goes back to search, to the waitlist, or to both. Likewise, FILL-003 triggers only on "canceled", while FILL-001 triggers on "becomes free". · *scope disambiguation* (a spec that applies to one variant says so in its trigger)
- **F8 (medium):** The HLD's first goal and its Approach rest on a "normalized view of clinic openings", but neither component owns how openings arrive from clinic calendars. Consider whether that is a third component or part of Fulfillment. · *effective intent-tree alignment* (each HLD concept traces to a design node)
- **F9 (low):** Keeping `enteredAt` when the time, site or accessibility preferences change, but resetting it on a service change, decides who holds queue position. It appears in the prose and INTAKE-005/006 but has no Decisions row. · *decision capture*
- **F10 (low):** The four tenets are unordered, though "First asked, first served" and "Clinical fit precedes utilization" can pull apart. Stating the order would settle ties. · *tenets capture forward-looking preference* (tenets are ordered tie-breakers)
- **F11 (low):** The HLD has no non-goals, target users, key design decisions or success metrics. "Routine primary-care" hints at a boundary that is worth stating. · *HLD is architecture and rationale*
- **F12 (low):** Two small cold-read items. The `FILL` prefix is not declared anywhere as Fulfillment's (for example in `prefix:` frontmatter). The term "registry scan" appears without "registry" being defined. · *docs carry current intent, written to be read cold*

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- **Enumerated:** 2 LLDs, 2 spec files, 15 specs (INTAKE-001–007, FILL-001–008), 8 Decisions rows, 4 tenets.
- **Code and tests:** none in the repo, so there are 0 `@spec` references and the annotation and tests-first dimensions could not be assessed.
- **Overlay:** there is no `docs/arrows/`, so this was a judgment review with no structural audit.
- **Dispatch:** full review in Full mode, anchored on the existing artifacts. The run was non-interactive, and no step needed a user decision.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.