**LID Coach — Field Notes**

## Executive summary

**Posture:** Bootstrapping — upper arrow in place and well-linked; downstream phases not yet built, and one design choice argues with a stated goal.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` carries the directive block, `- Mode: Full`, and a version; nothing to reconcile
- ✓ Linkage hygiene — `SYNC-001`/`SYNC-002` are grep-anchored, zero-padded, and match the leaf's `prefix: SYNC`
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` residue, no `[inferred]` backlog; the docs read as current intent
- ⚠ Intent-tree coverage — the HLD names three architecture elements; one has a leaf design
- ⚠ Decision capture — the load-bearing conflict-resolution choice is recorded as "Simpler."
- ✗ Arrow completeness — Tests and Code phases are absent, while both specs are marked `[x]`

**Headline:** The shape here is genuinely right — a real HLD with a usable tenet, a leaf design with a Decisions table, and EARS specs that trace cleanly to their leaf prefix, which is more arrow than most projects have at this stage. The highest-value next move is to revisit the wall-clock conflict rule against the clock-skew condition your own LLD describes, before any code compiles that choice in.

## Findings (10 total · 3 high · 5 medium · 2 low)

- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock, while `sync-design.md:9` states device clocks are "frequently wrong by several minutes" — under that condition the earlier edit can win and the later one is discarded, working against the HLD goal "Convergent state after reconnect"; no Decisions row records the trade · *tenets capture forward-looking preference / keep the arrow coherent*
- **F2 (high):** the "Last-writer-wins by device wall-clock" row cites only "Simpler." — a cold reader holding the clock-skew paragraph would still want to reverse this, and can't reconstruct what was weighed or what cost was accepted · *docs carry current intent — the keep-side and its ceiling*
- **F3 (high):** both specs carry `[x]` but the repository holds no tests, no code, and no `@spec` annotations — the arrow stops at EARS while the markers claim it doesn't · *canonical arrow shape*, *coherence is adjacency*
- **F4 (medium):** `high-level-design.md:13` names a device-local store as an architecture element, but no leaf design or spec covers it — including offline capture, which is goal #1 · *effective intent-tree alignment*
- **F5 (medium):** `sync-design.md` leaves merge granularity (whole-note vs. per-field), cross-device note identity, deletion, and upload retry open; two agents would land on incompatible implementations · *LLDs close enough of the solution space*
- **F6 (medium):** the timestamp-authority decision sits in the `SYNC` leaf, but capture-time stamping belongs to the device store — it governs both siblings and reads as a shared-parent concern · *intent attaches at the lowest node that dominates it*
- **F7 (medium):** "Convergent state after reconnect" (`high-level-design.md:21`) doesn't say cold whether converging by discarding an edit counts — the ambiguity is exactly the gap F1 slipped through · *docs carry current intent, written to be read cold*
- **F8 (medium):** `sync-design.md:9` states devices resync NTP only on reconnect but never says what follows from it; a cold reader can't tell whether it constrains the design or is background · *docs carry current intent, written to be read cold*
- **F9 (low):** the HLD has no Key Design Decisions section and no success metrics; `## Architecture` is a three-noun list that doesn't give responsibilities or boundaries · *HLD is architecture and rationale*
- **F10 (low):** one tenet ("Boring over clever") is a real tie-breaker with a defensible opposite — but this project's recurring hard call is correctness vs. simplicity under bad data, and a second tenet leaning that one would have pre-decided F1 · *tenets capture forward-looking preference*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the project's entire file set
- Enumerated: 1 HLD, 1 leaf LLD, 1 spec file, 2 EARS specs, 1 Decisions & Alternatives table (2 rows)
- Arrow-path walked: 1 segment end-to-end (HLD Approach → `SYNC` leaf → `SYNC-001`/`-002` → no tests → no code)
- Linkage metric: 0 `@spec` references found across the repository; 0 orphaned or colliding spec IDs
- Cold-read pass: all 3 LID docs; Decisions-table sweep: both rows (the SQLite row passed — a cold reader backed by *boring over clever* wouldn't question it)
- Arrow overlay (`docs/arrows/`) not installed, so no structural index was available; git history is a single `fixture` commit, which gives no tests-first signal either way

---

Want me to walk through the findings in detail, focus on a theme or priority — the F1/F2/F6/F7 cluster is really one knot around the timestamp decision — or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — how to grow the design tree as the device store and sync service each gain depth, where tests-first fits when you're still docs-only, or when a leaf warrants promotion to a sub-HLD — I can help with those too. I haven't changed any files; the coach is advisory, so configuration changes route through `/update-lid` and structural enumeration through `/arrow-maintenance`.