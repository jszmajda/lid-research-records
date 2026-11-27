**LID Coach — Shelfwise review**

**Posture:** Solid, coherent design core; the fastest wins are configuration wiring and one tenet-level design question.

**Scorecard**
- ✓ Design tree — one LLD per component; HLD carries architecture and rationale, no implementation bleed
- ✓ Spec hygiene — unique IDs, EARS-shaped, no obsolete/history residue
- ✓ Decision capture — decisions rows name the rejected alternative and its cost (two explicitly cite tenets/goals)
- ⚠ Tenet cascade — the local-first allocation rule leans against the HLD's own sequence tenet, with no recorded exception
- ⚠ Arrow completeness — the arrow stops at EARS; the `[x]` status marker is undefined
- ✗ Configuration — the instruction file declares a mode but carries no LID directive block

**Findings (7 total · 3 high · 3 medium · 1 low)**

- **F1 (high):** `CLAUDE.md` declares `## LID` / `- Mode: Full` but has no LID directive block (no pointer to the workflow, no spec/design convention) · *modes are declared, not inferred* — an unread mode is a default; run `/update-lid` to reconcile
- **F2 (high):** `HOLDALLOC-003/004` allocate to the *oldest local* hold before the county-wide oldest, so a later local patron takes a copy ahead of an earlier remote one — directly against HLD tenet "Waiting is honored in sequence … nobody's wait is lengthened by a patron who asked after them," from which the design prose (`hold-allocation-design.md:11`) records no exception · *tenet cascade* — name the tenet traded against, or amend the tenet
- **F3 (high):** the arrow has no Tests or Code phase, yet every spec is checked `[x]`; a cold reader can't tell whether `[x]` means "authored," "confirmed," or "implemented," and no code exists either way · *canonical arrow shape* + *tests before code* — define the status marker and state the arrow's current end
- **F4 (medium):** HLD has Problem/Approach/Tenets/Goals/Components but no Target Users and no explicit Non-Goals · *HLD is architecture and rationale* — non-goals are what keep later scope creep legible
- **F5 (medium):** spec prefixes `HOLDALLOC` and `PICKUP` derive inconsistently from their leaves (`hold-allocation`, `pickup-notices`), and the design docs never declare their prefix/namespace · *specs are grep-anchored linkage* — a cold grep can't resolve `PICKUP` to its leaf
- **F6 (medium):** the local-vs-strict-sequence allocation choice lives only in design prose, not in the Decisions & Alternatives table (which covers granularity, trigger, and cap only) · *decision capture* — the companion to F2; the row should carry the choice, the rejected strict-sequence alternative, and the accepted cost
- **F7 (low):** HLD components and LLDs don't cross-link to their spec files or prefixes; linkage rests entirely on filename co-location · *specs are grep-anchored linkage*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (13 specs: 7 HOLDALLOC, 6 PICKUP)
- Enumerated: 1 HLD, 2 LLDs, 2 spec files; `docs/arrows/` overlay absent
- Code/tests: 0 files, 0 `@spec` annotations — repo is docs-only
- Sampling: project is below the deep-sampling thresholds (≤15 LLDs, ≤200 annotated files), so judgment sampling applied; no end-to-end arrow-path sample was possible (no code/test layer)

**Worth a second look:** no capability flags apply to this configuration, so no self-check is required.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---
*Run defaults taken (non-interactive): mode defaulted to Full (no scope declared); proceeded with a full review although LID directives were absent (dispatch treats a LID-shaped project as reviewable, with the missing directives surfaced as F1); no deep-sampling pass (thresholds not met); advisory posture — no files were edited.*