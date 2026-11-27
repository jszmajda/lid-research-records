# LID Coach Review — Field Notes

**Bootstrapping — a clean intent spine from HLD to EARS; the arrow has no tests or code yet.**

**Scorecard**
- ✓ Intent-tree alignment — the `SYNC` prefix traces cleanly spec → LLD → HLD
- ✓ EARS discipline — two well-formed `When … SHALL` specs with unique IDs
- ✓ Mutation hygiene — no history residue, obsolete markers, or changelog drift in any doc
- ⚠ LLD sufficiency — the conflict rule leaves the documented clock skew unresolved
- ⚠ Arrow completeness — Tests and Code phases are absent; no `@spec` linkage exists yet
- ⚠ HLD discipline — rationale sections are thin (no key design decisions, no metrics)

The intent spine is clean and coherent for its size, and the specs map onto the LLD without friction. The highest-value next step is resolving the wall-clock conflict rule against the clock-skew context the LLD itself names — before any implementation fixes it in place — then letting tests and code complete the arrow.

**Findings (6 total · 2 high · 3 medium · 1 low)**
- **F1 (high):** the LLD's conflict rule picks the later *device wall-clock* timestamp while the same LLD's Context says device clocks are frequently wrong by several minutes and only resync when connectivity returns; nothing says whether correction happens before upload · *LLDs close enough of the solution space* (design should settle edges, not leave them to implementation) and *coherence is adjacency* (adjacent levels should agree)
- **F2 (high):** both specs are marked `[x]` complete, but there are no tests and no code anywhere in the project · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code) and *tests before code* (tests should be the first consumer of the intent)
- **F3 (medium):** the `Conflict resolution → Last-writer-wins by device wall-clock` row's rationale is only "Simpler." — it records the choice but not what was given up (edit loss, clock trust) · *docs carry current intent* (decision capture: a cold reader needs the trade-off, not just the pick)
- **F4 (medium):** the design doesn't settle losing-edit recovery, equal-timestamp tie-breaks, or upload-failure behavior, and no spec names those behaviors · *LLDs close enough of the solution space* and *effective intent-tree alignment* (behaviors with no spec drift silently)
- **F5 (medium):** the HLD has Problem, Approach, Tenets, Goals, Non-Goals, but no Key Design Decisions, no success metrics, no explicit target users, and "Architecture" is one sentence · *HLD is architecture and rationale* (the *why* that outlives implementation)
- **F6 (low):** no `docs/arrows/index.yaml` overlay, so structural checks (orphans, reverse orphans, cascade drift) have no index to run against · *canonical arrow shape* (optional overlay — an opportunity, not a current defect)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 specs, 0 code files, 0 test files
- Arrow-path sampled: the single `SYNC` segment end-to-end (HLD → LLD → spec → test → code); the test and code legs are absent
- Linkage metric: 0 `@spec` references (no code or tests exist to carry them)
- No `docs/arrows/` overlay present

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Run note — defaults taken: Full mode (per `CLAUDE.md`, no interaction needed), review only with no files changed (advisory posture).*