**Shelfwise — LID Coach review**

**Posture:** Solid design layer; lifecycle and tenet-cascade gaps to tighten.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; tenets are real tie-breakers with defensible opposites
- ✓ Mutation hygiene — all four docs read fresh; zero history residue, no `[obsolete]`/`[inferred]` markers
- ⚠ Configuration — `## LID` block carries mode/version but no directive text
- ⚠ Tenet cascade — local-first allocation leans against "waiting is honored in sequence"
- ⚠ Intent coverage — hold cancellation is referenced but never specified
- ⚠ Linkage — spec prefixes abbreviate leaf paths; 0 tests cite the 13 specs yet

**Findings (9 total · 3 high · 4 medium · 2 low)**
- **F1 (high):** CLAUDE.md's `## LID` block has `- Mode: Full` and `- Version: 1.4.0` but no LID directive text — future sessions get a mode with no workflow behind it; run `/update-lid` to reconcile · *modes are declared, not inferred*
- **F2 (high):** Branch-local-first allocation (hold-allocation-design.md:11) can serve a newer local patron before an older county-wide one, directly leaning against the tenet "waiting is honored in sequence," and no row records the exception · *tenet cascade — design nodes lean the way the HLD's tenets say to lean*
- **F3 (high):** Hold cancellation appears only as a trigger (HOLDALLOC-007) — no LLD or spec defines cancelling, deleting the record (tenet 4), or releasing the 15-hold cap slot; a cold reader can't resolve "who cancels, and what happens" · *effective intent-tree alignment — LLD behaviors with no specs are unnamed intent that drifts silently*
- **F4 (medium):** The allocation-ordering choice (local-first vs. strict county-wide sequence) survives only as design prose with a courier rationale, not a Decisions row naming what was given up · *docs carry current intent — decision capture*
- **F5 (medium):** HOLDALLOC-004 ("no open hold names the scanning branch") and HOLDALLOC-005 ("no open holds exist") both fire when a title has zero holds; an implementer meets two matching guards · *scope disambiguation — specs must be unambiguous when found via grep, out of context*
- **F6 (medium):** HOLDALLOC-005's reshelving edge has no counterpart in the LLD, and the LLD never says what clears `allocated` when a hold closes without checkout · *LLDs close enough of the solution space*
- **F7 (medium):** The `- [x]` markers on all 13 specs have no legend; with zero code in the repo, a cold reader reads them as "implemented" · *docs carry current intent — written to be read cold*
- **F8 (low):** Spec prefixes abbreviate the leaf paths (HOLDALLOC vs. `hold-allocation`, PICKUP vs. `pickup-notices`), so grepping the design-tree path finds no specs · *specs are grep-anchored linkage*
- **F9 (low):** No test cites any of the 13 specs yet — expected pre-implementation, but it means nothing has exercised the specs; when code starts, tests-first gives them their first consumer · *tests before code*

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files (13 specs: 7 HOLDALLOC, 6 PICKUP)
- Enumerated: 2 LLDs, 2 spec files, 0 code files, 0 test files, 0 `@spec` references; no `docs/arrows/` overlay, so no structural enumeration attempted
- Linkage metric: 13 unique spec IDs, no collisions; prefix-to-leaf tracing checked against both leaf dirs
- Residue screen: zero matches for obsolete/inferred/changelog patterns across `docs/`
- Non-interactive run — defaults taken: full review (dispatch row for missing directives + LID-shaped artifacts), Full mode, advisory posture (no files changed)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.