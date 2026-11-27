## LID Coach Review — Field Notes

**Posture:** Clean, early-stage skeleton — the arrow is coherent where it exists, and one load-bearing decision is under-captured.

**Scorecard**
- ✓ Configuration — mode declared `Full`, LID directives present, standard dirs in place
- ✓ Linkage — grep-friendly IDs, `SYNC` prefix resolves to the sync LLD, spec file backlinks its LLD
- ✓ Mutation hygiene — docs read present-tense; no changelog residue or obsolete markers
- ⚠ Decision capture — the central conflict-resolution choice is recorded in one word
- ⚠ Arrow completeness — the arrow stops at EARS; no tests or code yet
- ⚠ HLD discipline — the architecture section is a single line and misses success metrics

**Headline:** The intent layer is genuinely walkable HLD → LLD → EARS, with tight linkage from the `SYNC` leaf to its specs; the fastest win is fleshing out the conflict-resolution decision, because the doc's own clock-skew note is the strongest argument against it.

**Findings (7 total · 1 high · 4 medium · 2 low)**
- **F1 (high):** the conflict-resolution row ("Last-writer-wins by device wall-clock — Simpler.") leaves the reasoning out, and the LLD's own Context says device clocks drift by minutes — a cold reader would question and try to reverse the choice but cannot reconstruct what was traded away · *decision capture* (decisions stay live when a cold reader would still contest them)
- **F2 (medium):** no tests or code exist for `SYNC-001`/`SYNC-002`, so tests-first can be neither confirmed nor credited · *canonical arrow shape* + *tests before code* (the test is the first consumer, loading the intended use before implementation)
- **F3 (medium):** the LLD leaves real edges open — what identifies an "edit", how offline-created notes and deletions reconcile, and which side (device or service) runs the merge · *LLDs close enough of the solution space* (open edges are where agents guess, and guesses drift)
- **F4 (medium):** HLD `## Architecture` is one line ("Device-local store, sync service, reconciliation on the sync path") with no target users, success metrics, or key design decisions · *HLD is architecture and rationale* (the *why* should outlive any implementation)
- **F5 (medium):** specs carry unexplained `[x]` markers; if `[x]` means "implemented/verified," they contradict the absence of code and tests · *docs carry current intent, written cold* (a marker must stand on its own to a fresh reader)
- **F6 (low):** the sync LLD owns both upload and reconciliation; if reconciliation grows its own design decisions it becomes a sub-HLD candidate · *one LLD per intent component — or split into a sub-HLD* (a leaf straining under depth should delegate)
- **F7 (low):** the single tenet ("Boring over clever") is a real tie-breaker, but it leans *toward* LWW and offers nothing for the data-loss side of F1 — a second tenet (e.g., "never silently lose a field note") would pre-narrow that gap · *tenets capture forward-looking preference* (pre-narrow the choice no spec anticipates)

**What was audited**
- Read fully (entire repo): `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file, 2 specs, 1 arrow segment
- Sampled end-to-end: the single `SYNC` segment (HLD → LLD → EARS); no test or code files exist to sample
- Linkage metric: 2 spec IDs (`SYNC-001`, `SYNC-002`), 0 `@spec` annotations (no code/tests present)
- Arrow overlay: `docs/arrows/` absent, so no overlay-guided sampling

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 is the one I'd start with.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Run note (non-interactive): defaults taken were Full mode (already declared), no overlay presumed since `docs/arrows/` is absent, findings reported inline without persisting to disk, and no files edited per the coach's advisory posture. No follow-up turns were taken.*