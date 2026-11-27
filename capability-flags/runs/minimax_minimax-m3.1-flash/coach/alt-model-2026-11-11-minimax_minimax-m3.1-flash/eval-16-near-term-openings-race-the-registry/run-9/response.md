## Visit Planner — LID coaching review

### 1. Executive summary

**Posture:** *Solid design core, arrow truncated at the implementation end; one tenet conflict to resolve.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schema or signature leakage
- ✓ Tenets present — four real tie-breakers, mostly well-formed
- ✓ Mutation hygiene — docs read as current intent; no history residue or fossils
- ⚠ LLD sufficiency — two components, but the core matching predicate is undefined
- ⚠ Tenet cascade — the ≤36h checkout path runs against "First asked, first served"
- ⚠ Arrow completeness — HLD → LLD → EARS present; no tests, no code, yet every spec is marked done
- ✓ Mode fit — Full mode suits a two-component, project-wide design

**Headline:** The design layer is genuinely good — a clean HLD, two well-shaped LLDs, 15 grep-friendly, unique spec IDs and a healthy mutation posture. The fastest wins are capturing the reasoning behind the three magic time thresholds, resolving the checkout-vs-ordering tenet conflict, and deciding what "done" means on a spec with no implementation behind it.

### 2. Findings inventory

**Findings (14 total · 5 high · 6 medium · 3 low)**

- **F1 (high):** FILL-004 lets any eligible signed-in account claim a near-term opening, which a patient who asked earlier can lose — the mechanism works against the tenet *first asked, first served* (tenet cascade — tenets capture forward-looking preference). No Decisions row or doc records the exception.
- **F2 (high):** The 36-hour threshold, the 2-hour offer window, and the 20-minute scan delay in `fulfillment-design.md:7-9` carry no rationale — a cold reader will ask "why these numbers?" (decision capture — decisions stay live only if the reasoning is on the page).
- **F3 (high):** `CLAUDE.md` has the `## LID` mode marker but no directive block (no `linked-intent-dev` reference), so LID's workflow is configured by implication rather than declared (modes are declared, not inferred) — `/update-lid` reconciles this.
- **F4 (high):** The HLD describes "a normalized view of clinic openings" and lists openings as the domain, yet no LLD or spec segment owns them — `Intake` and `Fulfillment` assume openings exist (one LLD per intent component; effective intent-tree alignment).
- **F5 (high):** "Compatible", "eligible", and "clinical compatibility" are used to drive FILL-001/004/005/006 but are defined in neither LLD — the matching predicate is the missing link (LLDs close enough of the solution space).
- **F6 (medium):** No test or code phase exists, yet all 15 specs are marked `[x]` — consider whether that marker should assert *implemented* or *agreed* while the repo holds no implementation (canonical arrow shape; mutation, not accumulation).
- **F7 (medium):** The HLD says staff may act for patients who call, but no intake design or spec covers a staff-entered entry, its actor, or its effect on `enteredAt` and eligibility (effective intent-tree alignment).
- **F8 (medium):** Both Decisions tables give the rejected alternative and the accepted cost but never *why the alternative fails* — a cold reader can see what was given up but not reconstruct the trade (decision capture).
- **F9 (medium):** "Commit before communicating" is a triggered *when X, do Y* rule that FILL-007 already fixes — as a tenet it cannot break a tie (tenet quality — a tenet is a tie-breaker, not a spec).
- **F10 (medium):** FILL-003 publishes near-term openings to portal search with no stated compatibility filter, so an account that cannot take the opening may see it (tenet cascade — *clinical fit precedes utilization*). The claim-time recheck in FILL-006 prevents a wrong booking but not wasted effort.
- **F11 (medium):** The `Notifications | Transactional outbox` row reads as the native choice once FILL-007 landed — a decision that reads obvious after landing is accumulation, not live intent (docs carry current intent, keep-side ceiling).
- **F12 (low):** Undefined terms carried through the specs — "complete preferences" (INTAKE-001), "eligible signed-in account" (FILL-004), "compatible" (FILL-001) — each costs a future reader a spec lookup (semantic legibility as cheap linkage).
- **F13 (low):** INTAKE-006's "create a newly timed entry" is ambiguous next to the LLD's "closes the entry and creates a new one" (cold-read — docs carry current intent, written to be read cold).
- **F14 (low):** Minor naming/structure nits — the spec prefix `FILL` doesn't echo the LLD name `fulfillment`, and `docs/intent/` has no index to route a cold reader (semantic legibility).

### 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files (`intake-specs.md`, `fulfillment-specs.md`)
- Enumerated: 2 LLDs, 2 spec files, 15 spec IDs (8 `FILL-*`, 7 `INTAKE-*`) — all unique, grep-friendly, none reused
- Overlay: no `docs/arrows/` directory, no `index.yaml` — the arrow-maintenance overlay is not installed, so no structural enumeration was attempted (recommend `/arrow-maintenance` if you want orphan/reverse-orphan precision)
- Code and tests: none present — the repository contains 6 tracked files and a single commit, so the tests and code phases could not be sampled and `@spec` annotation placement could not be assessed
- Git history: one commit (`fixture`) — no commit ordering available to assess tests-first evidence

### 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for this project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken (non-interactive run):* proceeded with a Full-mode review anchored on the existing artifacts and treated the missing LID directive block as a finding (F3) rather than a blocker; recommended `/update-lid` for the configuration fix and `/arrow-maintenance` for any structural enumeration instead of attempting it here; made no file changes, per the skill's advisory posture; omitted the out-of-scope section because the project is in Full mode; applied the skill's default read-all-docs strategy rather than `references/sampling.md`, since the project is below the sampling thresholds and has no arrow overlay.