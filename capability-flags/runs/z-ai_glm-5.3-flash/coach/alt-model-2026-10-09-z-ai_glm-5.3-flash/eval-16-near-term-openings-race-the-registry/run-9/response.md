**LID Coach — Visit Planner**

**Posture: Bootstrapping — arrow in place, code side absent.**

**Scorecard**
- ⚠ Arrow completeness — HLD → LLDs → EARS exists; Tests and Code phases have no files at all
- ✓ HLD discipline — architecture and rationale only; no implementation detail bled upstream
- ✓ LLD granularity & sufficiency — two clean leaf LLDs, tight Decisions & Alternatives, solution space closed
- ✓ Mutation hygiene — no history residue, obsolete markers, or changelog tax in any doc
- ⚠ Linkage hygiene — `FILL-` spec prefix doesn't trace by name to the `fulfillment` leaf
- ✓ Tenet quality — four real tie-breakers with defensible opposites, lean-shaped not rule-shaped

**Headline:** The design side is genuinely well-done — two right-sized LLDs, clean EARS, strong tenets. The most valuable next step is the missing right half of the arrow: no tests or code exist anywhere, yet every spec is checkbox-marked `[x]` as if delivered.

**Findings (6 total · 2 high · 3 medium · 1 low)**
- **F1 (high):** No tests and no code exist in the repo, but all 15 specs are marked `[x]` (complete) — *tests before code; intent leads; code is compiled output*. The `[x]` markers make the docs claim implementation that isn't there; a future session will trust them.
- **F2 (high):** Spec IDs use the `FILL-` prefix while the owning leaf is `fulfillment` — *specs are grep-anchored linkage* (prefix = root-to-leaf path). `INTAKE-` matches its directory; `FILL-` doesn't, so grepping for the leaf name misses half the specs and a cold agent can't reconstruct the path.
- **F3 (medium):** HLD lacks Non-goals and Success Metrics sections — *HLD is architecture and rationale*. Tenets, Goals, and Components are present and good; the missing sections leave scope edges and "what does done look like" unanswered.
- **F4 (medium):** "registry scan" and `notBefore` in `fulfillment-design.md:9` are never defined anywhere — *docs carry current intent, written to be read cold* (in-conversation-only meaning). The spec (`FILL-003`) says "registry scan" too, so a cold reader can't tell what artifact is being scanned.
- **F5 (medium):** The design commits to a **two-hour offer window** (`fulfillment-design.md:7`) but no spec pins it — *LLDs close enough of the solution space* / spec coverage. `FILL-002` covers expiry without naming the duration, so a two-hour vs. two-day implementation both "satisfy" the specs.
- **F6 (low):** First-asked-first-served is a HLD tenet, but only `FILL-001`/`FILL-005` partially encode it; the published-openings checkout path (`FILL-004`) has no spec saying the offer-first patient keeps priority — *tenet cascade*. A cold session implementing checkout has nothing forcing the tenet there.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files (15 EARS specs)
- Enumerated: 2 leaf LLDs, 2 spec files, 15 specs; 0 code files, 0 test files in the repo
- Cold-read pass through all four docs in the intent tree
- Decisions-table sweep: 8 rows reviewed, all pass (each names rejected alternative and accepted cost)

**Defaults taken:** Full mode (declared in the `## LID` block); advisory posture — no files edited; all files read directly since the project is below the sampling threshold; capability-flags reference lists no flagged configurations, so no flag applies to this review.

Want me to walk through any finding in detail, or dig into one together? And if you have broader questions about using LID here — like how to start the tests-first side of this arrow, or whether specs should precede the code you're about to write — I can help with that too.