**LID Coach: printfarm**

**Posture:** Clean and compact, with one live decision pulling against a tenet.

**Scorecard**
- ✓ HLD discipline: problem, approach, tenets, goals and non-goals, with no schemas or signatures leaking upstream
- ✓ Linkage hygiene: IDs are unique, grep-friendly and match each LLD's `prefix:` (`QUEUE-`, `REG-`)
- ✓ Mutation hygiene: no change-narration, obsolete markers or history sections
- ⚠ Tenet alignment and decision capture: the job-queue restart behaviour works against the "a submitted job is a promise" tenet, and that choice isn't recorded as a decision
- ⚠ Intent-tree alignment: a few LLD behaviours have no spec, and one term ("suspect") isn't owned by any node
- ✗ Arrow completeness: every spec is marked `[x]`, but the project has no tests or code

**Headline:** The design layer is in good shape: one HLD, two well-bounded leaf LLDs, and Decisions tables that mostly name what was rejected and what it cost. The most valuable next step is to settle and write down how queued jobs survive a restart, because that choice currently undercuts the project's first tenet and main goal.

**Findings (7 total · 3 high · 2 medium · 2 low)**
- **F1 (high):** The job queue is held only in memory, so accepted jobs that haven't dispatched are lost on restart (`job-queue-design.md:14`). On a mini-PC that takes unattended OS updates and power blips overnight, this contradicts the tenet "a submitted job is a promise" and the goal "evening upload, overnight print, morning pickup" · *intent leads; code is compiled output* (a leaf design should carry out the HLD's intent, not quietly weaken it)
- **F2 (high):** The in-memory queue choice appears only in Architecture prose and has no Decisions & Alternatives row. The row should name the rejected alternative (for example, persisting the queue, perhaps in SQLite as the registry already does) and the accepted cost (members resubmit after a restart). Consider a fuller row. Because the HLD tenets and goals depend on this choice, a decision doc is also an option if you want the full option space on record · *docs carry current intent* (a live decision should be reconstructable by a cold reader, not left in someone's head)
- **F3 (high):** All 8 specs are marked `[x]` (implemented), but the project has no tests and no code, so the arrow stops at EARS. If code lives in another repo, the instruction file should say so; otherwise the markers claim more than exists · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code, with any deviation made explicit)
- **F4 (medium):** QUEUE-003 marks a printer "suspect", but the printer-registry LLD only knows unreachable, idle and busy. Nothing says what "suspect" means or who owns it. The meaning should live in the registry, which owns printer state, with a spec · *intent attaches at the lowest node that dominates it* (a decision belongs in the design node whose area covers everything it affects) and a cold-read gap
- **F5 (medium):** Some LLD behaviours have no spec:
  - rejecting a job whose class has no registered printer (`job-queue-design.md:20`)
  - staff-over-member priority with first-in-first-out order within each class (`:25`)
  - staff registering a printer (only retirement is specced)

  · *effective intent-tree alignment* (every behaviour an LLD describes has a spec to test against)
- **F6 (low):** The three tenets are unordered, yet tenet 1 (a job is a promise) and tenet 3 (the service stays small) conflict, and F1 is exactly where they meet. Consider ranking them so the next session knows which to lean on · *tenets capture forward-looking preference* (tie-breakers only work if they say which one wins)
- **F7 (low):** The HLD has no success metrics section and no key design decisions section. A metric such as "share of overnight jobs finished by morning" would make the main goal checkable · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, 2 LLDs (`job-queue`, `printer-registry`) and 2 spec files
- Enumerated: 2 leaf LLDs, 8 EARS specs (5 `QUEUE`, 3 `REG`), 0 test files, 0 code files, 0 `@spec` references
- Configuration: LID directives present and `Mode: Full` declared, so this was a full review. No `docs/arrows/` overlay, so arrow-path sampling and cascade-health checks had no index to work from
- Decisions sweep: 5 rows checked. All pass the cold-reader test; the in-memory queue decision (F2) has no row to check
- Not available: I couldn't read the core skill's `references/capability-flags.md` in this run, so the capability-flag section below is written without it

**Worth a second look:** Because I couldn't load the capability-flags reference, I'm treating its cautions as applying to me. Models in my class can miss designs that contradict the project's own tenets. I found one such conflict (F1), but please check both leaf designs against your HLD tenets yourself.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for your project, such as multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large, I can help with those too.