---

## LID Coach Report: Shelfwise

**Posture:** Bootstrapping — arrow in place, design well-specified, ready for implementation; core user journeys need closure.

**Scorecard**
- ✓ HLD discipline — clean architecture without implementation detail; tenets are real tie-breakers
- ✓ LLD granularity — one per intent component; scopes align with HLD
- ✓ Spec ID hygiene — well-formed, grep-friendly, aligned with LLDs
- ⚠ Completeness — critical user journey (hold cancellation) missing from specs
- ⚠ Integration clarity — handoff between allocation and pickup-notices is implicit
- ✓ Decision capture — Decisions & Alternatives tables are thorough and reasoned

**Headline:** The design is clean and well-structured at the HLD and LLD layers; the fastest wins are adding specs for patron hold cancellation and clarifying the boundary between the two intent components.

---

## Findings (4 total · 1 high · 2 medium · 1 low)

- **F1 (high):** Missing spec for patron hold cancellation · *arrow completeness* — A critical user action implied by the LLDs and mentioned in the Decisions table ("heavy readers occasionally hit the cap and must cancel one") has no corresponding EARS spec. When implementation starts, the team will need to infer the cancellation behavior from context.

- **F2 (medium):** Integration between allocation and pickup-notices is implicit, not explicitly specced · *effective intent-tree alignment* — The hold-allocation LLD describes marking a copy `allocated` and its eventual pickup or expiry, but the handoff to pickup-notices (which owns the notification window and expiry handling) is unspecified. PICKUP-001 references "an allocated copy", implying the boundary, but no allocation spec describes the state transition that triggers pickup-notices' work.

- **F3 (medium):** Goals lack explicit traceability to specs · *arrow completeness* — The HLD lists two measurable goals (sub-4-hour notification, <10% expiry rate), but the specs don't show which ones they address. A traceability note (e.g., "Goal 1: HOLDALLOC-003, 004, PICKUP-002") would help the team verify completeness during implementation.

- **F4 (low):** "Last pickup date" in PICKUP-002 needs clarification · *LLD sufficiency* — The spec says the ready notice should name "the title, branch, and last pickup date". To a cold reader implementing this, "last pickup date" is ambiguous — does it mean the date the window closes, or the last day the patron can pick up? Recommend rephrasing to "pickup window expiration date" or "pickup deadline: [7 days from today]".

---

## What was audited

- Read fully: CLAUDE.md (instruction file), docs/high-level-design.md, all LLDs (hold-allocation-design.md, pickup-notices-design.md), all spec files (hold-allocation-specs.md, pickup-notices-specs.md)
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs total
- Observed: no code, tests, or arrow-maintenance overlay (project is at bootstrap stage)
- Scope: Full mode, all paths in scope

---

## Worth a second look

Haiku-class models are known to miss design decisions that depend on project context or historical data (e.g., why the hold cap is exactly 15 patrons). The hold-cap decision in the Decisions table references preventing one patron from "reserving a whole genre" — this may rest on prior analysis of patron behavior or collection size. Please review the decisions in the hold-allocation LLD yourself to ensure the specifics (the 15-hold limit, the transit-vs-shelf allocation cutoff) are grounded in real constraints the team knows.

---

Want me to walk through the findings in detail, focus on a specific theme or item, or help you plan the closure for cancellation flows and integration boundaries?

If you have broader questions about using LID for your project — how to structure the code/test layers once you start implementation, whether you need an arrow-maintenance overlay at this stage, or how to keep the project organized as it grows — I can help with those too.