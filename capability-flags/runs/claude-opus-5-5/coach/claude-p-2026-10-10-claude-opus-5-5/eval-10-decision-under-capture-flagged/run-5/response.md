# LID Coach — Field Notes

## Executive summary

**Posture:** Bootstrapping — the design half of the arrow is in place and clean; the downstream half and one load-bearing decision need attention.

**Scorecard**
- ✓ Configuration and mode — the `## LID` block declares Full mode, and the standard directories are present
- ✓ Linkage shape — the `SYNC` prefix resolves to its LLD, IDs are unique, and both specs are well-formed EARS
- ✓ Mutation hygiene — no history residue, obsolete markers or chat-dependent wording in any doc
- ⚠ Decision capture — the conflict-resolution row doesn't record what was given up
- ⚠ LLD sufficiency — several sync edges are left open, one of which touches the convergence goal
- ✗ Arrow completeness — there are no tests or code in the repo, yet both specs are marked `[x]`

**Headline:** The docs are short, current and easy to read cold, and the HLD → LLD → spec chain is walkable. The most valuable next step is to revisit last-writer-wins by device wall-clock against the LLD's own statement that device clocks are wrong by minutes, and record that decision properly whichever way it lands.

## Findings (8 total · 3 high · 4 medium · 1 low)

- **F1 (high):** The conflict mechanism relies on the device clocks that the LLD's Context says are "frequently wrong by several minutes", so the earlier edit can win and the newer one is silently discarded (`sync-design.md:9,17`, `SYNC-002`). The HLD goals don't say whether losing a captured edit is acceptable. · *LLDs close enough of the solution space* — a design should hold under the operating conditions it describes.
- **F2 (high):** The "Conflict resolution" row gives "Simpler." as its whole rationale (`sync-design.md:23`). A cold reader who sees the clock-skew line would question this choice and can't reconstruct which alternatives were weighed (server-receipt order, logical clocks, keeping both edits) or what cost was accepted. · *docs carry current intent, written to be read cold* — rationale a fresh author would write belongs on the page.
- **F3 (high):** `SYNC-001` and `SYNC-002` are marked `[x]`, but the repo holds no tests, no code and no `@spec` annotations. If the implementation lives elsewhere, consider saying where; if not, the markers overstate the arrow. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present or its absence explicit.
- **F4 (medium):** The HLD goal "No blocked capture in the field" and the "device-local store" architecture element have no LLD and no specs. The only trace is a "Note storage: SQLite" row sitting in the sync LLD. · *effective intent-tree alignment* — every HLD concept traces down to a design node and specs.
- **F5 (medium):** The sync LLD leaves open edges that two agents would fill differently:
  - what happens when two timestamps are equal — this bears directly on the "Convergent state" goal;
  - whether a conflict is judged per note or per field;
  - how deletions are handled;
  - what happens on partial or retried uploads;
  - what "merges" means when there is no conflict.

  · *LLDs close enough of the solution space* — specific enough that two readers land on compatible implementations.
- **F6 (medium):** Two specs cover only the happy path of upload and conflict. Nothing covers upload failure or retry, idempotent re-upload, or the non-conflicting merge the LLD describes. · *coherence is adjacency* — specs should cover the behaviours the LLD names.
- **F7 (medium):** The HLD is thin at the architecture level. Architecture is one line, and there are no key design decisions, target users or success metrics. The choice of local-first with reconcile-on-reconnect has no rationale at the level where it lives. · *HLD is architecture and rationale* — the HLD carries the long-lived "why".
- **F8 (low):** There is a single tenet, "Boring over clever". It is a real tie-breaker, but it gives no lean on the question this project meets most: data safety versus simplicity when edits collide. Consider adding one and ordering the two. · *tenets capture forward-looking preference* — tie-breakers for decisions no spec anticipated.

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`.
- **Enumerated:** 1 HLD, 1 LLD, 1 spec file with 2 specs, 0 test files, 0 code files, 0 `@spec` references. There is no arrow overlay (`docs/arrows/` is absent).
- **Decisions rows swept:** 2. "Note storage: SQLite" passes, since the "Boring over clever" tenet explains it. "Conflict resolution" is F2.
- **Dispatch:** fully configured (directives, `Mode: Full`, standard directories), so this was a full review. Nothing was edited or written to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 pair naturally.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.