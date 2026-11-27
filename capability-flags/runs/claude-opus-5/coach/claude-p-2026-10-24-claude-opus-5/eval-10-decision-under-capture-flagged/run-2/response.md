**LID Coach — Field Notes**

## Executive summary

**Posture:** Early and clean — the intent layer is coherent; the arrow stops short of tests and code.

**Scorecard**
- ✓ Mutation hygiene — no change-narration, no obsolete markers, no planning residue anywhere
- ✓ Linkage shape — `prefix: SYNC` frontmatter, spec file names its LLD, IDs are grep-clean and zero-padded
- ✗ Arrow completeness — both specs are marked `[x]` but no tests or code exist in the repo
- ⚠ Decision capture — the load-bearing conflict-resolution choice is recorded as "Simpler."
- ⚠ Tenet/goal cascade — the merge mechanism works against a stated goal under a condition the LLD itself describes
- ✓ Mode fit — Full mode suits a project this small and this self-contained

**Headline:** For a four-file project the discipline is genuinely good — HLD stays at architecture, the LLD declares its parent and prefix, specs are EARS-shaped and properly WHEN-scoped, and nothing has accumulated. The single most valuable next step is to look again at last-writer-wins by device wall-clock: the LLD's own Context says those clocks are wrong by minutes, and that tension is neither resolved in the design nor recorded as a trade-off.

## Findings (7 total · 3 high · 2 medium · 2 low)

- **F1 (high):** `SYNC-001`/`SYNC-002` carry `[x]` status but the repo has no tests and no code — the arrow currently ends at EARS · *coherence is adjacency* — each level agrees with the one next to it, and *tests before code*
- **F2 (high):** `sync-design.md:17` resolves conflicts by device wall-clock while `sync-design.md:9` states device clocks are wrong by several minutes; under that condition the HLD's goal "Convergent state after reconnect" and its no-lost-capture intent are undercut, and no Decisions row records the exception · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets and goals say to lean
- **F3 (high):** the conflict-resolution row's rationale is "Simpler." — a cold reader holding this LLD would still question or try to reverse the choice, and can't reconstruct what was given up (discarded edits) or what was weighed (server receipt time, logical clocks) · *decision capture* — a decision that stays live once landed needs its cost on the page
- **F4 (medium):** the HLD's Architecture names a device-local store, but it has no design node; its storage choice (`SQLite on device`) sits in the sync LLD's Decisions table instead · *effective intent-tree alignment* and *intent attaches at the lowest node that dominates it*
- **F5 (medium):** the clock-skew sentence in `## Context` is introduced and then never acted on in the design — it reads as context the author was holding mid-thought rather than finished intent · *docs carry current intent, written to be read cold*
- **F6 (low):** the HLD has no success-metrics section; Goals are prose ("No blocked capture in the field") with nothing to measure convergence against · *HLD is architecture and rationale*
- **F7 (low):** one tenet ("Boring over clever") for a project whose hardest calls are about ordering and consistency — a second tie-breaker on data loss vs. simplicity would pre-narrow exactly the decision F2 and F3 sit on · *tenets capture forward-looking preference*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the project's entire file set (4 files, 71 lines)
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs, 1 EARS segment (`SYNC`), 2 Decisions rows
- Arrow-path walked: 1 segment end-to-end (HLD Architecture → sync LLD → `SYNC-001`/`SYNC-002` → tests → code); the tests and code phases are empty
- Linkage metric: 0 `@spec` annotations found in the repo (no source or test files present)
- Arrow-maintenance overlay: not installed (`docs/arrows/` absent) — structural checks were done by direct read rather than by index
- Dispatch: fully configured (LID directives present, `- Mode: Full`, standard directories) → full review. No interactive choices arose; Full mode was read from the marker, not defaulted.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F2 and F3 are closely linked and worth taking as a pair.

If you have broader questions about using LID on this project — when to split the device-local store into its own LLD, how to bring tests into the arrow from here, what `[x]` should mean before code exists — I can help with those too.