*Bootstrapping — clean upper-arrow foundation, with live conflict-design and decision-capture gaps before implementation.*

**Scorecard**
- ✓ Configuration & HLD discipline — explicit `Mode: Full` setup, concise architectural HLD with no implementation bleed, and clean `SYNC` prefix alignment
- ✓ Mutation hygiene — docs carry present-tense intent with no historical residue, changelogs, or obsolete markers
- ✗ Arrow completeness — `SYNC-001` and `SYNC-002` are marked `[x]` complete, while `Tests` and `Code` do not yet exist in the repo
- ⚠ Decision capture — `Conflict resolution` in `sync-design.md` gives only `"Simpler."` on a choice that its own clock-skew context makes immediately questionable
- ⚠ Design coherence & LLD sufficiency — wall-clock last-writer-wins discards edits under multi-minute offline clock drift, and server-to-device convergence and tie-breaking remain open

Field Notes has a clean Full-mode upper arrow — a focused HLD, event-driven EARS triggers, and clear `SYNC` traceability (with choices like `SQLite on device` already naturally grounded by the HLD's local-first approach and *Boring over clever* tenet); the highest-value next step before writing tests and code is revisiting or explicitly justifying wall-clock last-writer-wins under multi-minute clock drift in `docs/intent/sync/sync-design.md`.

**Findings (5 total · 3 high · 2 medium)**
- **F1 (high):** Consider aligning spec status with repo state in `docs/intent/sync/sync-specs.md`, where `SYNC-001` and `SYNC-002` are marked `[x]` without `Tests` or `Code` phases present yet · *canonical arrow shape — with a recursive design layer* (each phase in `HLD → LLDs → EARS → Tests → Code` exists and reflects actual progress)
- **F2 (high):** Consider expanding the `Conflict resolution` row (`Last-writer-wins by device wall-clock` · `"Simpler."`) in `docs/intent/sync/sync-design.md` so a cold reader can reconstruct what alternatives were set aside and why losing edits under multi-minute clock drift was accepted · *docs carry current intent, written to be read cold* (decisions a cold reader would question or try to reverse need their rejected alternatives and accepted costs on the page)
- **F3 (high):** Consider revisiting wall-clock last-writer-wins with discarded edits in `docs/intent/sync/sync-design.md` (§Conflict handling, `SYNC-002`), which works against §Context's multi-minute offline clock drift before NTP resync and risks silently discarding newer field notes · *coherence is adjacency* (mechanisms and specs stay consistent with the operating conditions and reconciliation intent around them)
- **F4 (medium):** Consider specifying server-to-device pull/download, equal-timestamp tie-breaking, deletes, and retry idempotency in `docs/intent/sync/sync-design.md` so reconnecting devices actually reach the HLD's *"Convergent state after reconnect"* goal · *LLDs close enough of the solution space* (an LLD narrows protocol and edge-case seams enough that independent sessions build compatible implementations without guessing)
- **F5 (medium):** Consider adding a sibling LLD for the HLD's `Device-local store` / unblocked field capture (or holding shared storage choices in the HLD) rather than keeping `Note storage` (`SQLite on device`) solely inside `docs/intent/sync/sync-design.md` · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across* (decisions shared across sibling components live in their common parent or owning node rather than tucked inside one sibling)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD (`sync`), 1 spec file (`sync-specs.md`) with 2 spec IDs (`SYNC-001`, `SYNC-002`), 0 arrow-overlay files (`docs/arrows/` not installed)
- Sampled code & tests: 0 test files and 0 source files present in the repository
- Linkage metric: 0 `@spec` references across tests and code

Want me to walk through the findings in detail, focus on a priority tier, or work through specific items like the `sync` conflict model together? You can also pick any single finding (`F1`–`F5`) to dig into.

If you have broader questions about using LID on this project — structuring sibling segments as you add the local store, walking the tests-first phase from `SYNC-001`/`SYNC-002`, when to install the arrow-maintenance overlay, or mode choices — I can help with those too.