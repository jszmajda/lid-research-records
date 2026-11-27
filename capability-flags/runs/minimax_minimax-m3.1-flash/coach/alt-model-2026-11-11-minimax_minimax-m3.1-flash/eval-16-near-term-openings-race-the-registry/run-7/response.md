# LID Coach — Visit Planner

## Executive summary

**Posture:** Bootstrapping — the arrow reaches EARS, but nothing downstream of it exists.

**Scorecard**
- ✓ Intent quality — four genuine tie-breaker tenets, no history residue in any doc
- ⚠ Decision capture — the load-bearing constants and trade-offs live only in chat
- ⚠ LLD sufficiency — the matching predicate, staff flows, and offer length are unstated
- ⚠ Cascade — LLD and specs are coherent where both exist; nothing cascades past EARS
- ✗ Linkage — 15 spec IDs, zero `@spec` annotations, zero tests
- ⚠ Configuration — mode is declared, the directive block is not

**Headline:** The design layer is genuinely good — a clean HLD, two coherent leaf LLDs, uniquely-namespaced EARS, and tenets that real tie-breakers — but the arrow stops at the spec layer while every spec is already marked complete, so nothing in the repository currently verifies the behavior the docs describe. The fastest wins are a decision-capture pass on the constants that drive the core flow, and honest status markers until tests exist.

## Findings (16 total · 4 high · 8 medium · 4 low)

- **F1 (high):** the arrow terminates at EARS — all 15 specs are marked `[x]` complete, but the repo contains no tests and no code · *canonical arrow shape* (phases collapsed) + *tests before code*
- **F2 (high):** zero `@spec` annotations anywhere — 15 spec IDs are linked to nothing, so no agent can walk spec → test → code · *specs are grep-anchored linkage* + *tests carry `@spec` annotations*
- **F3 (high):** the 36-hour threshold and 20-minute scan delay govern the core flow, but neither has a rationale or accepted cost in any Decisions table · *decision capture*
- **F4 (high):** near-term openings let any eligible signed-in account claim through checkout ahead of earlier-asked entries, against the "First asked, first served" tenet, with no recorded exception · *tenet cascade* + *decision capture*
- **F5 (medium):** the instruction file declares `## LID` / `- Mode: Full` but carries no LID directive block (no `linked-intent-dev` reference) — worth reconciling via `/update-lid` · *modes are declared, not inferred*
- **F6 (medium):** "compatible" is never defined — INTAKE-002 defers validity to it and FILL-001/005 order on it, so the central matching predicate is open · *LLDs close enough of the solution space*
- **F7 (medium):** `fulfillment-design.md` bundles two separable behaviors (>36h offer flow vs ≤36h publish/scan/claim flow) that share an ownership model but diverge in trigger and lifecycle — a sub-HLD candidate · *one LLD per intent component*
- **F8 (medium):** undefined vocabulary a cold reader cannot resolve: matcher, registry scan, searchable, offer, claim, outbox, compatible, eligible · *docs carry current intent, written to be read cold*
- **F9 (medium):** the HLD declares staff as a second actor and a goal of traceable staff explanations, but no LLD or spec covers a staff workflow · *effective intent-tree alignment*
- **F10 (medium):** the Intake Decisions table accepts "keys require expiry state" and "additional storage and compaction", yet key lifetime and intake event history are specified nowhere · *decision capture* + *LLD sufficiency*
- **F11 (medium):** the two-hour offer duration appears only in LLD prose — no spec states offer length or what an offer grants the patient · *coherence is adjacency*
- **F12 (medium):** the HLD's Approach never mentions the two-tier near/far horizon policy; the most consequential architectural behavior lives only in the leaf LLD · *HLD is architecture and rationale*
- **F13 (low):** spec prefix `FILL` doesn't echo its leaf node "Fulfillment" the way `INTAKE` echoes "Intake" · *effective intent-tree alignment*
- **F14 (low):** INTAKE-006's "newly timed entry" has no counterpart in the LLD's "creates a new one" — a cold reader can't tell whether the queue position resets · *LLDs close enough of the solution space*
- **F15 (low):** the Intake LLD specifies event-appending only for withdrawal, while the History row implies append-only history for every mutation · *effective intent-tree alignment*
- **F16 (low):** no `docs/arrows/` overlay is installed, so the structural enumeration behind the linkage findings isn't available to `/arrow-maintenance` yet · *coherence is adjacency* (coverage note)

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/{intake-design,intake-specs}.md`, `docs/intent/fulfillment/{fulfillment-design,fulfillment-specs}.md` — that is every LID document in the repository
- Enumerated: 2 LLDs, 2 spec files, 15 spec IDs (`INTAKE-001`–`007`, `FILL-001`–`008`), zero ID collisions, zero reused IDs, all zero-padded and namespaced
- Sampled: the entire repository (6 tracked files, 1 commit) — there are no code or test files, so the code/test sampling produced 0 `@spec` annotations and 0 test citations to assess
- Cold-read pass: every LID doc read with no conversational context; findings F3, F4, F8, F9, F12, F14, F15 came out of that pass
- Overlay: `docs/arrows/` absent — no arrow-path traversal possible

## Notes on this run

Defaults taken, per the skill's stated defaults under a non-interactive run: the project was treated as **Full mode** (the `## LID` block declares it) and reviewed in full; the missing LID directive block in `CLAUDE.md` is reported as a finding recommending `/update-lid` rather than applied; the report is **rendered inline and not persisted**, and no project files were edited, because the coach's advisory posture reserves application of changes for you. Structural precision for F2/F16 would come from `/arrow-maintenance` once the overlay is installed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.