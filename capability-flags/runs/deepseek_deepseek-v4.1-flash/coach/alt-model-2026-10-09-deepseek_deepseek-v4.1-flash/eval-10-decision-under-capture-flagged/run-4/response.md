# LID Coach — Review

**Posture:** Clean and well-linked through the specs; the arrow stops short of tests and code, and one design decision needs capturing. *(Bootstrapping — arrow defined, implementation not yet reached.)*

**Scorecard**
- ✓ Configuration — Full mode declared and well-formed in `CLAUDE.md`; no scope needed
- ✓ Linkage — spec IDs (`SYNC-001/002`) and the LLD `prefix: SYNC` align cleanly
- ✓ Mutation hygiene — no history residue, changelog, or `[obsolete]` markers in any doc
- ⚠ Arrow completeness — phases stop at EARS; no Tests or Code for the sync component
- ⚠ Decision capture — the conflict-resolution rationale ("Simpler.") leaves the tradeoff unstated
- ⚠ HLD coverage — target users, success metrics, and key design decisions are absent

**Headline:** The design-to-spec chain is coherent and free of accumulation drift; the fastest wins are closing the arrow (tests + code) and capturing *why* last-writer-wins was chosen given the LLD's own note that device clocks are unreliable.

**Findings (4 total · 1 high · 3 medium)**
- **F1 (high):** the arrow ends at EARS — no tests, no code, no `@spec` bindings for this component · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code) and *tests before code*
- **F2 (medium):** the conflict-resolution row's rationale is just "Simpler." — it names neither the alternative considered nor the cost accepted · *docs carry current intent* (decision capture)
- **F3 (medium):** conflict resolution keys on device wall-clock, yet the LLD states clocks are "frequently wrong by several minutes" and only resync on reconnect — a genuinely-later edit can be discarded as if it were older · *LLDs close enough of the solution space* (design concern; note LWW still converges, but ordering is untrustworthy). Consider a clock-agnostic tiebreaker or server-assigned ordering.
- **F4 (medium):** the HLD lacks Target Users, Success Metrics, and Key Design Decisions sections — the architecture-level *why* is thin · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 LLD, 1 spec file (2 specs), 0 test files, 0 code files
- Arrow-path sampling: not triggered (project is far below the 15-LLD / 200-`@spec` thresholds; no `docs/arrows/index.yaml` overlay)
- Linkage metric: 0 `@spec` references across the repo (no code or tests exist yet)

*(Capability-flag note omitted: `references/capability-flags.md` lists no flagged configurations. Out-of-scope note omitted: Full mode.)*

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Run defaults taken: Full mode from the `## LID` marker; no capability flags applied (none listed); no files edited and no report persisted (advisory posture).*