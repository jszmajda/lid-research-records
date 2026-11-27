# LID Coach — printfarm

**Posture: Solid design layer; the arrow stops at EARS.**

**Scorecard**
- ✓ Configuration — instruction file is fully LID-shaped: directives, `## LID` mode marker (Full), navigation table
- ✓ Tenet quality — three real tie-breakers with defensible opposites (*tenets capture forward-looking preference*)
- ✓ Mutation hygiene — no history residue, no obsolete markers; docs read cold
- ✗ Arrow completeness — HLD → LLD → EARS exist, but no Tests or Code phase anywhere in the repo
- ⚠ Tenet cascade — the "promise" tenet is defeated by the restart design, with no recorded exception
- ⚠ Intent-tree alignment — some LLD behaviors have no spec; cross-node vocabulary ("suspect") doesn't resolve

The design layer is genuinely good: two clean nodes that mirror the HLD's Architecture section, terse Decisions tables that name accepted costs, tenets that would actually settle an argument. The fastest wins are reconciling the arrow's missing downstream phases and recording the durability trade-off that the tenet conflict exposes.

**Findings (9 total · 3 high · 4 medium · 2 low)**

- **F1 (high):** every spec carries an `[x]` completion marker, yet the repo contains zero tests and zero code, and no doc says where implementation lives — either the markers overstate progress or the Tests → Code phases live outside this repo with no stated `@spec` convention · *canonical arrow shape* (a phase missing or collapsed should be explicit, not drifted into) and *tests before code*
- **F2 (high):** job-queue's in-memory queue discards accepted jobs on restart ("jobs… are gone, and members resubmit them") — which directly defeats the tenet "a submitted job is a promise: upload and walk away," and no Decisions row records the exception or names the tenet traded · *tenet cascade*
- **F3 (high):** that same durability choice survives only as design prose with no rationale — a cold reader hits "held entirely in process memory" while the registry persists to SQLite and asks why the queue doesn't; what was given up (crash safety) and what cost was accepted (member resubmission) is never stated · *docs carry current intent* — decision capture
- **F4 (medium):** LLD behaviors with no spec anywhere — "accepted only if its target class has at least one registered printer," staff/member priority ordering, and printer registration are all unnamed intent with nothing to test against · *effective intent-tree alignment*
- **F5 (medium):** QUEUE-003 has the queue "mark the printer suspect," but "suspect" is defined in no doc — the registry's state model (idle/busy/unreachable) doesn't contain it, and the queue is mutating state the registry owns · *coherence is adjacency*; substance lodged in a leaf that dominates a sibling should rise to the shared parent
- **F6 (medium):** two specs run ahead of their design — QUEUE-005 requires reordering be "recorded visibly in the queue view" and REG-003 requires retire semantics, but neither LLD body describes the mechanism · *LLDs close enough of the solution space*
- **F7 (medium):** the interface between the two nodes is unstated — job-queue says "when the registry reports a printer idle" while printer-registry only describes polling printers on an interval; a cold reader can't tell whether the registry pushes, the queue polls, or something in between · *LLDs close enough of the solution space*
- **F8 (low):** the HLD has Goals but no success metrics — "fair access to the popular printer classes" is unfalsifiable as written · *HLD is architecture and rationale*
- **F9 (low):** the tenets are an unordered list while "promise" and "stays small" genuinely conflict (durable queues cost resources) — consider an order or a one-line tie-break · *tenets capture forward-looking preference*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all 4 files under `docs/intent/` (the entire repo — 5 files outside `.git`)
- Enumerated: 2 LLDs, 2 spec files, 8 EARS IDs (`QUEUE-001`–`005`, `REG-001`–`003`), 5 Decisions rows
- Linkage metric: 0 `@spec` annotations — no code or test files exist to carry them
- Overlay: `docs/arrows/` absent, so no index to guide sampling; no `[inferred]` markers to triage

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.