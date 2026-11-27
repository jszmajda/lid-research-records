**Shelfwise — LID Coach Report**

**Posture:** *Bootstrapping — clean design layer, arrow stops at specs.*

**Scorecard**
- ✓ HLD discipline — problem, approach, tenets, goals, components; no implementation detail has crept upstream
- ✓ Spec hygiene — all 13 specs are EARS-formed, uniquely namespaced (`HOLDALLOC-`, `PICKUP-`), zero-padded, no residue
- ✓ Mutation hygiene — no change-narration, changelog, or conversational fossils in any doc
- ⚠ Configuration — the `## LID` block is present but the instruction file carries no LID directives
- ⚠ Tenet/design coherence — the allocation lean quietly contradicts the first tenet, and that choice has no decision row
- ✗ Arrow completeness — no tests, no code, no `@spec` annotations, yet every spec is marked `[x]`

The HLD and both leaf designs are tight, cold-readable, and free of residue, and the spec layer traces cleanly to them; the most valuable next step is to reconcile the branch-local allocation lean with the "waiting is honored in sequence" tenet and capture it as a decision *before* code lands, then run `/update-lid` so the instruction file catches up with the arrow you have built.

**Findings (12 total · 5 high · 4 medium · 3 low)**
- **F1 (high):** `CLAUDE.md` has `- Mode: Full` and a version, but no `linked-intent-dev` directive block — run `/update-lid` to reconcile · *modes are declared, not inferred* (the instruction file is where LID learns how to behave; without directives every session runs on defaults)
- **F2 (high):** The arrow ends at specs — no tests, no code, zero `@spec` annotations — yet all 13 specs carry `[x]`; either the implementation lives elsewhere (say so in the instruction file) or the markers are ahead of the arrow · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code, each phase present or its absence deliberate)
- **F3 (high):** `hold-allocation-design.md` gives a copy to the *newest* local hold before an *older* hold at another branch, which is exactly what tenet 1 ("nobody's wait is lengthened by a patron who asked after them") says not to do — consider qualifying the tenet or changing the lean · *tenets capture forward-looking preference* (a tenet is the tie-breaker the design should lean on, not lean against)
- **F4 (high):** That branch-local-first rule is the biggest decision in the allocation LLD and has no Decisions & Alternatives row — its only rationale is a clause about the courier van; consider a row naming the rejected "oldest hold county-wide" and the accepted cost (some patrons served out of order); a decision doc is an option if you want the full option space on record, since Goal 1 and the transit design both size themselves around it · *decision capture* (a cold reader should be able to reconstruct what was given up and why)
- **F5 (high):** Hold cancellation is relied on (`HOLDALLOC-007`, the hold-cap row's "must cancel one") but neither designed nor specified — who can cancel, what happens to an `allocated` copy on the shelf vs. in transit, whether the record is deleted per tenet 4 · *LLDs close enough of the solution space* (edges left open are where two agents land on incompatible implementations)
- **F6 (medium):** The docs use four distinct scan events — check-in, transit arrival, scan onto holds shelf, scan off for pull — without saying whether they are one circulation event or several; an agent could reasonably treat a transit arrival as a check-in that re-runs `HOLDALLOC-003` · *docs carry current intent, written to be read cold* (the event model lived in the author's head, not on the page)
- **F7 (medium):** The hold record's lifecycle is split — stored in `HOLDALLOC-001`, closed and deleted in `PICKUP-003`/`PICKUP-005`, cancelled nowhere — with no node that owns it; consider giving hold allocation ownership of the record lifecycle and letting pickup notices reference it · *intent attaches at the lowest node that dominates it* (substance affecting two siblings belongs where it governs both)
- **F8 (medium):** Goal 1 (median check-in-to-notice time) and Goal 2 (expiry rate) need retained outcome and timing data, while tenet 4 says a closed hold's record is deleted; the HLD should say what de-identified aggregate survives so the goals stay measurable · *HLD is architecture and rationale* (a success metric the architecture cannot observe is an open question, not a goal)
- **F9 (medium):** `PICKUP-006` covers "fails to deliver" for email and SMS, but the third channel (automated dialer) has no defined failure — no answer, voicemail, wrong number · *scope disambiguation* (a universal-sounding spec should be unambiguous for every variant it claims to cover)
- **F10 (low):** The four tenets are unordered, yet tenet 1 and the operational lean behind F3 already collide; consider numbering them by precedence · *tenets capture forward-looking preference*
- **F11 (low):** Neither design doc declares a `prefix:` in frontmatter, so `HOLDALLOC` → `hold-allocation` and `PICKUP` → `pickup-notices` resolve by convention only; consider adding it before the tree deepens · *specs are grep-anchored linkage*
- **F12 (low):** A patron who checks out a lapsed copy between the window ending (`PICKUP-004`) and the morning pull (`PICKUP-005`) hits an unstated edge — does `PICKUP-003` still apply? · *LLDs close enough of the solution space*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 spec IDs (7 `HOLDALLOC`, 6 `PICKUP`), 2 arrow segments, 6 files in the project total
- Arrow-path sampled: both segments end-to-end as far as they go (HLD section → LLD → spec); the test and code levels do not exist to sample
- Linkage metric: 0 `@spec` references; no `[inferred]` or `[obsolete]` markers; `docs/arrows/` overlay not installed
- Cold-read and Decisions-table sweep: all 7 decision rows read; 6 pass, and the one decision a cold reader would pause at (branch-local-first) has no row (F4)
- Capability-flags reference: could not be read from this session (outside the permitted directories), so its flags were treated as applying

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets. F3 is one I did catch; please check both leaf designs against your HLD tenets yourself in case there are others.

Want me to walk through the findings in detail, focus on a theme or priority (the tenet/decision cluster F3–F4, or the open lifecycle edges F5–F7), or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.