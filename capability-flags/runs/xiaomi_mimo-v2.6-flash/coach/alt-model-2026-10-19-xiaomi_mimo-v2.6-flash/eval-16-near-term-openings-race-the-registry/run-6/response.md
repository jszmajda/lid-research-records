# LID Coach — Visit Planner

**Posture: Healthy design layer — the arrow stops at specs.**

**Scorecard**
- ⚠ Configuration — `## LID` block declares mode but carries no linked-intent-dev directives
- ✓ HLD & tenets — four real tie-breakers, architecture-only content, no implementation bleed
- ✓ Spec linkage — 15 unique IDs, each traces cleanly to a leaf design
- ⚠ Cascade & tenet alignment — same-day claim window leans against first-asked; shared contracts have no home
- ⚠ LLD sufficiency — matching predicate and "registry" left open
- ✗ Arrow completeness — tests and code phases don't exist yet

**Headline:** The design tree is clean, well-teneted, and mutation-hygiene is excellent — docs read as current intent with no history residue; the fastest wins are reconciling the instruction-file directives via `/update-lid` and recording the same-day claim trade against first-asked before implementation starts.

**Findings (9 total · 3 high · 5 medium · 1 low)**
- **F1 (high):** CLAUDE.md's `## LID` block has a mode marker but no "linked-intent-dev" directives — agents won't know to load the workflow · *modes are declared, not inferred* (an undeclared directive is a default) → `/update-lid`
- **F2 (high):** no tests or code exist for either component — the arrow is walkable only through design + specs, with no note that implementation is pending · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code)
- **F3 (high):** under the ≤36h flow, any signed-in account's checkout can pass an earlier `enteredAt` interest entry — against "First asked, first served"; no row or doc records the exception · *tenet cascade* (design nodes should lean the way the HLD's tenets say to lean)
- **F4 (medium):** the ≤36h public-claim trade-off and the 36h / 20min / 2h thresholds have no Decisions & Alternatives row — a cold reader can't reconstruct what was given up or why these numbers · *docs carry current intent* (decision capture keep-side)
- **F5 (medium):** fulfillment's "compatible", "eligible", and "registry" are never defined — two reasonable agents could diverge on window-overlap and accessibility matching · *LLDs close enough of the solution space*
- **F6 (medium):** immutable `enteredAt` ordering and the append-only event history both span intake and fulfillment but live only in leaf prose — fulfillment's correctness depends on an intake-only guarantee · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F7 (medium):** every spec carries an unexplained `[x]` marker with no legend anywhere — and since no code exists, a cold reader may misread it as "implemented" · *docs carry current intent, written to be read cold*
- **F8 (medium):** the HLD has Goals but no non-goals or success metrics — scope edges (e.g., non-routine or specialist visits) stay open at the architecture level · *HLD is architecture and rationale*
- **F9 (low):** `FILL-*` truncates its leaf path while `INTAKE-*` spells it out — inconsistent prefix↔leaf echo for grep-anchored traversal · *specs are grep-anchored linkage*

**What was audited**
- Read fully (entire repository — 6 files): CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 15 spec IDs (INTAKE-001–007, FILL-001–008)
- Code/test sample: none exist — 0 files, 0 `@spec` references
- Arrow overlay: absent (`docs/arrows/` not present); no sampling needed at this size
- Cold-read pass and Decisions-table sweep run across all 4 design tables (8 rows); 7 of 8 rows pass, the gap is captured in F4

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---
*Run notes (non-interactive defaults taken): dispatch defaulted to a full review (mode marker already `Full`; directive strings absent, so coaching proceeded per the LID-shaped-artifacts branch); report rendered inline, not persisted to disk; advisory posture observed — no project files were edited.*