Reviewing the project's LID docs against the coach's principles; the report follows.

# LID Coach — Visit Planner

## Executive summary

**Posture:** Clean, well-shaped design layer; one design works against a tenet, and the arrow stops at the specs.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent, with no history residue or obsolete markers
- ✓ Decisions tables — both LLDs name the rejected alternative and the accepted cost on every row
- ✓ Spec form — 15 EARS specs with unique, stable IDs and clear triggers
- ✗ Tenet cascade — the short-notice fill path works against "First asked, first served"
- ✗ Arrow completeness — no tests or code in the repository, yet every spec is checked off
- ⚠ LLD sufficiency — the short-notice path leaves several edges open, and some designed behavior has no spec
- ⚠ Configuration — the mode marker is present, but the LID workflow directives are not

**Headline:** The HLD, two LLDs and two spec files are tight, current and consistently linked, with real tenets and honest decision tables. The most valuable next step is to settle the short-notice path in `fulfillment-design.md`: either bring it in line with "First asked, first served" or record it as a deliberate exception.

## Findings (11 total · 4 high · 4 medium · 3 low)

- **F1 (high):** Openings 36 hours or less away are searchable and claimable by any eligible signed-in account for 20 minutes before the waiting list is consulted (`fulfillment-design.md:9`, FILL-003/004/005). Under that condition a later request, or someone who never asked, passes an earlier one, which the tenet says never happens. · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean
- **F2 (high):** That exception has no Decisions row naming the tenet traded against and why, and the 36-hour, 20-minute and two-hour figures have no stated source. · *decision capture* — a choice a cold reader would question carries its reasoning on the page
- **F3 (high):** All 15 specs are marked `[x]`, but the repository has no tests, no code and no `@spec` annotations. If the implementation lives in another repo, consider saying so in `CLAUDE.md`; otherwise the markers are ahead of reality. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present
- **F4 (high):** `CLAUDE.md` has the `## LID` mode and version block but no linked-intent-dev workflow directives, so a fresh session isn't told to follow the arrow. Run `/update-lid` to reconcile. · *modes are declared, not inferred* — configuration is explicit in the instruction file
- **F5 (medium):** The short-notice path leaves edges open: how long a post-scan offer lasts, whether the opening stays searchable during that offer, what happens when no compatible entry exists, and how a short-notice opening freed by offer expiry (not cancellation) is handled. · *LLDs close enough of the solution space* — two agents would land on compatible implementations
- **F6 (medium):** Some designed behavior has no spec: one winner under concurrent claims (the row lock), idempotency-key expiry, and validation of accessibility needs. FILL-005 also drops "active" where FILL-001 has it. · *coherence is adjacency* — specs match the LLD
- **F7 (medium):** The HLD has no non-goals, target users, key design decisions or success metrics. The "normalized view of clinic openings" and the portal search/checkout that Fulfillment relies on have no owning component. · *HLD is architecture and rationale* — the HLD carries the project-level why
- **F8 (medium):** The four tenets are an unordered list, so nothing says which wins when they pull apart. F1 is exactly that case: first-asked against the goal of refilling quickly. · *tenets capture forward-looking preference* — ordered tie-breakers when they can conflict
- **F9 (low):** "Registry scan", "checkout" and "cancellation handler" appear in `fulfillment-design.md` without definition, and the registry is never named in the Intake docs. · *docs carry current intent, written to be read cold* — a doc stands without the conversation behind it
- **F10 (low):** The `FILL` prefix isn't declared anywhere (no `prefix:` frontmatter; the directory is `fulfillment`). Consider declaring it so the ID-to-LLD mapping isn't inferred. · *specs are grep-anchored linkage* — the ID prefix names the owning design node
- **F11 (low):** The rule that time, site and accessibility changes keep `enteredAt` while a service change resets it has no Decisions row. A reader could question it, since widening a window keeps the patient's place. · *decision capture*

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`) and both spec files.
- **Enumerated:** 2 LLDs, 2 spec files, 15 specs (INTAKE-001–007, FILL-001–008), 8 Decisions rows, 4 tenets, 3 goals.
- **Code and tests:** none in the repository; 0 `@spec` references.
- **Arrow overlay:** `docs/arrows/` is not installed, so no structural audit was available to draw on.
- **Dispatch:** Full mode as declared; full review anchored on the existing artifacts. This was a non-interactive run and no point came up where I needed your input.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.