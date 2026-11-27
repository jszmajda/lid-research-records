**LID Coach review — Visit Planner**

**Posture:** Bootstrapping — the design layer is strong and unusually clean; one unrecorded tenet trade and a configuration gap are worth settling before code arrives.

**Scorecard**
- ✓ Tenet quality — four genuine tie-breakers (each has a defensible opposite), none are platitudes or spec-shaped rules
- ✗ Tenet cascade — the short-notice checkout path works against "First asked, first served" with no recorded exception
- ✓ HLD discipline — clean architecture prose; no schema or implementation bleed
- ⚠ Configuration — mode marker present, but the instruction file lacks the linked-intent-dev directive block
- ✓ Mutation hygiene — every doc reads as fresh intent; zero changelog residue, no obsolete markers
- ⚠ Spec status markers — all 15 specs marked `[x]` with no implementation and no stated meaning

**Headline:** What's working is substantial — tenets that actually narrow decisions, specs whose WHEN clauses scope the two fulfillment regimes cleanly, and docs that pass a cold read. The single most valuable next step is recording (or removing) the short-notice exception to first-asked-first-served before implementation hardens it.

---

**Findings (7 total · 2 high · 2 medium · 3 low)**

- **F1 (high):** CLAUDE.md carries the `## LID` block but no directive naming linked-intent-dev, so future sessions won't be routed to the workflow for code changes · *modes are declared, not inferred* — the instruction file is the foundation every session builds on; an unwritten directive is a default that silently skips the arrow. Recommend `/update-lid`.
- **F2 (high):** FILL-004's open checkout for published short-notice openings lets any eligible later-arriving account pass an earlier compatible entry — the mechanism defeats "First asked, first served" under a condition the docs themselves describe (cancellation ≤36h out, earlier compatible entry waiting), and no Decisions row names the tenet traded against · *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean) and *decision capture* (a choice a cold reader would question, surviving only in prose). If the rapid-fill trade is deliberate — and goal 2 ("refill canceled visits quickly") suggests it may be — a Decisions-table row naming the trade would make it intent; if not, the design contradicts the HLD.
- **F3 (medium):** all 15 specs carry `[x]` status markers while the repo contains no code or tests, and no doc says what `[x]` means here — a future session can't tell whether it means "implemented," "reviewed," or is template residue · *coherence is adjacency* (each level agrees with its neighbors). Consider defining the marker's meaning or removing it.
- **F4 (medium):** the HLD promises "a normalized view of clinic openings" and fulfillment-design relies on a "cancellation handler," but no component or LLD owns opening ingestion or cancellation detection — the seam is referenced everywhere and designed nowhere · *one LLD per intent component* (a behavior with no owner is unnamed intent that drifts silently). Consider a third LLD/component entry, or an explicit non-goal.
- **F5 (low):** the HLD has no non-goals or success metrics; non-goals would also settle F4's boundary (is calendar ingestion in scope?) · *HLD is architecture and rationale* — non-goals outlive any implementation and pre-answer the scope questions a future session meets cold.
- **F6 (low):** open solution edges: the idempotency-key expiry lifecycle is named as an accepted cost but never designed; whether an active offer closes open claiming on a published opening is unspecified; the actor model for staff-assisted submission (whose account authenticates, how actor is attributed) is unresolved · *LLDs close enough of the solution space* — open edges are where two reasonable agents land incompatible implementations.
- **F7 (low):** the load-bearing tunables (36-hour regime split, 20-minute scan delay, 2-hour offer) and INTAKE-006's queue-position reset on service change carry no recorded rationale; terse Decisions rows citing each parameter's source would pin them · *decision capture*.

---

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files — the repository's entire content (6 files).
- The repo contains no code or test files, so the review covers the documentation arrow (HLD → LLDs → EARS); tests-first, `@spec` placement, and semantic-legibility dimensions had nothing to sample.
- Enumerated: 15 unique spec IDs (INTAKE-001–007, FILL-001–008), zero collisions; 2 LLDs matching the HLD's 2 components; no arrow overlay (`docs/arrows/` absent).

---

**Defaults taken in this run (non-interactive):** (1) Per the dispatch table, the instruction file lacks the linked-intent-dev directives while the project is clearly LID-shaped, so I proceeded with a full review anchored on the existing artifacts in the default Full mode; (2) lid-coach is advisory by design, so no files were edited — recommendations point at `/update-lid` (F1) and direct edits (F2–F7); (3) the report renders inline rather than persisted to disk.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F2 is the one I'd dig into first.

If you have broader questions about using LID for this project — where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.