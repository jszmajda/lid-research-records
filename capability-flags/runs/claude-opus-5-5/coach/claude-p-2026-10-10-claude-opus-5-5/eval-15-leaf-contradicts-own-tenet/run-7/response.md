# LID Coach — Shelfwise

## Executive summary

**Posture:** *Clean design layer; one unrecorded tension with a tenet, and the arrow stops at specs.*

**Scorecard**
- ✓ Doc hygiene — every doc reads as current intent, with no change-narration or chat residue
- ✓ Decision capture — rows name what was rejected and the cost accepted; the expiry-handling row even records its trade against Goal 1
- ✓ Intent-tree alignment — two HLD components, two LLDs, two spec prefixes (`HOLDALLOC`, `PICKUP`), one to one
- ⚠ Tenet cascade — branch-first allocation leans against "Waiting is honored in sequence" with no recorded exception
- ⚠ Spec coverage — a few designed behaviors have no spec, and one spec disagrees with its LLD
- ✗ Arrow completeness — no tests or code in the repo, yet all 13 specs are marked `[x]`
- ⚠ Configuration — `CLAUDE.md` has the mode marker but not the LID directive block

**Headline:** The design layer is in good shape — a tight HLD with real tenets, right-sized LLDs and clean EARS specs. The most valuable next step is to settle whether branch-first allocation is a deliberate exception to "Waiting is honored in sequence" and record it either way.

## Findings (10 total · 3 high · 5 medium · 2 low)

- **F1 (high):** Branch-first allocation (`hold-allocation-design.md:11`, HOLDALLOC-003) gives a returned copy to the oldest hold at the scanning branch, even when a patron at another branch has waited longer. The tenet says "nobody's wait is lengthened by a patron who asked after them". · *tenet cascade* — leaf designs should lean the way the HLD's tenets say, or record the exception.
- **F2 (high):** The branch-first choice has no Decisions row. The courier-van reason sits in one prose sentence, with no mention of the rejected alternative (strict county-wide order) or the tenet being traded. · *decision capture* — a choice a cold reader would question needs its alternative and cost on the page.
- **F3 (high):** All 13 specs are marked `[x]`, but the repo holds no tests and no code. · *canonical arrow shape* — HLD → LLDs → specs → tests → code; a status marker should reflect what the arrow can actually show.
- **F4 (medium):** `CLAUDE.md` lacks the linked-intent-dev directive block, so future sessions get the mode but not the workflow. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is where LID's setup is made visible.
- **F5 (medium):** The LLD closes a lapsed hold when the window lapses (`pickup-notices-design.md:11`); PICKUP-005 closes it when staff scan the copy off the shelf. A patron arriving in between gets a different answer from each. · *coherence is adjacency* — each level agrees with the one next to it.
- **F6 (medium):** Some designed behaviors have no spec: cancelling a hold (only the in-transit case, HOLDALLOC-007, is covered), deleting a cancelled hold's record, and releasing `allocated` at checkout. · *effective intent-tree alignment* — unspecced behavior drifts because nothing tests it.
- **F7 (medium):** A few edges are left open for an implementer to guess: what counts as a failed delivery on the phone-dialer channel, whether a patron is told their hold expired, and how the staff call on failed delivery squares with "on the channel the patron chose". · *LLDs close enough of the solution space* — two agents reading the doc should land on compatible implementations.
- **F8 (medium):** The four tenets are an unordered list, though they can pull against each other and against the goals (for example "hear once" against Goal 2). · *tenets capture forward-looking preference* — a tie-breaker list needs an order when its entries can conflict.
- **F9 (low):** "Hold history is not kept" is written as a fixed rule ("a closed hold's record is deleted") rather than a lean. Consider keeping the privacy lean as the tenet and leaving the deletion rule to the specs. · *tenets capture forward-looking preference* — tenets lean; specs trigger.
- **F10 (low):** The HLD has no target users or non-goals. · *HLD is architecture and rationale* — non-goals tell a future session what not to build.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files — 6 files, the whole repo.
- Enumerated: 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions rows, 4 tenets, 2 goals.
- Code and tests: none present, so `@spec` placement, tests-first evidence and semantic legibility could not be assessed.
- Arrow overlay: `docs/arrows/` is not installed, so no structural audit was available.
- Dispatch: the `## LID` block declares Full mode but the directive block is absent. Per the skill's default I ran a full review on the existing artifacts and raised the gap as F4.
- Non-interactive run: nothing was edited and no questions were asked.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.