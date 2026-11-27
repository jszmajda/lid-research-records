# LID Coach — Visit Planner

## Executive summary

**Posture:** *Bootstrapping — clean design layer, one tenet conflict in Fulfillment, nothing yet downstream of the specs.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, with no schemas or signatures
- ✓ Mutation hygiene — every doc reads as current intent, with no history or planning residue
- ✓ Intent-tree alignment — two HLD components, two LLDs, two spec files, with stable unique IDs
- ⚠ Tenet cascade — Fulfillment's short-notice path leans against the HLD's first tenet
- ⚠ Decision capture — that same choice has no Decisions row
- ✗ Arrow completeness — no tests or code in the repo, though every spec is marked `[x]`

**Headline:** The design layer is compact, cold-readable and well-shaped, with real tie-breaker tenets and decision tables that name what was given up. The most valuable next step is to reconcile Fulfillment's short-notice path with *First asked, first served*, either by changing the mechanism or by recording the exception on purpose.

## Findings (8 total · 4 high · 3 medium · 1 low)

- **F1 (high):** Short-notice openings can go to someone who never waited. For openings 36 hours or less away, `fulfillment-design.md:9` and FILL-003/004 let any eligible signed-in account claim the opening for 20 minutes before the earliest waiting entry is considered. The HLD says an earlier request is "never passed by one made after it", and names close-to-visit cancellations as the common case. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say to lean.
- **F2 (high):** The 36-hour split and 20-minute open window have no Decisions & Alternatives row. Nothing names the tenet being traded, the alternative (for example, offering to the waitlist first with a shorter offer), or the accepted cost. · *docs carry current intent, written to be read cold* — a choice a cold reader would question needs its reasoning on the page.
- **F3 (high):** All 15 specs are marked `[x]`, but the repo holds no tests, no code and no `@spec` annotations. Consider resetting the markers, or bringing the tests and code into this repo. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present.
- **F4 (high):** `CLAUDE.md` has the `## LID` mode block but none of the linked-intent-dev workflow directives, so a future session is not told to follow the arrow. Run `/update-lid` to reconcile. · *modes are declared, not inferred* — configuration lives explicitly in the instruction file.
- **F5 (medium):** The HLD promises a "normalized view of clinic openings" and lets staff act for patients who call, but neither has an LLD or spec. FILL-004 and INTAKE-001 only speak of a signed-in or authenticated account. · *effective intent-tree alignment* — every HLD concept traces down to an owning design node.
- **F6 (medium):** Fulfillment leaves several edges open:
  - "Compatible" is not defined.
  - Offer acceptance and decline have no design or spec.
  - The offer length on the short-notice path is unstated, and a two-hour offer could outlast the opening.
  - The two-hour duration is in the LLD but not in FILL-001.
  
  · *LLDs close enough of the solution space* — two agents reading the doc should land on compatible implementations.
- **F7 (medium):** FILL-002 ("release the opening and run matching again") does not say which path a short-notice opening re-enters: public search again, or straight to the registry. FILL-005 also drops the "active" qualifier that FILL-001 carries. · *scope disambiguation* — a spec that applies to one variant says so in its trigger.
- **F8 (low):** The four tenets are unordered. *First asked, first served* and the goal "refill canceled visits quickly" pull against each other, which is the tension behind F1. Consider ranking them so the next tie breaks your way. · *tenets capture forward-looking preference* — ordered tie-breakers for decisions no spec anticipated.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 15 specs (INTAKE-001–007, FILL-001–008), 8 Decisions rows.
- Code and tests: none in the repo, so there are 0 `@spec` references and nothing to sample.
- No arrow overlay (`docs/arrows/`) is present.
- Git history is a single commit, so tests-first ordering could not be assessed.
- Dispatch: Full mode. The directive text is absent but the project is LID-shaped, so this was a full review anchored on the artifacts (see F4).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are a natural pair.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.