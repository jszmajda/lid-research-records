# LID Coach Review — Visit Planner

**Posture:** Solid design foundation; configuration and eligibility edges need tightening.

**Scorecard**
- ✓ Tenet quality — four real tie-breakers, each with a defensible opposite; no platitudes
- ✓ Mutation hygiene — no history residue, changelog leftover, or conversational fossils; the docs read clean cold
- ⚠ Configuration — mode marker present, but the instruction file carries no LID directives
- ✗ LLD sufficiency — "compatible" and "eligible" are never defined; intake's status lifecycle is implicit
- ⚠ Tenet cascade — near-term checkout tensions against first-asked-first-served with no recorded exception
- ⚠ Cascade — the two-hour offer window exists only in LLD prose, not in any spec

**Headline:** The design layer is real and tight — two intent components mirroring the HLD's component list, 15 EARS specs that map cleanly onto design prose, and Decisions tables that record rejected alternatives and accepted costs on every row; the fastest wins are reconciling the instruction file via `/update-lid` and pinning down what "compatible/eligible" means before any code exists.

**Findings (7 total · 3 high · 3 medium · 1 low)**
- **F1 (high):** CLAUDE.md declares `- Mode: Full` but carries no linked-intent-dev directives, so nothing tells a fresh session to consult intent before code · *intent leads; code is compiled output* (specs are the source of truth; run `/update-lid` to reconcile) —
- **F2 (high):** "Compatible" and "eligible" are never defined — clinical fit, patient constraints, claim eligibility, intake's "complete preferences," and the entry `status` lifecycle all left open · *LLDs close enough of the solution space* (open edges are where each new session invents its own rules)
- **F3 (high):** near-term checkout (FILL-004) lets a later request win an opening an earlier interest entry was waiting for, against the tenet "an earlier request is never passed"; no Decisions row records the exception · *tenets capture forward-looking preference* (unrecorded exceptions leave future agents guessing which way to lean)
- **F4 (medium):** the HLD Approach promises staff acting for patients and a normalized openings view; no LLD or spec owns either · *effective intent-tree alignment* (every named capability should trace down the design tree)
- **F5 (medium):** the two-hour offer window lives only in `fulfillment-design.md` prose; no spec pins the TTL, so tests have nothing to cite · *cascade within a segment, pause across* (adjacent-level drift — LLD detail with no spec downstream)
- **F6 (medium):** every spec carries an `[x]` marker whose meaning is undefined — authored? approved? implemented? (there is no code) · *docs carry current intent, written to be read cold* (in-conversation-only meaning)
- **F7 (low):** the HLD has no non-goals or success metrics · *HLD is architecture and rationale* (a cold reader can't tell what's deliberately out of bounds)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all 4 files under `docs/intent/` (2 LLDs, 2 spec files)
- Enumerated: 2 LLDs, 15 unique spec IDs (INTAKE-001–007, FILL-001–008), 0 ID collisions
- Sampled code/tests: none exist — the repository contains only the instruction file and docs (0 files with `@spec` annotations; no `docs/arrows/` overlay, so the sampling reference was not engaged)
- Linkage metric: 15 spec IDs · 0 test citations · 0 code annotations; design↔spec adjacency checked line-by-line for both components
- Decisions sweep: all 8 table rows reviewed for cold-reader questionability — each reconstructs its rationale from the row and the docs above it; no decision-capture findings
- Defaults taken (non-interactive run): dispatched as *missing directives but LID-shaped* → full review at the declared Full mode; report rendered inline, not persisted to disk; no files edited (advisory posture); stopped after this report

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.