# LID Coach — Field Notes

**Posture:** Healthy design spine, incomplete arrow.

**Scorecard**
- ✓ **Configuration & mode fit** — Full mode declared in `CLAUDE.md:1-3`, directives present, no scope drift
- ✓ **HLD discipline & tenet quality** — architecture-level only, no implementation bleed; "boring over clever" is a real tie-breaker
- ✓ **Mutation hygiene** — no history residue, no `[obsolete]` markers, IDs unique and stable
- ⚠ **LLD sufficiency & decision capture** — thin rationale rows, key terms undefined
- ⚠ **Intent-tree alignment** — the note-store component named in the HLD has no LLD or spec
- ✗ **Arrow completeness** — arrow stops at EARS; no tests, no code, yet both specs are marked implemented

The design spine is clean and well-formed — one HLD, one leaf LLD, two greppable EARS specs, no residue, and a tenet that genuinely guides choices. The fastest wins are closing the arrow into tests and code, and opening back the conflict-resolution decision, which the same LLD's own clock-skew note undermines.

**Findings (9 total · 3 high · 4 medium · 2 low)**
- **F1 (high):** both specs are marked `[x]` (*status marker = code and tests exist*) in `docs/intent/sync/sync-specs.md:5-6`, but the repo contains zero tests and zero source files — the arrow has no Tests or Code phase · *canonical arrow shape (HLD → LLD → EARS → Tests → Code)* and *coherence is adjacency (each level agrees with the one beside it)*
- **F2 (high):** conflict resolution is last-writer-wins by device wall-clock, yet the same LLD states device clocks are "wrong by several minutes" (`docs/intent/sync/sync-design.md:9,17`) — under that stated condition the mechanism can converge on the wrong edit, defeating the HLD goal "Convergent state after reconnect," with no record of the trade-off · *tenet cascade (design nodes should lean the way the HLD's goals say)*
- **F3 (high):** the Conflict-resolution row's rationale is "Simpler." with no alternatives considered and no statement of what was given up (the losing edit is discarded, silently) — a cold reader would question this choice and cannot reconstruct the cost accepted · *docs carry current intent — live decisions stay legible; git preserves history*
- **F4 (medium):** "canonical store" and "pending edits" are never defined; no protocol, partial-failure, or idempotency behavior is specified, so two agents reading `docs/intent/sync/sync-design.md` would implement incompatible reconcilers · *LLDs close enough of the solution space — specific enough that agents land on compatible implementations*
- **F5 (medium):** SYNC-001/002 both say "the system" while the design has two systems (device and sync service); SYNC-002 never says which side performs the merge · *scope disambiguation — a universal-sounding spec must actually be universal when found by grep*
- **F6 (medium):** the HLD omits Target Users, Key Design Decisions, and Success Metrics, and its Goals ("No blocked capture in the field") are not falsifiable — Full mode expects every HLD section filled · *HLD is architecture and rationale*
- **F7 (medium):** the HLD names a device-local note store as a component, but the only LLD is `sync`; the SQLite note-storage decision (`sync-design.md:24`) therefore has no spec and no owning node · *effective intent-tree alignment — specs trace to LLDs trace to HLD*
- **F8 (low):** the LLD never states how the device-local SQLite store relates to the central canonical store (which is authoritative, what syncs back to devices), so the two docs read as separate systems · *docs carry current intent, written to be read cold*
- **F9 (low):** the single tenet governs novelty only; the one genuinely contested choice in the project — discarding a field edit — had no tie-breaker to lean on · *tenets capture forward-looking preference*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — 4 of 4 tracked files, 100% of the repository's documentation
- Enumerated: 1 HLD, 1 LLD (1 leaf, no sub-HLD), 1 spec file, 2 EARS specs (both event-driven and well-formed, IDs `SYNC-001`/`SYNC-002` unique and matching the leaf's `prefix: SYNC`)
- Linkage metric: 0 `@spec` references, 0 source files, 0 test files — no code paths existed to sample
- Ran a cold-read pass over every LID doc and a decisions-table sweep over both rows
- No arrow-maintenance overlay (`docs/arrows/` absent), so `index.yaml` was not read and no structural enumeration was performed
- Git history: a single commit ("fixture"), so there is no prior state to compare against
- Defaults taken (non-interactive run): reviewed in the declared Full mode; took the skill's default of proceeding where interaction would be requested (no scope prompts, no follow-up clarification); applied the skill's advisory posture, so no files were changed and nothing was written to disk

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.