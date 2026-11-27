# LID Coach: printfarm

## Executive summary

**Posture:** Clean, well-shaped design tree, with one design choice pulling against a tenet and the arrow stopping at specs.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, with no schemas or signatures creeping in
- ✓ Linkage and spec form — all 8 specs are well-formed EARS with unique IDs, and both prefixes (`QUEUE`, `REG`) resolve to their design docs
- ✓ Mutation hygiene — no changelog residue, obsolete markers or "as discussed" language
- ⚠ Tenet cascade and decision capture — the job-queue's in-memory queue works against "a submitted job is a promise", and that choice has no Decisions row
- ⚠ LLD ↔ spec coherence — some behaviours are designed but not specced, and one is specced but not designed
- ✗ Arrow completeness — every spec is marked `[x]`, but the repo has no tests, code or `@spec` annotations

**Headline:** The design layer is in good shape: one node per component, a lean HLD, and Decisions rows that name the rejected alternative and the accepted cost (the FIFO and slug rows are good models). The most valuable next step is to settle whether accepted jobs may be lost on restart, since that mechanism currently pulls against your first tenet and first goal.

## Findings (10 total · 3 high · 5 medium · 2 low)

- **F1 (high):** The job-queue holds accepted jobs "entirely in process memory", so undispatched jobs vanish on restart. The same doc says the mini-PC takes unattended OS updates and power blips, so an evening upload can disappear overnight with nobody there to resubmit. · *tenet cascade* — leaf designs should lean the way the HLD's tenets ("a submitted job is a promise") and goals ("no member present") say to lean.
- **F2 (high):** The in-memory queue choice appears only in Architecture prose, with no Decisions & Alternatives row. A cold reader can't tell what was weighed (perhaps "the service stays small"?) or what cost was knowingly accepted. · *decision capture* — a choice a reader would still question needs its trade-off on the page.
- **F3 (high):** All 8 specs carry `[x]`, yet the repo contains only docs. If the implementation lives elsewhere, say so in `CLAUDE.md`; if it doesn't exist yet, consider resetting the markers. · *canonical arrow shape* — HLD → LLD → EARS → tests → code, with each phase present and findable.
- **F4 (medium):** `QUEUE-005` (visible record of staff reordering) has no design behind it. The LLD says only that staff reorder; it doesn't say how reordering interacts with the two priority classes or what the "record" is. · *LLDs close enough of the solution space* — two agents should land on compatible implementations.
- **F5 (medium):** Several designed behaviours have no spec, so nothing will test them. These are the registered-printer acceptance rule, staff-before-member ordering, FIFO within a class, the loss of undispatched jobs on restart, slug recycling, and printer registration (REG covers retiring only). · *effective intent-tree alignment* — LLD behaviour without a spec is unnamed intent that drifts silently.
- **F6 (medium):** The job-queue marks a printer "suspect" (`QUEUE-003`), but printer state belongs to the registry, whose design knows only unreachable, idle and busy. What "suspect" means, who clears it and whether it blocks dispatch is not stated. · *intent attaches at the lowest node that dominates it* — a printer state belongs in the registry, with the queue referencing it.
- **F7 (medium):** "Idle" is never defined against a finished part still on the bed. As written, `QUEUE-002` dispatches the next job the moment a print ends, overnight with no one there to clear it. · *LLDs close enough of the solution space*.
- **F8 (medium):** Job slugs "recycle after 90 days", but the queue lives only in memory. A cold reader can't tell where slug history is kept, or whether a restart resets it. · *docs carry current intent, written to be read cold* — the doc must stand without the conversation that produced it.
- **F9 (low):** The three tenets are unordered, and F1 is the case where two of them collide ("a job is a promise" against "the service stays small"). Consider ranking them so the next session knows which wins. · *tenets capture forward-looking preference* — tie-breakers need an order when they can conflict.
- **F10 (low):** The HLD's Approach names a member/staff web UI, but the Architecture lists only two nodes. Consider either a UI node or a line saying which node owns the UI's behaviour. · *one LLD per intent component* — each "thing" a user would name has a home.

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- **Enumerated:** 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`) and 5 Decisions rows.
- **Code and tests:** none in the repo, and 0 `@spec` references, so tests-first evidence, annotation placement and code legibility could not be assessed.
- **Configuration:** `CLAUDE.md` has the LID directive and Full mode; there is no arrow overlay (`docs/arrows/`). Full mode fits a two-node project.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into; F1 and F2 are the natural starting pair.

If you have broader questions about using LID for this project — where a UI node fits, how to stage tests and code from existing specs, or when a node should split — I can help with those too.