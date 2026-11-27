# LID Coach Review — Field Notes

**Posture:** Bootstrapping — configuration and design layer in place; the arrow stops at EARS.

**Scorecard**
- ✓ HLD discipline — architecture-level only; real tenet; no implementation bleed
- ✓ Tenet quality — “Boring over clever” is a lean, not a platitude or a spec-shaped rule
- ✓ Mutation hygiene — all three LID docs read cold with no history residue or fossils
- ⚠ LLD sufficiency — the sync LLD names a hazard and then resolves conflicts with the hazard
- ⚠ Decision capture — the LWW row doesn’t let a cold reader reconstruct what was given up
- ✗ Arrow completeness — specs marked done, but no tests and no code exist anywhere in the repo

**What’s working:** Full-mode config is clean and coherent; the HLD stays at architecture level and carries a genuine tie-breaking tenet; SYNC-001/002 are well-scoped EARS (proper WHEN clauses, unique grep-friendly IDs, `prefix: SYNC` traces to the leaf LLD); no accumulation residue in any doc. **The most valuable next step:** tighten the sync LLD’s conflict-resolution edges (below), then write tests that cite SYNC-001/002 *before* any code — so the tests, not the implementation, pin the resolution semantics.

---

**Findings (5 total · 2 high · 2 medium · 1 low)**

- **F1 (high):** Specs SYNC-001 and SYNC-002 are marked `[x]`, but the repo has zero test files and zero code — the arrow stops at EARS · *canonical arrow shape* — HLD → LLD → EARS → Tests → Code; missing phases are silent drift unless documented, and `[x]` reads as “done” to a cold agent while nothing downstream exists. Next phase: tests citing SYNC-001/002, then code with `@spec` annotations on entry points.

- **F2 (high):** The LLD’s Context states device clocks are “frequently wrong by several minutes,” yet conflict handling picks the winner by device wall-clock timestamp — the arbiter *is* the named hazard · *LLDs close enough of the solution space* — under the operating condition the doc itself describes, wrong winners (losing the genuinely newer field edit) would be routine; two reasonable agents could diverge on whether to trust wall-clock at all. Consider a monotonic/revision-based or server-receive-order arbiter, or state why the wrong-winner rate is acceptable — and make sure tests encode whichever answer you land on.

- **F3 (medium):** The Decisions row “Conflict resolution | Last-writer-wins by device wall-clock | Simpler.” doesn’t let a cold reader reconstruct what was given up (chronological correctness under frequent skew) or what cost was accepted · *docs carry current intent* (decision capture) — holding Context + this row, a fresh reader would question and might reverse the choice; the rationale doesn’t settle it. A fuller row (what alternatives, what you traded) would.

- **F4 (medium):** The sync LLD leaves load-bearing edges open: what counts as a “pending” edit, how the service detects two edits to the same note, merge semantics for non-conflicting edits, and whether a discarded losing edit is recoverable · *LLDs close enough of the solution space* — agents could land on incompatible implementations of each.

- **F5 (low):** The “Note storage | SQLite on device | Standard embedded store.” row reads as the native, obvious choice once landed · *docs carry current intent* — the keep-side ceiling: a row that a cold reader wouldn’t question carries little live intent; fine to keep briefly or trim.

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 spec IDs; no `docs/arrows/` overlay; no code or tests in the repository (single git commit, “fixture”)
- Linkage: 2 unique spec IDs, 0 collisions, both leaf prefixes resolve; 0 `@spec` references (nothing to annotate yet)
- Non-interactive defaults taken: proceeded with a **full review** (dispatch: fully configured); report rendered **inline, not persisted to disk**; **no project files modified** (advisory posture — recommendations only)

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.