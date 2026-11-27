**LID Coach — review of Field Notes**

**Posture:** Bootstrapping — intent layer is clean and coherent, but the arrow stops at EARS and the design bakes in a mechanism its own context says is unreliable.

**Scorecard**
- ✓ Mutation hygiene — no history residue, planning text, or obsolete markers anywhere
- ✓ Linkage — spec IDs are grep-friendly (`SYNC-001/002`), trace cleanly to the one LLD, LLD traces to the HLD
- ✓ Tenet quality — "Boring over clever" is a real tie-breaker with a defensible opposite
- ⚠ Cascade / goal coherence — the sync design works against a stated HLD goal under a condition its own LLD describes
- ✗ Arrow completeness — no tests, no code; the arrow currently ends at the spec layer

What's working is real: the HLD is lean and carries architecture-level *why* without implementation detail bleeding upstream, the single LLD is well-scoped to one intent component (sync), and the two EARS specs are unambiguous and correctly scoped. This is a disciplined minimal LID setup.

**Findings (4 total · 2 high · 1 medium · 1 low)**
- **F1 (high):** SYNC-002 resolves conflicts by "later device wall-clock timestamp," but the LLD's own Context states device clocks are frequently wrong by several minutes until NTP resync on reconnect — under the condition the doc itself describes, last-writer-wins-by-device-clock can discard the actually-later edit and defeat the HLD's goal "Convergent state after reconnect" · *tenets capture forward-looking preference* (mechanism works against a stated goal; the conflict is visible only when you hold the HLD's goal against the LLD's context and mechanism together)
- **F2 (high):** The arrow stops at EARS — there are no test or code files, and both specs carry `[x]` status markers claiming completion with nothing implemented · *tests before code* — the `[x]` markers are drift: a future session grepping the specs will believe implementation exists; flip them until tests and code land
- **F3 (medium):** The Decisions & Alternatives row for conflict resolution records only "Simpler." — a cold reader can't reconstruct what was given up (skew tolerance, convergence guarantees) or which alternatives were weighed (server timestamps, hybrid logical clocks) · *docs carry current intent* (decision capture: the row leaves the reasoning out for a choice a reader would question — especially given F1)
- **F4 (low):** HLD Goals and Non-Goals are bare prose lines; consider bulleting them so each goal/non-goal is individually referenceable by leaf docs and specs · *HLD is architecture and rationale* (minor, quality-of-life)

**What was audited**
- Read fully: CLAUDE.md (instruction file, Mode: Full), docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 LLD, 1 spec file, 2 specs, 0 test/code files (project contains only docs)
- No arrow overlay (`docs/arrows/`) is present; structural audit via `/arrow-maintenance` is not applicable here
- Full-mode review — no out-of-scope exclusions

**Notes on defaults taken:** the skill is advisory-only and produced no file changes (it forbids edits even though your prompt asked for them — apply fixes via direct edits or `/update-lid`); no interactive decision points arose, so no defaults were needed. The most valuable next step: resolve the clock-skew conflict in F1 before any code is written — it's the one decision that shapes everything downstream.

Want me to walk through the findings in detail, or work through specific items together — e.g., drafting an alternative conflict-resolution design for F1/F3? If you have broader questions about using LID for this project — tests-first flow, when to add the arrows overlay, mode transitions — I can help with those too.