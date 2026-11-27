**LID Coach — Field Notes**

## 1. Executive summary

**Posture:** Small, well-formed arrow; the sync design has one live coherence gap and thin decision capture.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` carries the `## LID` block, `Mode: Full`, and the directive; detection is clean
- ✓ Linkage IDs — `SYNC-001/002` are grep-anchored and match the leaf's `prefix: SYNC`; no collisions or reuse
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` residue, no changelog sections anywhere
- ⚠ Intent-tree alignment — the HLD names a device-local store that no leaf design or spec owns
- ⚠ Tenet/goal cascade — the conflict-resolution mechanism works against the HLD's convergence and capture goals under a condition the LLD itself describes
- ⚠ Arrow completeness — the arrow currently runs HLD → LLD → EARS and stops; specs are marked done

**Headline:** For a project this size the fundamentals are in good shape — the mode is declared, the one leaf has a real `prefix:`, the specs are properly EARS-shaped with genuine `WHEN` clauses, and nothing has accumulated. The highest-value next step is the conflict-resolution path in `sync-design.md`: the LLD states that device clocks are routinely minutes off, then resolves conflicts by device wall-clock and discards the loser — worth either changing or recording deliberately.

## 2. Findings inventory

**Findings (10 total · 3 high · 5 medium · 2 low)**

- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock and discards the losing edit, while `:9` states device clocks are frequently wrong by several minutes — under that stated condition a field note can be silently destroyed by an older edit, against the HLD's "no blocked capture" and "convergent state" goals, with no Decisions row recording the trade · *tenet cascade / coherence is adjacency*
- **F2 (high):** the conflict-resolution row's rationale is "Simpler." — a cold reader holding the clock-skew paragraph would still question or try to reverse this choice, and can't reconstruct what was given up (logical clocks, server-receipt ordering, keeping both edits) or what cost was accepted · *decision capture; docs carry current intent, written to be read cold*
- **F3 (high):** the HLD's Architecture names a "device-local store" and the goals lead with field capture, but no leaf design or spec covers capture or local storage — that intent is currently unnamed and drifts with nothing to test against · *effective intent-tree alignment*
- **F4 (medium):** both specs carry `[x]` done markers while the repo contains no tests or code — the status markers assert an implementation the arrow can't reach · *coherence is adjacency*
- **F5 (medium):** the arrow runs HLD → LLD → EARS and stops; the tests and code phases aren't present yet, so no `@spec` convention is established to inherit later · *canonical arrow shape*
- **F6 (medium):** the "Note storage: SQLite on device" row sits in the sync leaf, but local storage governs capture as much as sync — substance lodged in one leaf when it dominates siblings reads as sync-owned to the next session · *intent attaches at the lowest node that dominates it*
- **F7 (medium):** `## Conflict handling` leaves edges open — equal timestamps, three-or-more-device conflicts, and whether a discarded edit is logged or recoverable — so two reasonable agents would implement it differently · *LLDs close enough of the solution space*
- **F8 (medium):** the HLD has no Key Design Decisions or Success Metrics, and `## Architecture` is a three-noun list; the architecture-level *why* that should outlive any implementation isn't on the page · *HLD is architecture and rationale*
- **F9 (low):** the single tenet ("boring over clever") is a good one — real defensible opposite, a lean not a trigger — but it doesn't cover this project's actual live tension, durability of a captured note versus simplest convergence; a second tenet would pre-narrow F1-shaped calls · *tenets capture forward-looking preference*
- **F10 (low):** "reconciliation on the sync path" (HLD `:13`) doesn't resolve for a reader with no conversation context — it names a location rather than a behavior · *docs carry current intent, written to be read cold*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the project's complete file set outside `.git`
- Enumerated: 1 HLD, 1 leaf LLD, 1 spec file, 2 spec IDs, 1 arrow segment (`SYNC`)
- Arrow-path walked: 1 segment end-to-end (HLD Approach → sync LLD → `SYNC-001/002` → *no tests* → *no code*)
- Linkage metric: 0 `@spec` annotations across 0 source or test files; no `docs/arrows/` overlay installed, so no `index.yaml` to consult
- Cold-read pass: all 4 docs; Decisions-table sweep: both rows in `sync-design.md`
- Dispatch: fully configured (directives + `Mode: Full` + standard directories) → full review, no questions needed

## 4. Offer to help

Want me to walk through any of these in detail, focus on a priority tier or a theme, or work through specific items together? F1 and F2 are the pair I'd start with — they're the same choice seen from the design side and the record side, and F3 is the cheapest to close.

If you have broader questions about using LID on this project — when a second leaf is worth splitting out, where the tests phase should start given the specs are already marked done, whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.