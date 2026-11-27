# LID Coach — Shelfwise

**Posture: Strong intent layer; the arrow stops at specs, and one tenet is out of step with the design that cites the tenets around it.**

**Scorecard**
- ✓ Mutation hygiene — no changelog residue, obsolete markers, or conversational leftovers anywhere; the docs read cold
- ✓ Spec quality — clean EARS phrasing, unique zero-padded IDs, WHEN clauses that would survive a second variant
- ✓ Decision capture — six of seven Decisions rows name the rejected alternative and the accepted cost
- ⚠ Tenet coherence — the allocation design quietly contradicts the first tenet, and the choice has no Decisions row
- ⚠ Configuration — `CLAUDE.md` has the `## LID` mode block but no LID directive block
- ✗ Arrow completeness — every spec is marked `[x]`, yet no test or code phase exists in the repository

**Headline:** The design layer is in genuinely good shape — two well-scoped components, tight EARS specs, decision tables that mostly earn their keep, and zero accumulation — and the fastest win is reconciling branch-first allocation with the *"Waiting is honored in sequence"* tenet, then squaring the `[x]` spec markers with the missing test and code phases.

**Findings (7 total · 4 high · 1 medium · 2 low)**
- **F1 (high):** Branch-first allocation (`hold-allocation-design.md`) lengthens an older hold's wait in favor of a newer local one, in tension with the HLD tenet *"Waiting is honored in sequence"* · *coherence is adjacency* — each level of the arrow agrees with the one next to it
- **F2 (high):** The branch-priority-vs-strict-FIFO choice has no Decisions & Alternatives row — its rationale is one clause of body prose ("keeps most copies off the courier van") · *decision capture* — choices a cold reader would still question deserve a row naming what was given up
- **F3 (high):** All 13 specs are checked `[x]`, but the project contains no tests, no code, and no `@spec` annotations — the arrow's last two phases are absent or live somewhere undocumented · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, with deviations explicit
- **F4 (high):** `CLAUDE.md` carries the `## LID` mode block but not the linked-intent-dev directive block — run `/update-lid` to reconcile · *modes are declared, not inferred* — the instruction file is the foundation everything else keys off
- **F5 (medium):** Cancelling a hold while its copy sits `allocated` on a holds shelf is unspecified — the design covers only cancellation in transit, so two implementers would guess differently · *LLDs close enough of the solution space* — open edges are where drift enters
- **F6 (low):** The tenet *"Hold history is not kept"* ends in a triggered rule ("a closed hold's record is deleted") already fixed by PICKUP-003/005, and the four tenets are unordered although the first two can conflict (F1 is that conflict) · *tenets capture forward-looking preference* — tenets are tie-breaker leans, ordered when they can collide
- **F7 (low):** Neither leaf design declares `prefix:` frontmatter, so the PICKUP ↔ `pickup-notices` mapping rests on inference · *specs are grep-anchored linkage* — the leaf prefix is the arrow boundary, best declared rather than guessed

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (HOLDALLOC-001–007, PICKUP-001–006), 4 tenets, 7 Decisions rows
- Searched project-wide for test files, code files, and `@spec` annotations: none found (0 `@spec` references)
- No `docs/arrows/` overlay present, so no index-guided segment sampling was possible; the review covered every LID doc in full

**Worth a second look:** I couldn't load the capability-flags reference in this environment, so per its own default I treat its flags as applying to me — models in my class are known to miss designs that contradict a project's own tenets. F1 is one such catch, but please check both leaf designs against your HLD tenets yourself in case others slipped past.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F1's tenet-vs-routing tension is a good one to think through.

If you have broader questions about using LID for your project — where a PRD would fit upstream of the HLD, when Scoped mode makes sense, what to do when a component outgrows one LLD — I can help with those too.