Now I'll produce the complete review report.

# Visit Planner LID Review

## Executive summary

**Posture:** Solid foundation, design-phase; some implicit context to clarify.

**Scorecard**
- ✓ HLD discipline — clean architecture, no implementation detail bleeding
- ✓ LLD granularity — two well-scoped components
- ✓ Linkage hygiene — spec IDs trace cleanly to design nodes
- ⚠ Docs written cold — implicit context in several key terms
- ⚠ Tenet ordering — four tenets with potential conflicts, unordered
- ✓ Mode fit — Full mode matches whole-system scope
- ✓ Mutation hygiene — no accumulation or residue

**Headline:** The design arrow is complete and well-structured across HLD and two LLDs; the fastest wins are clarifying implicit terms and ordering tenets that could conflict.

## Findings (4 total · 0 high · 2 medium · 2 low)

- **F1 (medium):** Design docs use undefined terms assuming conversation context · *docs carry current intent, written to be read cold*
- **F2 (medium):** Four tenets, some potentially conflicting, are unordered · *tenets capture forward-looking preference*
- **F3 (low):** FILL abbreviation reduces grep precision vs. FULFILLMENT · *specs are grep-anchored linkage*
- **F4 (low):** Tests and code phases not yet started — expected state for design-phase project · *canonical arrow shape*

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, all 2 LLDs, all 2 spec files
- Design coverage: 2 intent components (intake, fulfillment)
- Spec inventory: 15 behavioral specs (7 INTAKE, 8 FILL)
- No code or tests present (design-phase project)
- No arrow overlay (docs/arrows/)

## Detail on findings

**F1 — Implicit context (medium priority)**

Several terms appear in design docs without definition, assuming context a cold reader wouldn't have:

- "**the portal**" (HLD, Intake) — used three times but never explained. What portal? Patient-facing web app? Staff interface?
- "**the matcher**" (Fulfillment) — used twice as a noun but never introduced. Is this a component, a process, a service?
- "**registry scan**" (Fulfillment, FILL-003) — what registry? Where is it defined?
- "**offer**" (Fulfillment) — mentioned as something created and expired, but what it is, where it lives, who sees it is left implicit.
- "**searchable**" (Fulfillment) — "makes it searchable" — where? By whom? Presumably the portal, but that's also undefined.
- "**exact retries**" (Intake) — the Decisions table mentions "Client idempotency key" but the main design text doesn't explain what makes a retry "exact."

These work fine in a conversation where terms were introduced as the design evolved. A future session reading these docs cold — or a new team member — has to guess or ask. Consider adding a brief Components or Concepts section to each LLD, or inline definitions where terms first appear.

**F2 — Tenet ordering (medium priority)**

The HLD lists four tenets but doesn't order them. At least two could conflict in practice:

- "**First asked, first served**" says serve patients in request order.
- "**Clinical fit precedes utilization**" says satisfy eligibility before efficiency.

If a patient who asked first is a marginal clinical fit, and a later-asking patient is a better fit, which tenet wins? The second tenet's wording suggests clinical fit would win, but the ordering doesn't make that explicit.

When more than two tenets exist and could conflict, order them so future sessions know which leans harder. Consider listing them in precedence order, highest-priority tie-breaker first.

**F3 — FILL abbreviation (low priority)**

Fulfillment specs use the prefix `FILL-` rather than `FULFILLMENT-`. This is workable and grep-friendly, but `FILL` might match false positives in comments or prose ("fulfill", "filled", "filling"). The slightly longer `FULFILLMENT-` would be more precise and still readable.

Not urgent — the current IDs work — but worth considering if you're standardizing ID style across components.

**F4 — Design-phase arrow (low priority)**

The canonical arrow is HLD → LLDs → EARS → Tests → Code. This project has completed the first three phases but hasn't yet started tests or implementation. This is a natural and healthy state for a design-phase project — the specs are ready to drive test-first development when implementation begins.

Not a gap, just a note on current state.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.