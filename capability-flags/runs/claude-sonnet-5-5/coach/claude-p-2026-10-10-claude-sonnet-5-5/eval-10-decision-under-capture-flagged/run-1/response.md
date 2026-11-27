**Field Notes: LID coach review**

## 1. Executive summary

**Posture:** Healthy skeleton, with one design choice worth a second look.

**Scorecard**
- ✓ Configuration: the LID directives, `Full` mode marker and standard directories are all in place.
- ✓ Arrow design layer: the HLD → LLD → EARS chain is linked, and the `SYNC` prefix matches the LLD frontmatter.
- ✓ Doc hygiene: the docs read as present-tense intent, with no history residue or obsolete markers.
- ⚠ Design vs. tenets/goals: the conflict-resolution mechanism meets a condition the LLD itself describes.
- ⚠ Decision capture: the conflict-resolution row doesn't carry its reasoning or its cost.
- ⚠ Arrow completeness: the specs are marked done, but no tests or code are in the repo.

**Headline:** The design layer is clean, small and well-linked, with a real tenet and EARS specs that trace to their LLD. The most valuable next step is to revisit last-writer-wins by device wall-clock, given that the LLD says device clocks are frequently minutes off.

## 2. Findings inventory

**Findings (6 total · 2 high · 3 medium · 1 low)**
- **F1 (high):** Last-writer-wins by device wall-clock, with the loser discarded, meets the LLD's own "clocks wrong by several minutes" condition. A skewed device can silently overwrite a newer edit and a technician's note is lost. · *tenet cascade: do the designs lean the way the HLD's goals and tenets say?* The HLD's "convergent state" and "notes must reconcile" intent is at stake.
- **F2 (high):** The Decisions row for conflict resolution says only "Simpler." It doesn't name what is given up (silent data loss, clock-skew exposure) or the alternatives considered (logical or server-assigned ordering, keeping both versions). · *docs carry current intent: decision capture*
- **F3 (medium):** Both specs are marked `[x]`, but the repo has no tests or code carrying `@spec` annotations, so the lower arrow phases can't be walked. · *canonical arrow shape; tests carry `@spec` annotations*
- **F4 (medium):** The Sync LLD leaves edges open: tie-breaking on equal timestamps, edit granularity (whole note or field), deletions, and retry or partial-upload behavior. Two agents could reasonably implement these differently. · *LLDs close enough of the solution space*
- **F5 (medium):** SYNC-002 hard-codes "later device wall-clock timestamp" as the rule, so F1 would need to change the spec and the LLD together. Keep them in step when the design moves. · *coherence is adjacency*
- **F6 (low):** The HLD has no Key Design Decisions or success-metrics sections, and its Architecture section is one line. The local-first and sync-on-reconnect choices could use a short rationale. · *HLD is architecture and rationale*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`.
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 specs (`SYNC-001`, `SYNC-002`).
- Code and tests: none found in the repository, so there was nothing to sample.
- No `docs/arrows/` overlay is present, so no `/arrow-maintenance` audit applies yet.
- Cold-read pass: no unresolved context dependencies found.
- Decisions-table sweep: the SQLite row passes (a cold reader wouldn't question it); the conflict-resolution row doesn't (F2).

## 6. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into. F1 and F2 pair naturally.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.