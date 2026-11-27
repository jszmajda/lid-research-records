# LID Coach — Visit Planner

**Posture:** Strong intent docs; arrow stops early.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, clean tenets, no implementation bleed
- ✓ LLD granularity — one leaf per intent component, tight Decisions tables
- ✓ Mutation hygiene — docs read as current intent; no change-narration or fossils
- ⚠ Arrow completeness — Tests and Code phases absent
- ⚠ Linkage — one spec prefix doesn't resolve to its leaf without a mapping
- ⚠ Configuration — instruction file carries the mode marker but not the LID directive block

**Headline:** The design layer is genuinely well-written — the HLD's tenets are real tie-breakers and both LLDs close most of their solution space — but the arrow currently ends at specs; the fastest win is building the Tests/Code phases, with configuration reconciliation right behind it.

## Findings (6 total · 3 high · 2 medium · 1 low)

> **Findings**
> - **F1 (high):** No tests or code exist anywhere in the repo, so every spec is uncited and unexercised · *tests before code — tests preload the system's use into context; *tests carry `@spec` annotations — a test without a spec citation is an orphan
> - **F2 (high):** `CLAUDE.md` has a `## LID` block with `- Mode: Full` but lacks the LID directive block itself (no reference to linked-intent-dev or the workflow), so future sessions won't know how to walk the arrow · *modes are declared, not inferred — declaration makes the foundation visible; run `/update-lid` to reconcile
> - **F3 (high):** "Compatible" appears throughout `FILL-001/005/006` and the fulfillment design ("validates clinical compatibility"), but no spec or design statement defines what compatibility means or which fields it checks · *LLDs close enough of the solution space — two agents reading this would implement matching differently
> - **F4 (medium):** Spec IDs use `FILL-`, which doesn't name or obviously map to the `fulfillment` leaf; no `prefix:` frontmatter or `index.yaml` exists to resolve it · *specs are grep-anchored linkage — IDs are the walkable token path; consider `INTAKE-`/`FILL-` disambiguation via leaf frontmatter or rename
> - **F5 (medium):** The 36-hour cutoff, two-hour offer window, and 20-minute `notBefore` drive the entire two-path fulfillment design, yet no Decisions & Alternatives row records what was traded away for these values — a cold reader would question and possibly "fix" them · *decision capture — a live choice needs its cost on the page
> - **F6 (low):** HLD has Problem/Approach/Tenets/Goals/Components but no explicit non-goals section · *HLD is architecture and rationale — non-goals prevent scope creep arguments later

## What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs, both spec files — effectively 100% of the repo
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 INTAKE, 8 FILL), 8 Decisions-table rows
- Sampled: no code or test files exist to sample; no `docs/arrows/` overlay present

## Out-of-scope note
Omitted — Full mode.

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---
*Defaults taken in this non-interactive run: dispatch resolved as "proceed with full review anchored on existing artifacts" (the `## LID` block with `- Mode: Full` exists but the directive block is absent — surfaced as F2 rather than refusing, per the LID-shaped threshold); mode defaulted to Full as declared; no sampling guidance was needed (2 LLDs, no overlay); the capability-flags reference listed no flagged configurations, so no flag note applies. Per the skill's advisory posture, no files were edited.*