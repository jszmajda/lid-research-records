**LID Coach — Visit Planner**

## Executive summary

**Posture:** Bootstrapping — design layer is real and unusually clean; the arrow stops short of tests and code, and one tenet is quietly contradicted.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no `[inferred]` backlog
- ⚠ Configuration — the `## LID` block declares Mode and Version but carries no linked-intent-dev directive
- ✗ Arrow completeness — `HLD → LLDs → EARS` is in place; Tests and Code phases are absent while all 15 specs read as done
- ⚠ LLD sufficiency — "compatible" and "eligible" are the open edges in Fulfillment
- ⚠ Tenet cascade — the sub-36-hour open-search path cuts against *first asked, first served*

**Headline:** Two components, four well-formed tenets, 15 EARS specs that actually read like EARS, and Decisions & Alternatives tables with real accepted-cost columns — this is a better-shaped design layer than most projects have at this stage. The highest-value next steps are reconciling the tenet conflict in the fast-cancellation path and deciding whether the `[x]` markers mean "specified" or "built," because right now the arrow has no downstream half.

## Findings (11 total · 5 high · 4 medium · 2 low)

- **F1 (high):** `CLAUDE.md` declares `## LID` / `Mode: Full` / `Version: 1.4.0` but has no linked-intent-dev directive block — run `/update-lid` to reconcile · *modes are declared, not inferred* (an unread mode is a default, and cascade rigor keys off it)
- **F2 (high):** FILL-003/FILL-004 publish a ≤36-hour opening to open portal search where any eligible signed-in account may check out, which can pass over an earlier `enteredAt` entry; no Decisions row names the tenet traded · *tenets capture forward-looking preference* (a tenet contradicted without a recorded exception stops being a tie-breaker)
- **F3 (high):** the dual-path split itself — the 36-hour threshold, the 20-minute scan delay, the two-hour offer — is the load-bearing choice in `fulfillment-design.md` and has no Decisions row; a cold reader cannot reconstruct what was given up · *docs carry current intent, written to be read cold*
- **F4 (high):** "compatible active entries" and "eligible signed-in account" are never defined against Intake's service / sites / time window / accessibility fields; two agents would implement different matchers · *LLDs close enough of the solution space*
- **F5 (high):** no tests, no code, no `@spec` annotations anywhere, yet all 15 specs carry `[x]` · *canonical arrow shape* and *coherence is adjacency* (status markers that outrun the arrow make every later coherence check unreliable)
- **F6 (medium):** the HLD's "staff may act for patients who call" path has no design or spec; INTAKE-001 reads as an account submitting for itself · *effective intent-tree alignment*
- **F7 (medium):** the goal "give staff a traceable explanation for every confirmation, expiry, and withdrawal" has write-side specs (FILL-008, INTAKE-007) but no read path designed or specified · *effective intent-tree alignment*
- **F8 (medium):** neither spec file declares `prefix:` frontmatter, so `FILL-` → `fulfillment` leaf is inferred from the directory name alone · *specs are grep-anchored linkage*
- **F9 (medium):** Intake's Decisions table accepts "keys require expiry state" as a cost, but no spec or design text says how long an idempotency key lives or what a post-expiry retry does · *LLDs close enough of the solution space*
- **F10 (low):** four tenets, unordered, where *first asked, first served* and the goal of refilling quickly pull in opposite directions in exactly the fast-cancellation case · *tenets capture forward-looking preference*
- **F11 (low):** the two-hour offer window exists only in Fulfillment's design prose; FILL-002 fixes expiry behavior without the duration · *coherence is adjacency*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` (6 files, the entire repo)
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 15 EARS specs (7 `INTAKE-`, 8 `FILL-`), 2 arrow segments
- Arrow-path sampled: both segments walked HLD section → LLD → spec; both terminate at EARS
- Linkage metric: 0 `@spec` annotations, 0 test files, 0 non-markdown files
- Overlay: `docs/arrows/` absent, so no `index.yaml` to cross-check; structural enumeration via `/arrow-maintenance` isn't available until the overlay is installed
- Cold-read pass: all four LID docs; they stand on their own well — the gaps found are unwritten parameters and definitions, not conversational residue
- Non-interactive run: no dispatch prompt arose, and the declared `Mode: Full` was honored, so no out-of-scope section applies

Want me to walk through the findings in detail, focus on a theme or priority (the tenet conflict in F2/F3 is where I'd start), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — when to install the arrow overlay, how to get tests leading code from here, what the `[x]` markers should mean before implementation exists, or whether Fulfillment's two paths want to become sibling leaves under a sub-HLD — I can help with those too.