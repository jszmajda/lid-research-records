# LID Coach — Field Notes

## Executive summary

**Posture:** Bootstrapping — the design half of the arrow is in place and coherent; one load-bearing decision is under-captured, and the test/code half isn't here yet.

**Scorecard**
- ✓ Configuration & mode — directives, `Mode: Full`, HLD and `docs/intent/` all present; Full fits a single-product repo
- ✓ Spec hygiene — clean EARS phrasing, stable `SYNC-NNN` IDs resolving to the LLD's `prefix: SYNC`, triggers scoped in their WHEN clauses
- ✓ Adjacent-level coherence — SYNC-002 says exactly what the LLD's Conflict handling section says; no history residue anywhere
- ⚠ Decision capture — the conflict-resolution row gives a one-word rationale for the choice a reader is most likely to challenge
- ⚠ LLD sufficiency — the merge path and several conflict edges are left open
- ✗ Arrow completeness — no tests or code in the repo, though both specs are marked `[x]`

**Headline:** The HLD → LLD → specs chain is short, readable cold, and internally consistent. The most valuable next step is to write down what last-writer-wins by device clock gives up, because the LLD's own Context says those clocks are wrong by minutes.

## Findings (7 total · 3 high · 3 medium · 1 low)

- **F1 (high):** The conflict-resolution row's rationale is "Simpler." — it names no alternative considered and no cost accepted (a technician's edit is discarded) · *docs carry current intent, written to be read cold* (a decision a cold reader would still question needs its trade-off on the page)
- **F2 (high):** Wall-clock last-writer-wins sits beside a Context stating device clocks are "frequently wrong by several minutes", so the older edit can win and the newer one is silently dropped; consider whether that is the intended behaviour. This is a design concern separate from F1's capture gap · *LLDs close enough of the solution space* (a design should be specific enough that two agents land on compatible implementations — and that its stated conditions don't undercut its mechanism)
- **F3 (high):** SYNC-001 and SYNC-002 are marked `[x]`, but the repo holds no tests, no code and no `@spec` annotations · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code; each phase exists, or its absence is deliberate and stated)
- **F4 (medium):** The HLD goal "No blocked capture in the field" and the device-local store have no LLD and no specs; the SQLite decision is lodged in the Sync LLD instead · *effective intent-tree alignment* (every HLD concept traces down to a design node and specs)
- **F5 (medium):** The Sync LLD leaves edges open: what "merges them into the canonical store" does, what happens on equal timestamps, how deletes versus edits resolve, and whether the timestamp is edit time or upload time · *LLDs close enough of the solution space* (open edges are where agents guess)
- **F6 (medium):** The HLD's Architecture is a single line, and it has no target users, key design decisions or success metrics · *HLD is architecture and rationale* (the HLD carries the long-lived "why")
- **F7 (low):** The single tenet, "Boring over clever", is a real tie-breaker, but nothing says which way to lean between simplicity and never losing a technician's note — the tension F1 and F2 turn on · *tenets capture forward-looking preference* (one-line leans for decisions no spec anticipated)

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the whole repo is these four tracked files in one commit
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs, 2 Decisions rows (the SQLite row passes — the tenet already explains it)
- Code and tests: none present to sample; 0 `@spec` references
- Arrow overlay: `docs/arrows/` is not installed, so there was no index to consult
- Non-interactive run: dispatch resolved to a full review with no prompts needed, and nothing was edited or written to disk

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.