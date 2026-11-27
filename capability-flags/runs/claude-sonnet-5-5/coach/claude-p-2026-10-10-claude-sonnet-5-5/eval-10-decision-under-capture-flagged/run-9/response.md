# LID Coach report: Field Notes

## Executive summary

**Posture:** Well-shaped and young. The arrow is in place, and the main drift is in one conflict-handling decision.

**Scorecard**
- ✓ Configuration: `CLAUDE.md` declares LID with Full mode, and the standard `docs/` layout is present
- ✓ Design-tree shape: one HLD, one LLD with `parent:` and `prefix:` frontmatter, and spec IDs that trace to `SYNC`
- ✓ Doc hygiene: no history residue, no `[obsolete]` markers, no conversation-dependent phrasing
- ✓ Spec form: both specs are EARS-shaped, uniquely numbered, and correctly scoped
- ⚠ Tenet and goal cascade: the sync conflict rule works against the HLD's problem statement and goals
- ⚠ Decision capture: the conflict-resolution row doesn't record what was given up
- ⚠ LLD sufficiency: the merge path leaves several edges open

**Headline:** The HLD is concise and carries a real tenet, and the LLD and specs link cleanly to it. The most valuable next step is to revisit last-writer-wins by device wall-clock, which your own LLD says is unreliable, and record the reasoning either way.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** Conflict resolution by device wall-clock discards edits, yet the LLD's own Context says device clocks are often minutes wrong. This can silently lose the technician's actual latest edit, which cuts against the HLD problem ("notes must reconcile") and goals. · *tenets capture forward-looking preference* (the lean should cascade into designs; gloss: leaf mechanisms should pull the way the HLD's tenets and goals do)
- **F2 (high):** The Decisions row "Last-writer-wins by device wall-clock — *Simpler.*" doesn't say what was given up (silent data loss under clock skew, ties) or why that cost is acceptable. A cold reader would question this choice and couldn't reconstruct the trade-off. · *docs carry current intent, written to be read cold* (decisions that stay live need their reasoning on the page)
- **F3 (medium):** The Architecture and Conflict handling sections leave open how pending edits are merged (granularity of a "same note" conflict, non-conflicting edits, equal timestamps, interrupted uploads, ordering). Two agents could implement compatible-looking but different behavior. · *LLDs close enough of the solution space* (specific enough that independent readers land on compatible implementations)
- **F4 (medium):** Only two specs exist, and they cover the upload and the conflict winner. Behaviors such as a failed or partial upload, retry on the next reconnect, and the convergence goal itself have no spec to test against. · *effective intent-tree alignment* (LLD and HLD behaviors should have specs, or they drift unnamed)
- **F5 (low):** Both specs are marked `[x]`, but the repo has no code, tests, or `@spec` annotations. I couldn't verify the markers, and the arrow stops at EARS here. If the implementation lives elsewhere, a one-line pointer in the LLD would help. · *tests carry `@spec` annotations* / *canonical arrow shape*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 specs), no code or test files, no arrow overlay (`docs/arrows/` absent)
- Cold-read pass: all four docs
- Decisions-table sweep: both rows. "SQLite on device" passes, since the "Boring over clever" tenet explains it. The conflict-resolution row is F2.
- Not run: structural enumeration. If you add the overlay, `/arrow-maintenance` covers that.

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.