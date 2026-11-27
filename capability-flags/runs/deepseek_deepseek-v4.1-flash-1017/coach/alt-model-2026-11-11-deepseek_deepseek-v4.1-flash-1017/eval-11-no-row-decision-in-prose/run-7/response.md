## LID Coach Review — printfarm

**Posture:** Solid intent-first foundation, with unclosed seams in contracts and goal coverage.

**Scorecard**
- ✓ Configuration & mode — Full mode declared, directives coherent, HLD and `docs/intent/` both present
- ✓ Arrow foundation — HLD → 2 LLDs → 8 EARS specs; prefixes resolve to their leaf LLDs
- ✓ Mutation hygiene — docs read as current intent; no changelog or history residue
- ⚠ Intent-tree completeness — behavior specified for surfaces (web UI) that no design node owns
- ⚠ LLD sufficiency & contracts — `suspect`, printer classes, and state ownership left open
- ⚠ Tenet & goal cascade — the "job is a promise" tenet and the fairness goal aren't carried into mechanisms
- ⚠ Status & tests — every spec is `[x]`, no legend for the marker, and no tests or code exist

**The HLD reads freshly and the two design nodes are cleanly linked to their specs — the fastest wins are closing the queue↔registry contract and reconciling the in-memory queue with the promise tenet before code begins.**

### Findings (8 total · 3 high · 3 medium · 2 low)

- **F1 (high):** The HLD goal "fair access to the popular printer classes" has no mechanism in either LLD — FIFO within a class only orders arrival, and the Problem's long-job monopolization is answered only by "mitigated by staff reordering" in the Decisions table · *tenet cascade* (design nodes should lean the way the HLD's goals and tenets point)
- **F2 (high):** `job-queue-design.md` states accepted-but-undispatched jobs are gone on restart, under the very conditions its Context names (unattended OS updates, power blips) — directly against the HLD tenet "a submitted job is a promise: members should be able to upload and walk away," with no Decisions row recording the trade · *tenet cascade* and *decision capture* (decisions stay live once landed, and are recorded with what was given up)
- **F3 (high):** Printer state ownership is split: `QUEUE-003` tells the queue to "mark the printer suspect," while `printer-registry` owns printer state and never defines `suspect` or relates it to `unreachable` — the queue↔registry contract is open · *intent attaches at the lowest node that dominates it* (state changes belong to the node that owns the state) and *LLDs close enough of the solution space*
- **F4 (medium):** Upload rejection (`QUEUE-001`), the queue view, and staff reordering (`QUEUE-005`) describe a member/staff web UI, but the HLD declares only two design nodes and no LLD owns that surface — behavior without an owning intent component · *effective intent-tree alignment* (specs trace to LLDs trace to HLD)
- **F5 (medium):** All eight specs are marked `[x]` with no legend defining the marker, and the repo contains no tests or code — a cold reader can't tell whether `[x]` means "approved" or "implemented," and the completion claim is unbacked · *docs carry current intent, written to be read cold* and *tests before code*
- **F6 (medium):** The HLD has Goals but no success metrics; "fair access" and "morning pickup" aren't measurable, so the arrow has no way to say later whether intent was met · *HLD is architecture and rationale*
- **F7 (low):** The `printer-registry` Decisions rows record a rationale but omit the alternatives considered and accepted cost for heartbeat interval and SQLite store, so a cold reader can't reconstruct what was traded · *decision capture*
- **F8 (low):** The three tenets are unordered though at least two can conflict (promise-to-member vs. staff override) — ordering would tell a future session which lean wins · *tenets capture forward-looking preference*

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs, both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs; both leaf prefixes (`QUEUE`, `REG`) resolve to their LLD frontmatter
- No source, tests, or build files exist; no `docs/arrows/` overlay present
- Linkage metric: 0 `@spec` references (nothing to annotate yet); git history is a single commit, so tests-first ordering isn't observable
- Adjacency coherence (spec ↔ test ↔ code) is not assessable until implementation exists

### Offer to help
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.