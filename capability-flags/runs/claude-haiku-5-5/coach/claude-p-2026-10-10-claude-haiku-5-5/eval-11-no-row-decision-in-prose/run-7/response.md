## LID coach review: printfarm

**Posture: Solid design, with one tenet conflict to settle before code lands.**

**Scorecard**
- ✓ Linkage: spec IDs are namespaced by leaf prefix (`QUEUE`, `REG`), match each file's `prefix:` frontmatter, and follow EARS consistently
- ✓ HLD discipline: the HLD carries architecture and rationale, with no schemas, signatures, or API shapes
- ✓ Configuration and mode fit: the `## LID` block, mode, and navigation table are in place, and Full mode matches a two-node project
- ⚠ Tenet cascade: the in-memory queue works against the "submitted job is a promise" tenet and the overnight goal
- ⚠ Status markers: every spec claims implementation that doesn't exist yet
- ⚠ LLD sufficiency: a few behaviors and states are unspecified or undefined across nodes

**Headline:** The two nodes are clean, well-linked, and each Decisions row names what was rejected and what it costs. The most valuable next step is deciding what happens to queued jobs when the service restarts, since that choice conflicts with the HLD's promise tenet and the overnight-pickup goal.

**Findings (12 total · 2 high · 6 medium · 4 low)**
- **F1 (high):** Accepted-but-undispatched jobs are lost on restart (`job-queue-design.md` line 14), which pulls against the promise tenet and the overnight goal · *tenet cascade: does a mechanism lean against a tenet or goal?*
- **F2 (high):** All eight specs are marked `[x]` (implemented per the EARS reference, meaning code and tests exist), but the repo has no code or tests · *coherence is adjacency: markers should match the level below*
- **F3 (medium):** The in-memory queue choice has no row in the job-queue Decisions table · *decision capture: a live choice belongs in a row a cold reader will find*
- **F4 (medium):** The queue marks a printer "suspect" (QUEUE-003), but the registry never defines that state or how it clears · *cascade pauses across node boundaries*
- **F5 (medium):** Some LLD behaviors have no spec: the job-acceptance rule, staff-over-member priority, and printer registration (only retirement, REG-003, is specified) · *effective intent-tree alignment: unspecified behavior is unnamed intent*
- **F6 (medium):** "Class" means both printer class and priority class (QUEUE-002 vs. the Prioritization section), so "head job of that printer's class" is ambiguous · *semantic legibility: names should echo the concepts they carry*
- **F7 (medium):** QUEUE-001 covers only members, but the 64 MB Decisions row reads as applying to every upload · *scope disambiguation: a spec's scope should match its LLD*
- **F8 (medium):** The arrow stops at specs, with no tests or code yet · *canonical arrow shape: expected at this stage, but the tests-first check can't run until tests exist*
- **F9 (low):** The tenets are unordered, and tenets 1 and 3 can conflict (a durable promise vs. a small service) · *tenet quality: order tenets when they could conflict*
- **F10 (low):** The 64 MB row says it keeps the disk safe, but nothing bounds how many G-code files accumulate on disk · *decision capture: the accepted cost is unstated*
- **F11 (low):** The HLD has no success-metrics or key-design-decisions section; if omitting them is intentional, ignore this · *HLD is architecture and rationale*
- **F12 (low):** "Six printers today" in the registry Context is a time-bound snapshot · *mutation, not accumulation: docs should read as current intent without dates*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 8 spec IDs (QUEUE-001 to QUEUE-005, REG-001 to REG-003)
- Arrow-path sampled: none, since the repo has no code or tests yet
- Linkage metric: 0 `@spec` references (no code)
- Cold-read pass: all five LID docs
- Capability flags: none listed for this configuration, so no flag note applies

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.