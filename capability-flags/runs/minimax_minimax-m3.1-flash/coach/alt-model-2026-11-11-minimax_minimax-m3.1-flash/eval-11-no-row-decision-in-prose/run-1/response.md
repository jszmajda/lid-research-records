# printfarm — LID Coach Report

**Posture:** Bootstrapping — the design layer is genuinely clean; the arrow stops at EARS.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schema or signature leakage
- ✓ EARS quality — every spec has a WHEN clause, unique IDs, correct `prefix:` alignment
- ✓ Mutation hygiene — no history residue, no obsolete markers, no stale `[inferred]` entries
- ⚠ Arrow completeness — no tests and no code exist; the arrow bottoms out at EARS
- ⚠ Intent-tree alignment — HLD names a component with no design node, and several LLD behaviors have no specs
- ⚠ Tenet quality — tenets read as values/goals rather than forward-looking tie-breakers

The design layer is well-formed and unusually clean for a young project; the fastest wins are closing the arrow below EARS and tightening the two places where the docs describe behavior nobody has captured.

**Findings (9 total · 3 high · 4 medium · 2 low)**
- **F1 (high):** the arrow has no test or code phase — the repository contains only docs, so no spec has a test citing it · *tests before code* / *tests carry `@spec` annotations*
- **F2 (high):** the in-memory queue drops accepted-but-undispatched jobs on restart (`docs/intent/job-queue/job-queue-design.md:14`), directly against the tenet "a submitted job is a promise" (`docs/high-level-design.md:20`), and no Decisions row records the trade · *tenet cascade* / *decision capture*
- **F3 (high):** the HLD gives members a web UI and staff a queue view (`docs/high-level-design.md:9`), but no design node owns the UI — `QUEUE-005` depends on a "queue view" that has no LLD · *effective intent-tree alignment*
- **F4 (medium):** LLD behaviors with no spec anywhere — acceptance requires a registered printer in the class (`job-queue-design.md:20`), G-code kept on disk under a content hash (`job-queue-design.md:14`), staff/member priority classes (`job-queue-design.md:25`), and printer registration (`printer-registry-design.md:10`) · *effective intent-tree alignment*
- **F5 (medium):** the three HLD tenets are stated as values and goals, not tie-breakers with defensible opposites, and are unordered even though "keep the service small" and "the queue explains itself" can pull against each other · *tenets capture forward-looking preference*
- **F6 (medium):** spec status markers have no legend — every spec is `[x]` while nothing is implemented, so a cold reader cannot tell whether `[x]` means accepted, verified, or built · *docs carry current intent*
- **F7 (medium):** the "three missed heartbeats" threshold (≈45 s to mark unreachable) lives only in prose (`printer-registry-design.md:18`) and never gets a Decisions row, unlike the interval beside it · *decision capture*
- **F8 (low):** `job-queue` bundles upload acceptance, dispatch/retry, prioritization, and upload storage in one node — consider whether upload handling promotes to a sub-HLD with a child LLD · *one LLD per intent component — or split into a sub-HLD when it outgrows one node*
- **F9 (low):** "Six printers today" (`printer-registry-design.md:10`) is a snapshot that ages into residue; a current fact belongs in present tense without the temporal marker · *docs carry current intent*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/`
- Enumerated: 2 design nodes, 2 spec files, 8 spec IDs (`QUEUE-001`–`005`, `REG-001`–`003`), 0 collisions, 0 `[inferred]`, 0 `[obsolete]`
- Code/test sample: the full tree — 0 source files, 0 test files, 0 `@spec` annotations (single-commit repo, so no history to sample)
- Arrow overlay: none installed (`docs/arrows/index.yaml` absent), so no index or segment coverage was available
- Cold-read pass: every LID doc read with no conversational context; findings F2, F3, F6, F9 surfaced there

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.