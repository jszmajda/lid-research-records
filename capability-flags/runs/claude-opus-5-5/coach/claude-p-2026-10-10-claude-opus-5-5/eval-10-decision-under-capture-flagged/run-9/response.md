# LID Coach report — Field Notes

## Executive summary

**Posture:** Bootstrapping — the design half of the arrow is clean and linked; the conflict decision and the test/code half need attention.

**Scorecard**
- ✓ Configuration and mode — `## LID` block, `Mode: Full` and the directive are all present; Full fits a single-product repo
- ✓ Mutation hygiene — all three docs read as current intent, with no history or planning residue
- ✓ Linkage — `prefix: SYNC` in the LLD matches both spec IDs; the specs are well-formed EARS and point back to their LLD
- ⚠ Decision capture — the one choice a reader would challenge carries a one-word rationale
- ⚠ LLD sufficiency — the sync design covers upload and conflict only; several edges are left open
- ✗ Arrow completeness — specs are marked `[x]`, but the repo holds no tests or code

**Headline:** The skeleton is right: one HLD, one LLD per component, specs that mirror the LLD exactly, and nothing stale. The most valuable next step is to revisit the conflict-resolution decision, both the choice itself and how it is recorded, before anything is built on it.

## Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** Conflicts are resolved by device wall-clock, yet the sync LLD's own Context says those clocks are "frequently wrong by several minutes". An older edit can therefore win and the newer one be silently discarded, which works against the HLD's "notes must reconcile" and its convergence goal. · *tenets and goals cascade into leaf designs* — each mechanism should hold up against the HLD's goals under the conditions the docs themselves describe
- **F2 (high):** The Decisions row for conflict resolution says only "Simpler." It doesn't say simpler than what, or that discarding a technician's edit was the accepted cost. · *docs carry current intent, written to be read cold* — a decision a future reader would question needs its alternatives and trade-off on the page
- **F3 (high):** `SYNC-001` and `SYNC-002` are marked `[x]`, but there are no test or source files in the repo and no `@spec` annotations. · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code) and *tests before code* — a status marker should be backed by a test that cites the spec
- **F4 (medium):** The sync LLD leaves several edges open:
  - how merged state gets back to devices (only upload is described, so convergence isn't reachable as written)
  - equal-timestamp ties
  - deletes
  - whether an edit is a whole note or a field
  - upload retry and partial failure
  - whether the losing technician is told

  *LLDs close enough of the solution space* — two agents reading the LLD should land on compatible implementations
- **F5 (medium):** The HLD names a device-local store and a "no blocked capture" goal, but neither has an LLD or specs. The "SQLite on device" decision sits in the sync LLD instead. · *one LLD per intent component* and *intent attaches at the lowest node that dominates it* — a decision lives with the component that owns it
- **F6 (low):** The HLD has no target users, key design decisions or success metrics, and its Architecture section is one line. The single tenet is a real tie-breaker, but one tenet narrows few choices. · *HLD is architecture and rationale* — the HLD carries the long-lived "why" that leaf designs lean on

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 specs), 2 Decisions rows; 0 test files, 0 source files, 0 `@spec` references
- Dispatch: fully configured (directives, mode marker and standard directories present), so this was a full review; no arrow overlay (`docs/arrows/`) is installed
- Non-interactive run: the skill had no questions to ask, so no defaults were taken; nothing was edited or written to disk

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.