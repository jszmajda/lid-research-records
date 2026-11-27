# LID Coach Report: Shelfwise

**Posture:** The design layer is clean and small, but the arrow ends at the specs, and one tenet is quietly overridden.

**Scorecard**
- ✓ HLD discipline: the HLD has only problem, approach, tenets, goals and components. It has no schemas, signatures or pseudocode.
- ✓ Decision capture (mostly): 6 of the 7 Decisions & Alternatives rows name the rejected option and the cost accepted. That's unusually good.
- ✓ LLD granularity and mode fit: there are two LLDs, one for each HLD component, with clean `HOLDALLOC-` / `PICKUP-` prefixes. Full mode fits a project this size.
- ⚠ Tenet alignment: the allocation rule works against the first tenet, *Waiting is honored in sequence*.
- ⚠ LLD sufficiency: the design leaves a few edges open, in cancellation and in failed phone-call notices.
- ✗ Arrow completeness: all 13 specs are checked `[x]`, but the project has no tests or code, so nothing carries a `@spec` annotation.

**Headline:** Both design docs are cold-readable and record rationale well, and every spec reads as testable. The most useful next step is to decide whether serving the scanning branch first is an exception to the "waiting in sequence" tenet or a mistake, then write that answer down in the HLD or the allocation LLD.

**Findings (8 total · 4 high · 2 medium · 2 low)**
- **F1 (high):** Allocation serves holds at the scanning branch first (`hold-allocation-design.md` §Design ¶2; HOLDALLOC-003/004). So a patron who asked later at this branch gets the copy before a patron elsewhere who asked sooner. That goes against the first HLD tenet, "nobody's wait is lengthened by a patron who asked after them." You could either narrow the tenet or change the design. · *tenets capture forward-looking preference* (a tenet is the tie-breaker a future session leans on when no spec covers a choice)
- **F2 (high):** The local-first rule has no row in the Decisions & Alternatives table. Its only rationale is one prose sentence about the courier van. The table doesn't name the option given up (strict county-wide oldest-first) or its cost (older holds at other branches wait longer). · *docs carry current intent, written to be read cold* (a choice a reader would question needs a full table row naming what was given up)
- **F3 (high):** Every spec is marked `[x]`, but the project has no tests or code. If the code lives in another repo, the instruction file doesn't say where. Otherwise the checkmarks claim more than exists. · *canonical arrow shape* (HLD → LLD → EARS specs → tests → code, each phase present) and *tests carry `@spec` annotations* (each test cites the spec it checks)
- **F4 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full, Version 1.4.0) but none of the Linked-Intent Development directive text. Future sessions get the mode setting but not the instructions for working in that mode. Running `/update-lid` would add them. · *modes are declared, not inferred* (the setup is written in the instruction file, not assumed)
- **F5 (medium):** Cancellation is specified only for a copy in transit (HOLDALLOC-007). Nothing says what happens when a hold is cancelled while it is waiting in the queue, allocated at the desk, or already on the holds shelf. Nothing says whether a cancelled hold's record is deleted, as the "Hold history is not kept" tenet requires. · *LLDs close enough of the solution space* (two agents reading the LLD should build compatible behavior)
- **F6 (medium):** PICKUP-006 and the LLD define a failed delivery only as a bounced email or an undeliverable SMS. The third channel, the automated phone call, is left open: no answer, voicemail and a busy line aren't covered. · *scope disambiguation* (a spec that applies to only some channels should say which)
- **F7 (low):** The four tenets aren't ranked, but some can conflict: "waiting in sequence" against courier efficiency, and "patrons hear once" against the staff call-backs on the exceptions list. · *tenets capture forward-looking preference* (tenets that can conflict should be ranked)
- **F8 (low):** The HLD Approach says uncollected items "go to the next person waiting." A cold reader takes that as a strict county-wide queue. But PICKUP-005 re-runs allocation as a check-in at the same branch, so the local-first rule applies again. Once F1 is settled, the HLD sentence should match the answer. · *docs carry current intent, written to be read cold* (a doc should make sense with no memory of the conversations behind it)

**What was audited**
- Read in full: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Counted: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (IDs unique and grep-friendly), 7 Decisions & Alternatives rows, each checked against the cold-reader test.
- Code and tests: none in the project, so there were no `@spec` annotations to sample.
- Arrow overlay: `docs/arrows/` is absent, so no `index.yaml` was read.
- The core skill's `references/capability-flags.md` couldn't be read in this run, so its flags were treated as applying.

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets, and places where a doc depends on context that isn't written down. Please check both LLDs against your four HLD tenets yourself, not only the conflict in F1.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick one finding to dig into, and F1 with F2 is a natural pair.

If you have broader questions about using LID for your project, such as where the code repo fits, where PRDs fit, switching modes, or what to do when a segment grows too large, I can help with those too.