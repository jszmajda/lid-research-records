**LID Coach — Field Notes**

## 1. Executive summary

**Posture:** Healthy shape, sparse arrow — the design layer is clean and well-linked; the risk sits in one under-captured decision that works against a stated goal.

**Scorecard**
- ✓ Configuration — `CLAUDE.md` carries the directive block, `Mode: Full`, version marker
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` markers, no stale `[inferred]` rows
- ✓ Linkage namespace — `SYNC` prefix resolves to the leaf; IDs unique, zero-padded, grep-friendly
- ⚠ Intent-tree coverage — HLD names three architecture components; one has a design node
- ✗ Arrow completeness — specs marked complete with no tests or code downstream
- ✗ Decision capture — the project's hardest call carries a one-word rationale

**Headline:** For a project this young the discipline is already real — the HLD separates problem from approach, the LLD declares `parent` and `prefix`, and both specs are properly WHEN-scoped, so the grep path works today. The highest-value next move is revisiting the conflict-resolution decision in `sync-design.md`: the LLD's own Context says device clocks are wrong by minutes, and the chosen mechanism keys on those clocks.

## 2. Findings inventory

**Findings (8 total · 3 high · 4 medium · 1 low)**

- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock, while the same doc's Context (line 9) says those clocks are wrong by several minutes — under the condition the docs themselves describe, a lagging device's newer edit is silently discarded, which works against the HLD goal *"Convergent state after reconnect"* · *tenet cascade* — design nodes should lean the way the HLD's tenets and goals say to lean, or record the exception
- **F2 (high):** the Conflict-resolution row's rationale is "Simpler." — a cold reader holding this row plus the clock-skew Context would still question the choice, and can't reconstruct what was traded or what cost was accepted · *decision capture* (the keep-side of *docs carry current intent*)
- **F3 (high):** `SYNC-001` and `SYNC-002` are marked `[x]` but the repo has no tests and no code — the arrow stops at EARS while the status markers say otherwise · *canonical arrow shape*; *tests before code*
- **F4 (medium):** the HLD's Architecture names device-local store, sync service, and reconciliation; only sync has a leaf design node and specs, so the store's intent is unnamed · *effective intent-tree alignment* — specs trace to LLDs trace to HLD, in both directions
- **F5 (medium):** the "Note storage | SQLite on device" row sits in the sync leaf though it governs the device-store component, not sync · *intent attaches at the lowest node that dominates it* — substance that governs a sibling rises to the shared parent
- **F6 (medium):** the HLD has one tenet ("Boring over clever") and none covering data preservation vs. simplicity — the exact axis F1's decision sat on, so the lean wasn't pre-narrowed when it mattered · *tenets capture forward-looking preference*
- **F7 (medium):** the HLD has no Key Design Decisions section and no success metrics; Goals is two sentences of prose · *HLD is architecture and rationale* — the HLD is where architecture-level *why* lives
- **F8 (low):** the HLD's Architecture section is a single clause listing parts, with no rationale for local-first-plus-central-merge over the alternatives · *HLD is architecture and rationale*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 leaf LLD, 1 spec file, 2 EARS specs, 2 Decisions & Alternatives rows
- Arrow-path walked: 1 segment, HLD Architecture → `SYNC` leaf → specs → (no tests) → (no code)
- Linkage metric: 0 `@spec` annotations found — no source or test files exist in the repository
- Overlay: `docs/arrows/` absent, so no `index.yaml` cross-check; structural findings are pattern-level only
- Passes run: dimension sweep, cold-read pass through all four docs, Decisions-table sweep (2 rows: 1 passes, 1 flagged as F2)
- This review was non-interactive, so no dispatch questions were put to you; the project read as fully configured (directives + `Mode: Full` + standard directories), which selects a full review, and the report is rendered inline rather than persisted — the skill's default.

## 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? F1 and F2 are the same choice seen from two angles — happy to start there, or pick any finding to dig into.

If you have broader questions about using LID for your project — where to put the device-store design node, how to sequence tests-before-code from here, multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.