**LID Coach review: printfarm**

**Executive summary**

Posture: Sound design core, early arrow. One tenet conflict is worth settling first.

**Scorecard**
- ✓ Mode fit: Full mode matches a two-node project where the whole design lives in one place.
- ✓ Intent-tree alignment: the QUEUE and REG prefixes resolve to the two leaf LLDs that the HLD's Architecture section names.
- ✓ Mutation hygiene: no change-narration or obsolete specs. Rejected alternatives sit in the Decisions tables with their reasons.
- ⚠ Tenet cascade: the in-memory queue runs against the "promise" tenet under conditions the Context describes.
- ⚠ LLD sufficiency: the `suspect` printer state, the job-acceptance rule, and how a job gets the staff priority class are all left open.
- ⚠ Arrow completeness: the arrow stops at specs. Tests and code aren't in this repo yet, so linkage and tests-first can't be checked.

**Worth a second look:** The Context says the mini-PC takes unattended OS updates and occasional power blips, and that accepted jobs are lost on restart. The HLD's first tenet says a submitted job is a promise. The two are in tension, and no Decisions row records which one won.

Headline: The two nodes are cleanly split, and their specs trace back to the architecture. The most valuable next step is deciding whether accepted jobs should survive a restart. The current in-memory design cuts against the promise tenet, and nothing records that trade-off.

**Findings (12 total · 3 high · 4 medium · 5 low)**
- **F1 (high):** Accepted jobs are lost on restart, which works against the "promise" tenet under the power blips and OS updates the Context describes · *tenet cascade* (a mechanism working against a tenet under a described condition), *decision capture*
- **F2 (high):** The `suspect` printer state is set by the queue, but the registry has no such state and no spec defines what it does · *intent attaches at the lowest node that dominates it*
- **F3 (high):** Nothing says how a job gets the staff priority class, and QUEUE-005 (reordering) has no LLD prose behind it · *LLDs close enough of the solution space*
- **F4 (medium):** The job-acceptance rule (a class needs at least one registered printer) and staff printer registration have behavior but no EARS spec · *coherence is adjacency*
- **F5 (medium):** Every spec is marked `[x]` with no legend, and there's no code or tests to back the marker · *docs carry current intent, written to be read cold*
- **F6 (medium):** Tenets 1 (promise) and 3 (stay small) can conflict, and the list has no order to settle it · *tenets capture forward-looking preference*
- **F7 (medium):** The tests and code phases of the arrow aren't in this repo yet, so `@spec` linkage and tests-first can't be assessed · *canonical arrow shape*
- **F8 (low):** The HLD has no success-metrics or target-users section · *HLD is architecture and rationale*
- **F9 (low):** The 15 s heartbeat interval is recorded, but the three-miss threshold's rationale isn't · *decision capture*
- **F10 (low):** "Six printers today" appears in the HLD and the registry Context and will go stale · *mutation, not accumulation* (docs reflect current intent; git preserves history)
- **F11 (low):** QUEUE-001 covers member uploads only, and staff uploads aren't addressed · *scope disambiguation*
- **F12 (low):** QUEUE-002 says to dispatch the head job but doesn't say what happens when the class queue is empty · *scope disambiguation*

**What was audited**
- Read fully: CLAUDE.md, `docs/high-level-design.md`, both LLDs (`job-queue-design.md`, `printer-registry-design.md`), and both spec files (8 specs)
- Enumerated: 2 LLDs, 2 spec files, 8 specs
- Arrow-path sampled: none. There's no arrow overlay, code, or tests in the repo.
- Linkage metric: 0 `@spec` references, because there's no code yet
- Capability flags: the reference file lists no flagged configurations, so that section is omitted.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.