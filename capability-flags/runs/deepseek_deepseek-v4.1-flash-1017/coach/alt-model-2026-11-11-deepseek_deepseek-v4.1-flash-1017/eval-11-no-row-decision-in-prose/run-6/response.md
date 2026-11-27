**LID Coach review — printfarm**

**Posture: Clean doc layer with a live tenet contradiction and missing downstream phases.**

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ Intent-tree linkage — `QUEUE` / `REG` spec prefixes resolve cleanly to their leaf LLD frontmatter
- ✓ Mutation hygiene — docs read as current intent; no changelog residue or obsolete markers
- ⚠ Cascade — the in-memory queue undercuts a stated tenet with no recorded exception
- ⚠ Spec coverage — several described behaviors have no EARS spec
- ✗ Tests & code — no implementation and no `@spec` annotations anywhere to walk

**Findings (9 total · 3 high · 4 medium · 2 low)**
- **F1 (high):** the job-queue's in-memory design drops accepted-but-undispatched jobs on restart, directly defeating the tenet *"a submitted job is a promise"* and the *overnight-with-no-member-present* goal, with no recorded exception · *tenet cascade (design should lean the way the HLD's tenets say)*
- **F2 (high):** the choice to hold the queue entirely in memory (vs. persisting it) is a live, reversible-question decision a cold reader would challenge, yet it has no Decisions & Alternatives row explaining the durability cost accepted · *decision capture (docs carry current intent)*
- **F3 (high):** specs are all marked `[x]` but there is no code and no test in the repo, and no `@spec` references exist — the Tests and Code phases of the arrow are absent, so spec → test → code cannot be walked · *canonical arrow shape / tests carry `@spec` annotations*
- **F4 (medium):** LLD behaviors with no owning spec — queue acceptance precondition (target class needs a registered printer), FIFO/priority ordering, content-hash dedupe, slug recycling, printer registration, and idle/busy state derivation · *effective intent-tree alignment*
- **F5 (medium):** the queue↔registry interface is left open — the registry "polls each printer's status endpoint on an interval" while dispatch is "event-driven when the registry reports a printer idle"; push vs. pull is unspecified · *LLDs close enough of the solution space*
- **F6 (medium):** the HLD has three tenets in an unordered list, and tenets 1 and 3 (job durability vs. keep-the-service-small) can genuinely conflict · *tenets capture forward-looking preference*
- **F7 (medium):** the meaning of the `[x]` status marker is ambiguous — accepted or implemented? Paired with F3, a reader can't tell whether these specs are done or merely agreed · *specs are grep-anchored linkage*
- **F8 (low):** restart recovery leaves a cold-reader gap — §Architecture says farm state is rebuilt from what printers are running, but not how an in-flight job reconciles with ordering or duplicate detection · *docs carry current intent, written to be read cold*
- **F9 (low):** the HLD has no explicit Key Design Decisions section; architecture-level choices (single-service deployment, per-class queues) live only in prose · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs (`job-queue-design.md`, `printer-registry-design.md`) and both spec files (`job-queue-specs.md`, `printer-registry-specs.md`)
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (QUEUE-001–005, REG-001–003)
- Codebase: 0 source files and 0 test files tracked; 0 `@spec` references
- Overlay: no `docs/arrows/` present; not required in Full mode
- Sampling: full read of every file (project under the sampling threshold)

Want me to walk through the findings in detail, focus on a theme or priority (for example, the F1/F2 durability contradiction), or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large — I can help with those too.