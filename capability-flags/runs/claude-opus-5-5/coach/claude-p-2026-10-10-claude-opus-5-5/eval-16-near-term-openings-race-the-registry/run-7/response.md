# LID Coach: Visit Planner

## Executive summary

**Posture:** Clean, well-shaped design layer, with one tenet conflict in Fulfillment and no tests or code downstream yet.

**Scorecard**
- ✓ Design-tree shape — one HLD, two LLDs that match the HLD's two components, one spec file each
- ✓ Mutation hygiene — every doc reads as current intent, with no history, changelog or planning residue
- ✓ HLD discipline — architecture and rationale only, with no schemas or signatures
- ⚠ Tenet cascade — the short-notice path in Fulfillment works against "First asked, first served"
- ⚠ LLD sufficiency — several terms and edges the matcher depends on are left open
- ✗ Arrow completeness — no tests or code in the repository, though every spec is marked `[x]`

**Headline:** The design layer is in good shape — tight docs, real tenets, Decisions tables that name the rejected alternative and the accepted cost. The most valuable next step is to settle whether the 20-minute open-search window for short-notice openings is a deliberate exception to "First asked, first served", and record the answer.

## Findings (9 total · 4 high · 3 medium · 2 low)

- **F1 (high):** Short-notice openings can be claimed by "any eligible signed-in account" for 20 minutes before waiting entries are considered (`fulfillment-design.md:9`, FILL-003/004). This passes over earlier requests, which the tenet at `high-level-design.md:10` says never happens. · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean.
- **F2 (high):** The 36-hour split, the 20-minute head start and the open-checkout choice have no Decisions row, so a cold reader cannot tell what was traded against the tenet or why. · *decision capture* — a choice a reader would still question needs its alternative and cost on the page.
- **F3 (high):** There are no tests and no code in the repo, yet all 15 specs are checked `[x]`. Consider unchecking them, or documenting where the implementation lives if it is elsewhere. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present. Also *tests carry `@spec` annotations* — each test cites the spec it exercises.
- **F4 (high):** `CLAUDE.md` has the `## LID` mode block but not the linked-intent-dev directive block, so future sessions get the mode without the workflow. Run `/update-lid` to reconcile. · *modes are declared, not inferred* — the instruction file is the foundation everything else keys off.
- **F5 (medium):** Fulfillment leaves load-bearing terms and edges open: "compatible" vs "eligible", "registry scan", how an offer is accepted or declined, and what the two-hour offer means for an opening less than two hours away. · *LLDs close enough of the solution space* — two agents reading the LLD should land on compatible implementations.
- **F6 (medium):** Some intent in the HLD and LLDs has no spec:
  - The two-hour offer duration is absent from FILL-001.
  - Staff acting for callers appears in the HLD Approach, but INTAKE-001 and FILL-004 cover only authenticated or signed-in accounts.
  - Idempotency-key expiry is named as an accepted cost in the Intake Decisions table, with no spec.
  
  *Effective intent-tree alignment* — behaviours without specs drift because nothing tests them. `/arrow-maintenance` can enumerate these precisely if the overlay is installed.
- **F7 (medium):** The four tenets are unordered, and nothing says which wins when "First asked, first served" meets the goal "Refill canceled visits quickly" — the tension F1 sits on. The first tenet's "never" also reads as an invariant rather than a lean. · *tenets capture forward-looking preference* — ordered tie-breakers for the choices no spec anticipated.
- **F8 (low):** The HLD has no non-goals, target users or success metrics. "Routine primary-care" in Goals hints at a scope boundary that is not stated. · *HLD is architecture and rationale* — the HLD holds the long-lived why, including what the system is not for.
- **F9 (low):** The `FILL` prefix is not declared in the Fulfillment LLD. A `prefix:` frontmatter line would let a grep for `FILL-` resolve to its owner without inference. · *specs are grep-anchored linkage* — IDs carry the path to the owning design node.

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`) and both spec files (7 `INTAKE` specs, 8 `FILL` specs).
- **Code and tests:** none in the repository, so there are 0 `@spec` references and nothing to sample.
- **Arrow overlay:** `docs/arrows/` is not present, so no structural audit was attempted.
- **Decisions tables:** all 8 rows were swept and stand on their own. The gap is the missing rows in F2.
- **Dispatch:** the mode marker is present (Full) but the directive block is absent, so this was a full review anchored on the existing artifacts.
- **Non-interactive run:** no prompts arose, and nothing was edited or written to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.