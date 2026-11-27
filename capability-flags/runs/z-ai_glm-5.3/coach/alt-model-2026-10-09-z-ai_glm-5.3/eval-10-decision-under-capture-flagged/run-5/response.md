# LID Coach review — Field Notes

**Posture:** *Bootstrapping — the arrow is in place and the docs are clean, but the sync segment's status markers and its core conflict decision contradict the project's own words.*

**Scorecard**
- ✓ Configuration — `## LID` block well-formed; Full mode fits this whole-repo, docs-first project
- ✓ Mutation hygiene — every doc reads as if authored fresh today; no residue or history
- ✓ Tenet quality — "Boring over clever" is a real tie-breaker with a defensible opposite
- ✗ Status coherence — both specs claim implementation; the repo contains no code or tests
- ⚠ Tenet cascade — the conflict mechanism rests on the very input the LLD documents as unreliable
- ⚠ LLD coverage & sufficiency — half the HLD's architecture has no design node, and the return half of "reconcile" is an open edge

**Headline:** The configuration, doc hygiene, and linkage are genuinely solid — the arrow walks from HLD to spec IDs in a single grep, and the docs carry zero residue. The most valuable next step is to make the sync design tell the truth about itself: re-decide (or explicitly justify) the wall-clock tiebreaker against the clock skew your own Context documents, and flip the two false `[x]` markers.

**Findings (5 total · 2 high · 3 medium · 0 low)**
- **F1 (high):** The conflict design defeats the "Convergent state after reconnect" goal under its own described conditions — the LLD Context says device clocks are "frequently wrong by several minutes" during offline periods (`sync-design.md:9`), yet the tiebreaker is "later device wall-clock timestamp wins" (`sync-design.md:17`, codified as SYNC-002); with skewed clocks the *earlier* edit can win and the newer edit is silently discarded. · *Tenet cascade — a design's mechanisms must not work against the HLD's own goals under operating conditions the docs themselves describe.* Note the "Boring over clever" tenet is satisfied but beside the point: this is the boring choice that is also unreliable under the stated constraint.
- **F2 (high):** Both specs are marked `[x]` — "implemented: code and tests exist" — but the repo has no code or tests at all; with no `docs/arrows/` overlay, these markers are the project's *only* status signal, so every future session reading `sync-specs.md` inherits a false foundation. · *Coherence is adjacency — each level of the arrow must agree with its adjacent level.*
- **F3 (medium):** The conflict-resolution row's rationale is "Simpler." — no alternative named, no cost recorded. A cold reader holding the clock-skew Context would question the choice and cannot reconstruct what was given up. Consider a fuller row (e.g., server-assigned ordering, logical clocks) naming the accepted cost — or a decision doc if this one warrants debate on the record. · *Decision capture (docs carry current intent) — a live decision needs its reasoning on the page, not just the choice.*
- **F4 (medium):** The device-local note store — the HLD's first-listed architecture concept and the thing the "No blocked capture" goal depends on — has no design node; its one decision (SQLite) sits in the sync LLD's table by default, though it plausibly governs capture too. Consider a `device-store` LLD to own it, or a line in the sync LLD stating where capture-side design will live. · *One LLD per intent component — each thing a user would describe as "a thing" gets its own node.*
- **F5 (medium):** Reconciliation is specified one-way (device → service): SYNC-001 covers upload, SYNC-002 covers conflict, but nothing covers returning the merged canonical state to devices — the edge the convergence goal implies. Two reasonable agents could land on incompatible answers here. · *LLDs close enough of the solution space — under-specified edges are where intent drift enters, session after session.*

**What was audited**
- Read fully: the entire repository — `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` (4 files; no code or test files exist to sample)
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 0 `@spec` annotations, 0 tests; no `docs/arrows/` overlay
- Exhaustive read (no sampling needed at this size); cold-read pass and Decisions-table sweep run over every LID doc; conventions checked against the linked-intent-dev skill's EARS syntax and LLD template references

**Run notes (non-interactive defaults taken):** Mode Full is explicitly declared in `CLAUDE.md`, so dispatch proceeded on the declared full review (no default needed); the report is rendered inline rather than persisted (the skill's default); no other user-choice points arose. The capability-flags reference lists no flagged configurations, so no second-look note applies. Per the skill's advisory posture I made no file changes — apply fixes directly, via `/update-lid` for configuration changes, or `/arrow-maintenance` for structural enumeration (not warranted at this size).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for this project — where the device-store LLD should sit, how to phase tests-first onto the sync specs, mode transitions, what to do when a segment grows too large — I can help with those too.