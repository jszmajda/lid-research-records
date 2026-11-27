## printfarm LID coach report

**Posture:** Healthy foundation, with one design decision the tenets don't back up. The specs have also outrun the LLDs and any implementation evidence.

**Scorecard**
- ✓ Configuration: the LID directive and `Mode: Full` are in place, and the HLD and both LLDs are at the standard paths.
- ✓ HLD discipline: it is all architecture and rationale, with no implementation detail leaking in.
- ✓ Spec hygiene: IDs are unique and grep-friendly, and every spec is EARS-shaped and scoped in its WHEN clause. The `QUEUE-` and `REG-` prefixes match the LLD `prefix:` frontmatter.
- ✓ Accumulation: I found no changelog residue, `[obsolete]` specs or `[inferred]` markers.
- ⚠ Decision capture and tenet fit: the in-memory queue conflicts with tenet 1, and the cost isn't captured.
- ⚠ Adjacent-level coherence: the LLDs and specs disagree at several seams.
- ⚠ Implementation linkage: every spec is marked `[x]`, but there is no code or test evidence in the repo.

**Headline:** The arrow's top half is real and well-written. Both LLDs carry rejected alternatives and accepted costs, and the specs are crisp. The most valuable next step is to settle whether the in-memory queue is a decision you want to keep, given the "a submitted job is a promise" tenet.

**Findings (8 total · 2 high · 4 medium · 2 low)**
- **F1 (high):** The job queue is held only in memory, so accepted-but-undispatched jobs are lost on restart, against the "upload and walk away" tenet and the overnight goal. The mini-PC takes unattended OS updates. · *Docs carry current intent* (the design concern), and *intent leads; code is compiled output* (the design contradicts declared intent).
- **F2 (high):** The in-memory choice has no Decisions & Alternatives row, so a cold reader can't see what was rejected or what cost was accepted. The registry's SQLite store, by contrast, has a row. This is a separate finding from F1 and still worth a row even if you keep the design. A decision doc isn't warranted. · *Decision capture*
- **F3 (medium):** All eight specs are marked `[x]`, yet the project contains no source or tests, so nothing carries `@spec` annotations. Either the code lives elsewhere or the markers are ahead of reality. Tests-first can't be assessed. · *Tests carry @spec annotations*, *tests before code*
- **F4 (medium):** The LLDs and specs are out of step:
  - QUEUE-005 (staff reordering must be visible) has no counterpart in the job-queue LLD. The Prioritization section never mentions reordering.
  - The LLD rule that a job is accepted only if its class has a registered printer has no spec.
  - The staff/member priority classes and FIFO ordering have no spec.
  - Slug recycling after 90 days has no spec.
  
  For the structural enumeration, run `/arrow-maintenance`. · *Coherence is adjacency*
- **F5 (medium):** The seam between the two nodes is thin:
  - QUEUE-003 marks a printer "suspect", but the registry LLD never defines that state (it describes idle, busy and unreachable).
  - QUEUE-002 depends on the registry "reporting idle", but no registry spec or LLD text defines that notification.
  
  · *Intent attaches at the lowest node that dominates it*, *LLDs close enough of the solution space*
- **F6 (medium):** Dispatch failure is under-specified. A failed job returns to the head and the printer is marked suspect, but nothing says whether suspect printers still receive dispatches or how they recover. Two agents could build different behavior, including a retry loop on the same printer. · *LLDs close enough of the solution space*
- **F7 (low):** The tenets aren't ordered, and they can conflict. "A submitted job is a promise" and "the service stays small" pull opposite ways on queue persistence (see F1). An explicit ordering would let a cold reader resolve it. Tenet 2 reads closer to a rule than a tie-breaker. · *Tenets capture forward-looking preference*
- **F8 (low):** The "fair access to popular printer classes" goal has no matching design. FIFO within two priority classes gives no per-member fairness, and the Decisions table itself notes one long job can hold a class. "Printer class" is also never defined (three hardware models against class names). · *HLD is architecture and rationale*, *docs written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files.
- Enumerated: 2 LLDs, 2 spec files (8 specs: 5 `QUEUE-`, 3 `REG-`).
- Arrow-path sampling: not possible past the specs. There are no code or test files, and the arrow overlay (`docs/arrows/`) isn't installed.
- Linkage metric: 0 `@spec` references.
- Cold-read pass and Decisions-table sweep: done across all docs. Most rows passed; the gap is the missing row in F2.

**Offer to help**
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.