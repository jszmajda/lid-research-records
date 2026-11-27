# LID Coach — Visit Planner

**Healthy design-stage arrow — coherent and cold-readable; implementation not yet begun.**

**Scorecard**
- ✓ Tenets — four real tie-breakers (defensible opposites, leans rather than triggered rules)
- ✓ Mutation hygiene — every doc reads as authored fresh today; no history or planning residue
- ✓ HLD discipline — architecture and rationale only; no implementation detail bleeding upstream
- ⚠ Tenet cascade — one mechanism works against a stated tenet, unrecorded (F1)
- ⚠ Decision capture — the short-notice design's load-bearing choices have no paper trail (F3)
- ⚠ Configuration — the instruction file has the mode marker but no LID directives (F2)

The design tree is tight — disciplined EARS, real tenets, zero residue across only five files. The most valuable next step is resolving the short-notice path's tension with "First asked, first served" before code locks it in, alongside a `/update-lid` pass to restore the directive block.

**Findings (10 total · 2 high · 3 medium · 5 low)**
- **F1 (high):** The short-notice claim window (fulfillment-design.md:9, FILL-004) lets a later — or nonexistent — request beat an earlier interest entry while the 20-minute scan pends · *tenet cascade* (leaf mechanisms must lean the way the HLD's tenets say) — the tenet is absolute ("an earlier request is never passed by one made after it"), and nothing records this trade; the design and the tenet will fight at implementation time if the speed-over-fairness choice isn't captured deliberately.
- **F2 (high):** CLAUDE.md carries the `## LID` mode marker but no directive block — no mention of linked-intent-dev, no instruction to walk the arrow; a cold agent landing here wouldn't know LID is in force · *modes are declared, not inferred* — recommend `/update-lid` to reconcile.
- **F3 (medium):** The 36-hour threshold, 20-minute claim window, and two-hour offer are the design's most question-provoking choices yet have no Decisions rows — a cold reader can't reconstruct why short-notice abandons queue order, or why these values · *decision capture* (from *docs carry current intent* — choices a cold reader would still question need their reasoning on the page).
- **F4 (medium):** "Compatible" is the core matching predicate but no doc or spec defines its inputs (service? site? window? accessibility?), and the HLD's "clinical compatibility" doesn't narrow it; "exact retry" semantics (same key, different payload?) are likewise open · *LLDs close enough of the solution space* — open edges are exactly where intent drift enters, session by session.
- **F5 (medium):** All 15 specs are `[x]`-checked while the repo contains zero code or tests, and the convention is defined nowhere · *minimum surface, maximum discipline* — a cold reader can't tell whether the marker claims implementation or authorship, and if it claims implementation it's a false signal today.
- **F6 (low):** The `FILL` prefix doesn't echo its "Fulfillment" component the way `INTAKE` echoes "Intake" — if a rename to `FULFILLMENT-*` is wanted, now (nothing references the IDs yet) is the cheapest it will ever be · *specs are grep-anchored linkage*.
- **F7 (low):** The two-hour offer TTL lives only in the fulfillment LLD; no spec fixes offer duration, so a future test has nothing to cite · *effective intent-tree alignment* (an LLD behavior with no spec).
- **F8 (low):** The HLD carries no non-goals or success metrics — e.g., whether urgent/non-routine care is out of scope is left to reader inference · *HLD is architecture and rationale*.
- **F9 (low):** The fulfillment LLD introduces "the matcher" and "registry scan" without a defining phrase; one clause each would remove the guesswork · *docs carry current intent, written to be read cold*.
- **F10 (low):** INTAKE-001's "an authenticated account submits" doesn't say whether staff acting for a caller is the same path (whose account authenticates?) · *scope disambiguation*.

**What was audited**
- Read fully: the entire repository — CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files (5 files)
- Enumerated: 2 LLDs, 15 EARS specs (7 INTAKE, 8 FILL); all IDs unique and EARS-conformant
- Code/test sampling: none possible — no source or test files exist yet, so `@spec` linkage, tests-first, and semantic-legibility dimensions couldn't be exercised; worth a re-run once implementation starts
- No `docs/arrows/` overlay present, so no index-guided sampling applied

**Defaults taken (non-interactive run):** the instruction file lacks LID directives while the project is clearly LID-shaped, so per the skill's dispatch table I proceeded with a full review anchored on the existing artifacts at the default Full mode rather than stopping at a configuration complaint; the review is advisory per the skill's posture, so no files were edited; and the run stops at this report per the skill's "the coach does not iterate."

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F1 especially — to dig into.

If you have broader questions about using LID on this project — when to add the arrow overlay, how to structure the first tests-first pass, or mode transitions — I can help with those too.