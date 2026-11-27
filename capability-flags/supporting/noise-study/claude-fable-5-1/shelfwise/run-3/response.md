**LID Coach — Shelfwise**

**Posture:** Bootstrapping — design layer in place and clean; the arrow stops at specs, and one seam disagrees with a tenet.

**Scorecard**
- ✓ Mutation hygiene — no changelog residue, no `[obsolete]` or `[inferred]` markers; every doc reads as current intent
- ✓ Spec hygiene — clean EARS form, unique namespaced IDs, scope carried in WHEN clauses
- ✓ HLD discipline — architecture and rationale only, no implementation detail bleeding upstream
- ✗ Arrow completeness — no tests, no code, no `@spec` annotations, yet all 13 specs are marked `[x]`
- ⚠ Cascade coherence — hold-allocation's local-branch-first routing bends the HLD's first tenet; the allocation ↔ pickup seam has no owner
- ⚠ Configuration — `## LID` block is present but the instruction file carries no LID directives

The two design nodes are well-scoped, the Decisions tables mostly reconstruct cleanly for a cold reader, and the spec files are ready to be cited; the most valuable next step is to reconcile the HLD tenet with hold-allocation's routing rule and record that choice, then walk the arrow forward into tests and code.

**Findings (10 total · 4 high · 4 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block (Mode: Full, Version 1.4.0) but no LID directive text; run `/update-lid` to reconcile · *modes are declared, not inferred* — the instruction file is where every session learns how to work the arrow
- **F2 (high):** The arrow ends at EARS: no tests, no code, zero `@spec` annotations, while all 13 specs are ticked `[x]`; either untick until tests and code cite them, or state where the implementation lives · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present or its absence deliberate and written down
- **F3 (high):** Hold-allocation serves the scanning branch's oldest hold before an older hold elsewhere, which contradicts the HLD tenet "nobody's wait is lengthened by a patron who asked after them"; resolve at the HLD, not the leaf · *intent attaches at the lowest node that dominates it* — a choice that changes what a tenet means belongs in the HLD
- **F4 (high):** Local-branch-first vs. strict county-wide FIFO is the most consequential choice in hold-allocation and has no Decisions & Alternatives row; add one naming the rejected FIFO and the accepted cost (skipped earlier patrons, weighed against one courier run a day) · *decision capture* — a landed choice a cold reader would still question needs its tradeoff on the page
- **F5 (medium):** "Re-run allocation as a check-in" is invoked from PICKUP-005 and HOLDALLOC-007 but defined by neither, and a copy allocated at check-in yet never scanned onto the shelf has no path out of `allocated`; consider naming re-allocation once in hold-allocation and having pickup-notices link to it · *cascade within a segment, pause across* — an obligation landing in a sibling's territory should be acknowledged by that sibling
- **F6 (medium):** Hold-allocation leaves edges open: a hold cancelled while its copy sits on the holds shelf, deletion of a cancelled hold's record (tenet 4 promises it), and a patron holding the same title twice · *LLDs close enough of the solution space* — two agents should land on compatible implementations without guessing
- **F7 (medium):** Pickup-notices reads as if context is already known: what "failed delivery" means for the automated dialer, where the patron's channel preference comes from, and what the morning pull list and daily exceptions list actually are · *docs carry current intent, written to be read cold* — in-conversation-only meaning that future sessions cannot recover
- **F8 (medium):** "Hold history is not kept" is a decision or non-goal phrased as a tenet, and the tenets are unordered even though tenet 1 already collides with the courier-economy lean the LLD acts on; consider moving tenet 4 to a Key Design Decisions or Non-goals section and ordering the rest · *tenets capture forward-looking preference* — one-line tie-breakers with a defensible opposite, ranked when they can conflict
- **F9 (low):** The HLD has no Non-goals or target-users section; naming what Shelfwise does not own (catalog, patron signup, channel preferences) would answer most of F7 at the source · *HLD is architecture and rationale*
- **F10 (low):** Neither design doc carries `prefix:` frontmatter, so `HOLDALLOC` and `PICKUP` resolve to their leaves by convention only · *specs are grep-anchored linkage* — the leaf prefix should be declared, not inferred

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (7 HOLDALLOC, 6 PICKUP), 0 test files, 0 source files
- Arrow overlay: `docs/arrows/` not present, so no index to guide segment sampling
- Linkage metric: 0 `@spec` references across the project
- Sampling: no sampling was needed; the project is small enough that every LID doc was read in full, with a cold-read pass and a Decisions-table sweep over all 7 rows

**Worth a second look:** I could not load the capability-flags reference in this session, so I am treating its flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets. F3 is one I did catch; please check both leaf designs against the HLD tenets yourself, especially "Patrons hear once, clearly" against the exceptions-list path in pickup-notices.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.