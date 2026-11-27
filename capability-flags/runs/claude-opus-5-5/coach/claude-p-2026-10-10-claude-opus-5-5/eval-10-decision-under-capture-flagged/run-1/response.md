# LID Coach — Field Notes

## Executive summary

**Posture:** Bootstrapping — clean design spine, but the arrow stops at specs and the one consequential decision is thinly recorded.

**Scorecard**
- ✓ Configuration and mode — `## LID` block, Full mode, HLD and `docs/intent/` are all in place.
- ✓ Mutation hygiene — all three docs read as current intent, with no history residue or chat-dependent phrasing.
- ✓ Linkage and tree alignment — `SYNC-001` and `SYNC-002` resolve to the `prefix: SYNC` leaf, which traces to the HLD's sync path.
- ⚠ Tenet and goal cascade — the conflict mechanism leans on device clocks that the same LLD says are unreliable.
- ⚠ LLD sufficiency and decision capture — several edges of sync are open, and the key row's rationale is one word.
- ✗ Arrow completeness — specs are marked `[x]`, but the repository has no tests or code.

**Headline:** The spine is small, legible and well-linked, and the HLD's single tenet is a real tie-breaker. The most valuable next step is to revisit last-writer-wins by device wall-clock against the clock skew that `sync-design.md` itself describes, and record what that choice gives up.

## Findings (8 total · 3 high · 4 medium · 1 low)

- **F1 (high):** Conflict resolution picks the winner by device wall-clock (`sync-design.md:17`, `SYNC-002`), while the same LLD says device clocks are "frequently wrong by several minutes" (`:9`). Under that condition a device with a fast clock wins over a later edit, and a technician's note is silently discarded. Consider whether that still meets the HLD goal "Convergent state after reconnect" in the sense you intend. · *tenet cascade* — leaf designs should lean the way the HLD's tenets and goals point.
- **F2 (high):** The conflict-resolution row's rationale is "Simpler." (`sync-design.md:23`). A cold reader would question this choice given F1 and cannot reconstruct what was weighed or what cost was accepted; the row also has no alternatives column. Consider a fuller row. · *docs carry current intent, written to be read cold* — a decision that stays contestable needs its trade-off on the page.
- **F3 (high):** Both specs carry `[x]`, but the repository contains only docs, with no tests, no code and no `@spec` annotations. Consider resetting the markers, or landing tests and then code. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, each phase present; and *tests before code*.
- **F4 (medium):** The sync LLD leaves edges open that two implementers would fill differently:
  - what an "edit" is (whole note or field);
  - how timestamp ties resolve;
  - how deletes are handled;
  - upload failure and retry;
  - how the merged state gets back to devices, which the convergence goal depends on.
  
  · *LLDs close enough of the solution space* — specific enough that two agents would build compatible implementations.
- **F5 (medium):** The HLD names a device-local store and a "No blocked capture" goal, but no LLD or spec covers capture or storage. The "SQLite on device" decision sits in the sync LLD's table instead. Consider a store/capture LLD to own it. · *one LLD per intent component*, and *intent attaches at the lowest node that dominates it* — a decision lives with the component it governs.
- **F6 (medium):** The HLD is skeletal: Architecture is one line, and there are no target users, key design decisions or success metrics. Consider filling these in, since the reconciliation strategy in F1 is an architecture-level call that currently has nowhere to live upstream. · *HLD is architecture and rationale* — the HLD carries the long-lived "why".
- **F7 (medium):** `SYNC-002` covers only "two devices … while offline". Cases with three or more devices, or an offline edit against a note changed by an online device, are unaddressed. · *scope disambiguation* — a spec's trigger should state exactly where it applies.
- **F8 (low):** The single tenet, "Boring over clever", is well-formed, but it does not lean on the trade-off this project hits first: data preservation versus simplicity. Consider adding a second, ordered tenet for it. · *tenets capture forward-looking preference* — one-line tie-breakers for decisions no spec anticipated.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`.
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 specs, 2 Decisions rows, 0 test files, 0 code files, 0 `@spec` references.
- No arrow overlay (`docs/arrows/`) is present, so there was nothing to sample there.
- Passes run: dimension review, cold-read pass over every doc, and a Decisions-table sweep. The "Note storage: SQLite" row passes the sweep as written; only its placement is noted (F5).
- This is an advisory review; no files were changed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.