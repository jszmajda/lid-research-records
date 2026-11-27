# printfarm — LID Coach Review

## Executive summary

**Posture:** Bootstrapping — design layer authored, coherent, and clean; one tenet conflict to resolve before implementation starts.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no implementation detail bleeding upstream
- ✓ LLD granularity — one design node per component, matching the HLD's two architecture nodes
- ✓ Mutation hygiene — no history residue, planning text, or obsolete markers; every doc reads as authored fresh
- ✓ Linkage — spec IDs (`QUEUE-###`, `REG-###`) unique, grep-friendly, prefixes match LLD frontmatter
- ⚠ Tenet cascade — one design choice works against a core tenet under conditions the docs themselves describe
- ⚠ Spec coverage — a few LLD-described behaviors have no EARS spec

**Headline:** The design layer is in genuinely good shape for a young project — a tight HLD, two well-scoped LLDs, and tidy specs that trace cleanly. The single most valuable next step is to reconcile the in-memory queue with the "a submitted job is a promise" tenet (F1) and record the outcome, before tests and code exist to encode the drift.

## Findings (7 total · 1 high · 5 medium · 1 low)

- **F1 (high):** job-queue holds accepted jobs entirely in process memory, so jobs accepted but undispatched are lost on restart — while its own Context names unattended OS updates and power blips, and the HLD's tenet says "a submitted job is a promise: members should be able to upload and walk away" · *tenet cascade — each design node should lean the way the HLD's tenets and goals say to lean; under the docs' own described conditions (evening upload → overnight blip → no part in the morning) this defeats the tenet, and no Decisions row records an exception naming the tradeoff*
- **F2 (medium):** the durability choice has no Decisions & Alternatives row — a cold reader would question why the staff-facing registry survives restarts (SQLite) while the member-facing promise doesn't · *decision capture (docs carry current intent) — a choice a cold reader would still question needs its reasoning on the page, or every future session re-derives or contradicts it*
- **F3 (medium):** three described behaviors have no EARS spec: staff-over-member prioritization with FIFO within class, and the "class must have a registered printer" acceptance rule (job-queue), plus staff printer registration (printer-registry Context — only retirement has a spec) · *effective intent-tree alignment — LLD behaviors with no spec are unnamed intent that drifts silently because there's nothing to test against*
- **F4 (medium):** QUEUE-003 introduces a "suspect" printer state the registry LLD knows nothing about — printer state semantics are registry-owned, so this either belongs in printer-registry or needs a clarifying note that suspicion is queue-local · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across — substance that governs a sibling's state should rise to (or be coordinated with) the node that owns it*
- **F5 (medium):** "slugs recycle after 90 days" implies durable slug state, but the queue is held entirely in memory — the 90-day clock has no substrate a cold reader can find · *LLDs close enough of the solution space — under-specified edges get filled in by whoever implements, which is where intent drift enters*
- **F6 (medium):** all eight specs carry `[x]` status markers with no tests or code in the repo and no stated meaning for the marker — a cold reader can't tell what "done" claims here · *docs carry current intent, written to be read cold — state what's true today, and define the marker so future sessions aren't left guessing*
- **F7 (low):** the HLD's tenets are an unordered list while tenet 1 (the promise) and tenet 3 (stays small) can conflict — exactly the tension the in-memory choice quietly resolved toward tenet 3 · *tenets capture forward-looking preference — when tenets could conflict, order (or annotate) them so the lean is pre-narrowed rather than sampled*

## What was audited

- Read fully: every LID doc in the repo — CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files
- Enumerated: 2 design nodes, 8 EARS specs (5 `QUEUE`, 3 `REG`), 5 Decisions & Alternatives rows
- Sampled: no code or tests to sample — implementation hasn't started (noted, not flagged; tests-first with `@spec` annotations attaches at implementation kickoff)
- Overlay: no `docs/arrows/` directory present

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into — F1 and F2 resolve together, and I can help you weigh the durability options against tenet 3.

If you have broader questions about using LID for this project — how the tests-first phase will pick up these eight specs, when a `docs/arrows/` overlay would start paying for itself, or how to record a decision like F1/F2 properly — I can help with those too.