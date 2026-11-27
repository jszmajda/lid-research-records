I have everything I need. Here's the review.

---

# /lid-coach — printfarm

## Executive summary

**Posture:** *Healthy design layer; the arrow stops at the spec line, and one leaf mechanism quietly works against a core promise.*

**Scorecard**
- ✓ **LLD granularity** — two leaf LLDs, one per intent component, matching the HLD's two nodes exactly
- ✓ **HLD discipline** — architecture and rationale only; SQLite/schema detail stays down in the registry LLD where it belongs
- ✓ **Linkage IDs** — `QUEUE-00x` / `REG-00x` are unique, zero-padded, grep-friendly, and their `prefix:` frontmatter resolves cleanly to each leaf
- ⚠ **Spec coverage** — real LLD behaviors (prioritization, acceptance guard) have no EARS spec
- ⚠ **Tenet cascade** — the in-memory queue defeats the "upload and walk away" promise under conditions the LLD itself describes
- ⚠ **Arrow completeness** — Tests and Code phases are absent though every spec is marked `[x]`
- ✓ **Mode fit** — Full mode matches a two-component, wholly-LID repo

**Headline:** The design tree is genuinely clean — the HLD/LLD split is disciplined, granularity matches intent, and linkage IDs are solid. The highest-value work is downstream: close the gap between what the LLDs say and what the specs name, and reconcile one leaf mechanism with the tenet it currently undercuts.

## Findings (7 total · 3 high · 3 medium · 1 low)

- **F1 (high):** The job-queue holds accepted-but-undispatched jobs in process memory; on the "unattended OS updates and the occasional power blip" the LLD itself names, those jobs are lost and must be resubmitted by a member who, per the goal, isn't present — this defeats the tenet *"a submitted job is a promise: upload and walk away"* and the goal *"overnight print… with no member present"* · *tenets/goals must hold through the leaf designs — a mechanism that defeats one under a described condition is drift*
- **F2 (high):** Every spec is marked `[x]` (done), but the repo has no Tests or Code phase at all — the arrow is truncated above its two lowest levels, so tests-first and spec↔code coherence can't be verified · *tests before code; canonical arrow shape*
- **F3 (high):** Behaviors described in the job-queue LLD have no EARS spec — the two-priority-class/FIFO ordering, and "a job is accepted only if its target class has a registered printer" — so that intent is unnamed and nothing can test against it · *effective intent-tree alignment — LLD behaviors should have specs*
- **F4 (medium):** The choice to keep the queue in volatile memory (lost on restart) isn't in job-queue's Decisions & Alternatives, yet a cold reader would question it against the walk-away promise · *docs carry current intent — a live, contestable decision needs a Decisions row*
- **F5 (medium):** Two of the HLD's three tenets aren't forward-leaning tie-breakers — *"no silent reordering"* is a rule already fixed as spec QUEUE-005, and *"a submitted job is a promise"* reads as a goal/value; only *"the service stays small"* is a true lean · *tenets capture forward-looking preference, not values or spec-shaped rules*
- **F6 (medium):** QUEUE-002's "the head job of that printer's class" overloads *class* (printer class vs. the staff/member priority classes) and doesn't encode the priority ordering, so two agents could reasonably implement different dispatch orders · *LLDs close enough of the solution space; scope disambiguation*
- **F7 (low):** The three tenets are an unordered list though they can conflict (keep-the-promise vs. stay-small) — ordering states which wins · *tenets capture forward-looking preference — order them when they can conflict*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design LLDs and both spec files under `docs/intent/`
- Enumerated: 2 design nodes (job-queue, printer-registry), 2 spec files, 8 EARS specs (QUEUE-001–005, REG-001–003)
- Arrow overlay: none (`docs/arrows/` absent) — structural coherence not independently cross-checked
- Code/test linkage: no source or test files present, so no `@spec` annotations to sample
- Config: LID directive present, Mode: Full, Version 1.4.0 — fully configured

---

Want me to walk through any of these in detail, focus on a theme or priority (the tenet/durability conflict in F1 is the one I'd start with), or work through specific items together? Pick a finding and I'll go deep.

If you have broader questions about using LID on printfarm — when to author the Tests/Code phases, whether to add the `/arrow-maintenance` overlay as the farm grows, or how status markers like `[x]` should track against real code — I'm glad to help with those too.