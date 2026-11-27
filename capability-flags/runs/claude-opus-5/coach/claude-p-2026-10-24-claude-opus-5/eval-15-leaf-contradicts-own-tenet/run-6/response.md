**LID Coach — Shelfwise**

## Executive summary

**Posture:** *Solid design layer; the arrow stops at specs, and two HLD commitments are quietly in tension with the designs below them.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ LLD granularity — two leaves matching the two things a librarian would name; no overlap
- ✓ Spec hygiene — EARS-shaped, uniquely prefixed, zero-padded, no `[obsolete]` residue
- ⚠ Configuration — the `## LID` block carries mode and version but no linked-intent-dev directives
- ✗ Arrow completeness — tests and code phases are absent while every spec is marked done
- ⚠ Tenet cascade — allocation's branch preference leans against a stated tenet with no record of the trade

**Headline:** The design layer here is genuinely good — tight HLD, two clean leaves, EARS specs that a cold reader can follow, and Decisions tables that name accepted costs (the pickup-window and expiry-handling rows are model examples). The highest-value next steps are reconciling the instruction file with `/update-lid` and recording the branch-preference decision, which is currently the most consequential choice in the project and the least documented.

## Findings (11 total · 5 high · 4 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block declares `Mode: Full` and `Version: 1.4.0` but carries no linked-intent-dev directive text, so a fresh session gets the mode without the methodology · *modes are declared, not inferred* — the declaration is what the rest of LID keys off
- **F2 (high):** Allocation's local-branch preference (`hold-allocation-design.md:11`, `HOLDALLOC-003/004`) hands a copy to a patron who asked later over one who asked earlier whenever the copy is scanned at the later patron's branch — directly against the tenet "nobody's wait is lengthened by a patron who asked after them," with no row naming the trade · *tenet cascade / coherence is adjacency*
- **F3 (high):** That same branch-preference choice has no Decisions & Alternatives row; its rationale ("keeps most copies off the courier van") survives only as inline prose · *decision capture* — a cold reader would absolutely question or try to reverse this one
- **F4 (high):** Every spec in both files is marked `[x]`, but the repo holds no tests and no code — the arrow runs `HLD → LLDs → EARS` and stops · *canonical arrow shape*; *tests before code*
- **F5 (high):** Goal 2 ("fewer than 10% of holds-shelf items expire uncollected") cannot be measured under the tenet "Hold history is not kept" plus `PICKUP-003/005`, which delete the record at close — the outcome is gone before it can be counted · *tenets capture forward-looking preference* (the tension sits inside the HLD, between a tenet and a goal)
- **F6 (medium):** Cancellation is only designed for the in-transit case (`HOLDALLOC-007`); a hold cancelled while its copy sits on a holds shelf has no trigger, and no spec closes or deletes a cancelled hold's record · *LLDs close enough of the solution space*
- **F7 (medium):** The `allocated` marker is set (`HOLDALLOC-003/004`) and guarded (`HOLDALLOC-006`) but no spec clears it on checkout or expiry — the state machine's exit edges are open · *coherence is adjacency*
- **F8 (medium):** The four tenets are an unordered list, yet at least two pairs can collide in practice (sequence-of-waiting vs. courier efficiency; hear-once vs. Goal 2) · *tenets capture forward-looking preference* — an unordered set gives a future session no tie-breaker between tie-breakers
- **F9 (medium):** Neither spec file declares `prefix:` frontmatter, so `HOLDALLOC` / `PICKUP` resolve to `hold-allocation/` and `pickup-notices/` only by reader inference · *specs are grep-anchored linkage*
- **F10 (low):** The patron's chosen contact channel is load-bearing for `PICKUP-002` and `PICKUP-006` but no spec stores or changes it; `HOLDALLOC-001`'s stored fields don't include it · *effective intent-tree alignment*
- **F11 (low):** A few body-prose lines restate Decisions rows in the negative ("No reminder follows."; "does not trigger a fallback channel") where the table already carries the choice and its cost · *docs carry current intent* — mild, and worth a light touch only

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (2 design docs, 2 spec files)
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 4 tenets, 2 goals, 7 Decisions rows
- Arrow-path walked: both segments end-to-end — HLD component link → design doc → spec file → (tests: none found) → (code: none found)
- Searched for: tests, source files, `@spec` annotations, `docs/arrows/` — none present, so no overlay-guided sampling and no `/arrow-maintenance` enumeration available
- Cold-read pass: all five LID docs, plus a Decisions-table sweep across all 7 rows
- Non-interactive run: no dispatch prompt was needed — the instruction file lacks LID directives but the project is clearly LID-shaped, so I took the skill's stated default and ran a full review anchored on the existing artifacts (F1 records the configuration gap)

---

Want me to walk through the findings in detail, focus on a theme or priority band, or work through specific items together? F2 and F3 are the pair I'd start with — they're the same choice seen from two angles, and the remedy for one informs the other.

If you have broader questions about using LID on Shelfwise — when to add tests-and-code phases, how to handle a metric that a privacy tenet makes unmeasurable, when a leaf should be promoted to a sub-HLD — I'm glad to go into those too.