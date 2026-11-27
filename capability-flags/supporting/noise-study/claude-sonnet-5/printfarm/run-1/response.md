## LID Coach report

**Posture:** Well-shaped design layer, but the arrow stops at specs.

**Scorecard**
- ✓ Spec hygiene: all 8 specs are EARS-shaped, use unique `QUEUE-`/`REG-` IDs, and each `WHEN` clause carries its own scope.
- ✓ HLD discipline: the HLD stays at architecture and rationale, with no schemas or signatures.
- ✓ Mutation hygiene: there is no history residue, changelog text, or `[obsolete]` markers.
- ✓ Configuration: the instruction file has the LID directive and a Full mode marker, and the standard layout exists.
- ⚠ Arrow completeness: no tests or code are present, yet every spec is marked `[x]`.
- ⚠ Decision capture: the most consequential design choice, the in-memory queue, is not in the Decisions table.
- ⚠ Design-to-intent coherence: the queue design sits in tension with the HLD's first tenet.

**Headline:** The two-node design tree is clean and well-linked, and the FIFO and upload-limit decisions are exactly the kind of rationale a cold reader can reconstruct. The most valuable next step is to settle the in-memory queue against the "a submitted job is a promise" tenet and write that decision down.

**Findings (7 total · 3 high · 3 medium · 1 low)**
- **F1 (high):** The queue is held only in memory, so accepted jobs vanish on restart and members must resubmit. That runs against the first tenet ("upload and walk away") and the overnight, no-member-present goal, on a mini-PC the LLD says takes unattended OS updates and power blips. · *intent leads; code is compiled output* (the design should serve declared intent) and *tenets capture forward-looking preference* (tenets only help if the design honors them)
- **F2 (high):** The in-memory choice appears only in Architecture prose. It has no Decisions & Alternatives row naming the rejected alternative (persisting to SQLite, which the registry already uses) or the accepted cost. A cold reader will question it and may try to reverse it. This is a separate finding from F1, and a fuller table row is enough; no decision doc is needed. · *docs carry current intent, written to be read cold* (rationale a fresh author would write belongs on the page)
- **F3 (high):** All 8 specs are marked `[x]`, but the project has no tests and no code carrying `@spec` annotations. If the implementation lives in another repo, the arrow is not walkable from here. If it doesn't exist yet, the markers are premature. · *canonical arrow shape* (HLD → LLD → EARS → tests → code) and *tests carry `@spec` annotations* (each test cites the spec it exercises)
- **F4 (medium):** QUEUE-003 marks a printer "suspect", but the registry owns printer state (idle, busy, unreachable) and never defines "suspect". Nothing says what suspect means for dispatch, how it clears, or what stops a job bouncing back to the head of the queue repeatedly. · *LLDs close enough of the solution space* (leaving edges open lets the agent guess) and *intent attaches at the lowest node that dominates it* (a state that touches both nodes belongs to the shared owner)
- **F5 (medium):** Several LLD behaviors have no spec, so nothing anchors tests to them:
  - `job-queue`: the class-has-a-printer acceptance rule, the staff/member priority classes with FIFO, and content-hash dedupe of uploads.
  - `printer-registry`: heartbeat polling at the 15 s interval, and staff registering printers (only retirement is specified).
  · *effective intent-tree alignment* (each LLD behavior traces to a spec)
- **F6 (medium):** The three HLD tenets are an unordered list, yet "a submitted job is a promise" and "the service stays small" pull against each other, and F1 is exactly where they collide. Consider ordering them so a cold session knows which way to lean. · *tenets capture forward-looking preference*
- **F7 (low):** The goal "fair access to the popular printer classes" has no design behind it beyond class-level FIFO, and the HLD has no success metrics. Consider either a sentence on what fairness means or a softer goal. · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, 2 LLDs, and 2 spec files (8 EARS specs in total).
- The decisions-table sweep covered all 5 rows. Slug recycling after 90 days is borderline but reconstructable, so it is not flagged.
- Not present: code files, test files, `@spec` references, and the arrow overlay (`docs/arrows/`), so no arrow-path sampling was possible and no segment health data was available.
- Non-interactive defaults: none were needed. Mode is declared Full.

**Offer to help:** Want me to walk through the findings in detail, focus on a theme or priority (say, the F1/F2 queue-durability question), or work through specific items together? You can also pick a specific finding to dig into. For F3, `/arrow-maintenance` can enumerate linkage precisely once code and tests exist.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.