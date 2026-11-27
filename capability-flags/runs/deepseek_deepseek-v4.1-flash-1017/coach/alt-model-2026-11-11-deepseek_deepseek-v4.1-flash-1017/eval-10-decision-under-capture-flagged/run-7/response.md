**LID Coach — Field Notes**

**Posture:** Solid scaffolding, one load-bearing decision needs tightening. The arrow is clean from HLD through EARS and the configuration is coherent; the sharpest issue is a conflict-resolution choice that runs against the project's own stated clock reality.

**Scorecard**
- ✓ Configuration — LID directives present, `- Mode: Full`, pointer to the workflow skill is intact
- ✓ Mutation hygiene — no history residue, changelogs, or obsolete markers anywhere
- ✓ Linkage naming — IDs `SYNC-001/002` resolve cleanly to the `SYNC` leaf and its `prefix:` frontmatter
- ⚠ Decision capture — the conflict-resolution row is under-justified against the clock caveat in the same doc
- ⚠ Tenet/goal cascade — last-writer-wins on device wall-clock sits against the "convergent state" goal under the described clock-skew condition
- ⚠ HLD completeness — architecture-level and clean, but missing Success Metrics, Key Design Decisions, and an explicit Target Users section

The HLD/LLD/spec skeleton is well-formed and the tenet is a genuine tie-breaker; the highest-value next step is to resolve the wall-clock conflict decision and record what it costs.

**Findings (6 total · 2 high · 3 medium · 1 low)**
- **F1 (high):** Conflict resolution uses later *device wall-clock* timestamp even though the same LLD says device clocks are "frequently wrong by several minutes"; the Decisions row rationale is only "Simpler." and never names what was given up · *decision capture* (a live choice a cold reader would question, with the reasoning left off the page)
- **F2 (high):** Last-writer-wins on device wall-clock works against the "convergent state after reconnect" goal under the clock-skew condition the LLD itself describes, and no Decisions row records the trade · *tenet cascade* (mechanisms should lean the way the HLD's goals say to lean)
- **F3 (medium):** The arrow stops at EARS — no tests and no code exist for `SYNC-001`/`SYNC-002` · *tests before code* / *canonical arrow shape*
- **F4 (medium):** The LLD describes the sync service *merging pending edits into the canonical store*, but only upload and conflict cases have specs — the non-conflicting merge path is unnamed · *effective intent-tree alignment* (LLD behaviors with no spec)
- **F5 (medium):** HLD omits Success Metrics, Key Design Decisions, and an explicit Target Users section (users appear only inside Problem) · *HLD is architecture and rationale*
- **F6 (low):** `SYNC-002` is scoped to "two devices"; device-vs-service contention and 3+ device cases fall outside its WHEN clause · *scope disambiguation*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs (`SYNC-001`, `SYNC-002`)
- Code/tests: 0 source files, 0 test files, 0 `@spec` annotations found
- Overlay: no `docs/arrows/index.yaml`; no arrow segments to sample

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Run notes (non-interactive defaults): treated the project as Full mode per its `- Mode: Full` marker; did not persist the report to disk; kept advisory posture (no files edited); ended at the report rather than entering a follow-up turn.*