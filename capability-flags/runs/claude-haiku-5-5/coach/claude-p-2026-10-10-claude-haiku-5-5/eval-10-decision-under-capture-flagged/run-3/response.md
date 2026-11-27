**LID Coach report: sync project**

**Executive summary**

Posture: **Solid early design; the Sync LLD needs its convergence path and one key decision written out.**

**Scorecard**
- ✓ Mode fit: Full mode suits a greenfield design set
- ✓ Linkage: the `SYNC` prefix matches the LLD's `prefix:`, and both spec IDs are unique and grep-anchored
- ✓ Scope disambiguation: both specs state their trigger in the WHEN clause
- ✓ Tenets: "Boring over clever" is a real lean, with a defensible opposite and an explicit escape hatch
- ✓ Docs discipline: no change-narration or history residue
- ⚠ Decision capture: the wall-clock last-writer-wins row gives no cost or alternatives
- ⚠ LLD sufficiency: the convergence path and several edge cases are open

Headline: The core intent is clear and well-linked for a project this size: the HLD names the problem and tenets, the LLD owns the sync behavior, and the specs match the LLD. The most valuable next step is to write down how convergence actually happens and what the wall-clock decision costs, since both are load-bearing and currently live only in the author's head.

**Findings (9 total · 2 high · 3 medium · 4 low)**
- **F1 (high):** The HLD goal "convergent state after reconnect" has no mechanism. Devices upload, but nothing returns the merged state to them, and a device whose edit loses never learns it was discarded · *LLDs close enough of the solution space*
- **F2 (high):** The last-writer-wins row says only "Simpler." while the Context says device clocks are "frequently wrong by several minutes." A cold reader can't tell what was given up or accepted · *docs carry current intent, written to be read cold* (decision capture)
- **F3 (medium):** The HLD names a device-local store as a component, but only the Sync LLD exists. The SQLite choice sits in a table row with no design doc · *one LLD per intent component*
- **F4 (medium):** Behaviors with no spec: non-conflicting merge in the sync service, and the NTP resync on reconnect described in the Context · *effective intent-tree alignment*
- **F5 (medium):** Open edges in the conflict rule: equal timestamps, whether "edit" means whole note or field, how reconnect is detected, and whether pending edits are kept after a failed upload · *LLDs close enough of the solution space*
- **F6 (low):** The HLD has no success metrics or target users, so "no blocked capture in the field" can't be checked · *HLD is architecture and rationale*
- **F7 (low):** The `[x]` markers in the spec file have no legend, so a reader can't tell whether they mean implemented, accepted, or something else · *docs carry current intent, written to be read cold*
- **F8 (low):** Terms drift: the HLD says "central service," the LLD says "sync service," and "canonical store" is never defined · *docs carry current intent, written to be read cold*
- **F9 (low):** No tests or code exist yet, so tests-first evidence can't be assessed. Writing tests for SYNC-001 and SYNC-002 before implementation would exercise the arrow early · *tests before code*

**What was audited**
- Read fully: `CLAUDE.md` (LID block, Mode Full, directive present), `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file (2 specs)
- Arrow-path sampled: none. There is no code, no tests, and no arrow overlay, so there was nothing to trace past the specs
- Linkage metric: 0 `@spec` references (no code yet)
- Sampling reference not needed: the project is below the LLD and `@spec` thresholds, and no overlay is present
- Capability flags: the skill's flag file lists no flagged configurations, so no capability note applies

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.