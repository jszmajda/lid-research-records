## LID Coach — Visit Planner

**Posture:** Bootstrapping — the arrow is real and well-shaped through specs; it stops there.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; tenets are genuine tie-breakers with defensible opposites
- ✓ LLD sufficiency — both designs close the solution space (mechanisms, state transitions, accepted costs) without reproducing code
- ✓ Mutation hygiene — docs read as current intent; no history residue, no `[obsolete]` markers
- ⚠ Arrow completeness — specs exist, but no Tests or Code phase anywhere
- ⚠ Configuration — the instruction file lacks the LID directive block
- ⚠ Tenet cascade — one mechanism works against a HLD tenet with no recorded exception

**Headline:** The design tree is clean and the tenets are the best part of this setup; the most valuable next step is reconciling the instruction file and then walking the arrow's missing lower half (tests → code).

### Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** `CLAUDE.md` has a `## LID` block with `Mode: Full` but no LID directives (no mention of linked-intent-dev or the workflow) — future sessions won't know how to work the arrow. Run `/update-lid` to reconcile. · *modes are declared, not inferred*
- **F2 (high):** All 15 specs are marked `[x]` (complete), yet the repo contains zero code and zero tests — the arrow stops after EARS. Either the `[x]` markers are premature (uncheck them until implemented), or implementation was lost. Plan the Tests → Code phases, tests first. · *tests before code; canonical arrow shape*
- **F3 (high):** Tenet "First asked, first served" says an earlier request is never passed by a later one — but the ≤36h path (FILL-004, fulfillment-design.md §Design) lets *any* eligible signed-in account claim the opening during the 20-minute searchable window, bypassing queued entries with less `enteredAt`. No Decisions row records this trade. Either name the tenet traded against in a Decisions row (why the 20-minute window justifies queue-jumping) or reconsider the mechanism. · *tenets capture forward-looking preference — tenet cascade*
- **F4 (medium):** Spec prefixes: `INTAKE-*` resolves to the intake leaf, but `FILL-*` names no design node — the leaf is "fulfillment." Rename to `FULFILLMENT-*` (or a shared abbreviation declared via `prefix:` frontmatter) so greps resolve in both directions. · *effective intent-tree alignment — specs are grep-anchored linkage*
- **F5 (medium):** The 36-hour cutoff and the 20-minute `notBefore` window are load-bearing numbers living only in prose; a cold reader can't reconstruct what was given up. Add Decisions rows for each. · *docs carry current intent — decision capture*
- **F6 (low):** The HLD has Problem/Approach/Tenets/Goals/Components but no Non-goals or Success metrics sections — cheap to add and it sharpens future tie-breaks. · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, all 4 design/spec files under `docs/intent/` (2 LLDs, 2 spec files, 15 specs)
- Enumerated: the entire repo (6 files); no code or test files exist to sample; no `docs/arrows/` overlay
- Spec status markers: all 15 marked `[x]`

No capability flags apply to this review configuration.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken in this non-interactive run:* Full mode (from the `## LID` block, since directives were absent but artifacts exist), inline report with no files written, and advisory posture — no edits applied.