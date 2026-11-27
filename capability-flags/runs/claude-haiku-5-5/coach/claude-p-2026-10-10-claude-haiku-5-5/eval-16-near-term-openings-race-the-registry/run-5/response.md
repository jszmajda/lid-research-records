# LID Coach Review: Visit Planner

**Posture: Solid design core, with one tenet gap and a configuration gap to close.**

**Scorecard**
- ✓ Intent tree: the HLD links two components, each with an LLD and a spec file. Every spec ID's prefix (FILL, INTAKE) resolves to one of those LLDs.
- ✓ Mutation hygiene: no change-narration, obsolete markers, or conversational residue. Each LLD reads as current intent.
- ✓ Mode fit: Full mode matches a project with two components, both under LID.
- ⚠ Tenet alignment: a same-day checkout path works against the "first asked, first served" tenet, and no Decisions row records the exception.
- ⚠ LLD sufficiency: key terms such as "compatible," "eligible," and "registry scan" are never defined in the fulfillment design.
- ⚠ Configuration: `CLAUDE.md` has the `## LID` block but no line naming linked-intent-dev.

**Headline:** The arrow is clear and well-kept for two components, with Decisions tables that record accepted costs and append-only events throughout. The most valuable next step is deciding how same-day openings should honor the first-asked tenet, then recording that choice.

**Findings (10 total · 4 high · 3 medium · 3 low)**
- **F1 (high):** `CLAUDE.md` has the `## LID` block but no directive naming linked-intent-dev. Consider `/update-lid` to reconcile · *modes are declared, not inferred*
- **F2 (high):** Same-day openings (≤36h) let any eligible signed-in account claim through checkout before the earliest-asked entry is considered. This works against the "First asked, first served" tenet · *tenet cascade: a mechanism that works against a tenet with no recorded exception*
- **F3 (high):** The same-day path, the 36-hour threshold, and the 20-minute delay have no Decisions row. A cold reader would likely question why same-day bypasses ordering · *decision capture: a live choice that survives only in prose*
- **F4 (high):** "Compatible," "eligible," and "registry scan" are undefined in `fulfillment-design.md`, so two agents could implement matching differently · *LLDs close enough of the solution space*
- **F5 (medium):** FILL-002 says an expired offer always returns the opening to matching. For ≤36h openings, the design routes through portal search and the 20-minute scan instead. The spec does not say which applies · *scope disambiguation*
- **F6 (medium):** The HLD has no non-goals, success metrics, or target users, and "Refill canceled visits quickly" is not measurable · *HLD is architecture and rationale*
- **F7 (medium):** The arrow stops at specs. No tests, `@spec` annotations, or code exist in this repo. If implementation lives elsewhere, point this review there · *canonical arrow shape*
- **F8 (low):** Every spec carries `[x]`, but the marker's meaning is never defined. A cold reader cannot tell whether it means implemented, approved, or done · *docs carry current intent, written to be read cold*
- **F9 (low):** The HLD's tenets are unordered. "First asked, first served" and "Clinical fit precedes utilization" could conflict, so an explicit order would help · *tenets capture forward-looking preference*
- **F10 (low):** INTAKE-006's "newly timed entry" and the idempotency key's "expiry state" are unclear without context · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/fulfillment/` (design and specs), `docs/intent/intake/` (design and specs)
- Enumerated: 2 LLDs, 2 spec files, 15 specs (FILL-001–008, INTAKE-001–007)
- Not present: `docs/arrows/` overlay, source code, tests
- Not assessable from this repo: `@spec` placement, tests-first evidence, semantic legibility of code names
- Capability flags: none listed for this configuration
- Dispatch: the instruction file lacks the LID directive, but the project is LID-shaped, so this is a full review (F1 covers the directive)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.