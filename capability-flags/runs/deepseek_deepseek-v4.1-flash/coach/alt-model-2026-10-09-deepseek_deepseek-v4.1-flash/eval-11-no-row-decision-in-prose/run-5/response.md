**LID Coach review — printfarm**

**Solid greenfield arrow; the sharpest win is resolving the queue's restart behavior against your own "a submitted job is a promise" tenet.**

**Scorecard**
- ✓ Linkage — EARS specs are unique, grep-friendly, and their prefixes trace cleanly to leaf LLDs
- ✓ Decision hygiene — Decisions tables carry real rationale, rejected alternatives, and accepted costs
- ⚠ Tenet precision — two of three tenets read as goals or spec-shaped rules rather than tie-breakers
- ⚠ Intent-tree alignment — several LLD behaviors have no spec
- ⚠ HLD coverage — Target Users, Key Design Decisions, and Success Metrics are absent
- ⚠ Arrow completeness — the arrow stops at EARS; no tests or code yet

**Findings (7 total · 1 high · 4 medium · 2 low)**
- **F1 (high):** the queue is held in process memory and accepted-but-undispatched jobs are lost on restart (`job-queue-design.md:14`), which works against the HLD tenet "a submitted job is a promise" and the "evening upload → morning pickup with no member present" goal, under the power-blip condition the design's own Context names (`:10`); no Decisions row (and no HLD Key Design Decisions section) records the trade · *tenets capture forward-looking preference* + *intent attaches at the lowest node that dominates it / coherence is adjacency* + *docs carry current intent*
- **F2 (medium):** LLD behaviors with no spec — "a job is accepted only if its target class has at least one registered printer" (`job-queue-design.md:20`), content-hash dedup (`:14`), and printer registration (`printer-registry-design.md:10`) · *effective intent-tree alignment* (LLD behaviors with no spec are unnamed intent)
- **F3 (medium):** Full-mode HLD omits Target Users, Key Design Decisions, and Success Metrics, and uses "Architecture" where the template's System Design sits · *HLD is architecture and rationale*
- **F4 (medium):** tenet 1 ("a submitted job is a promise…") reads as a value/goal, not a lean with a defensible opposite; tenet 2 blends a real lean (staff over members) with a spec-shaped rule ("no silent reordering" ≈ QUEUE-005) · *tenets capture forward-looking preference*
- **F5 (medium):** the instruction file carries only the compact pointer plus the `## LID` block — no arrow mandate or inspection invariant · *minimum surface, maximum discipline* / *modes are declared, not inferred* — consider `/update-lid` to reconcile
- **F6 (low):** tenets are unordered though 1 and 2 can conflict (a staff reorder can break a member's FIFO expectation) · *tenets capture forward-looking preference*
- **F7 (low):** Decisions tables drop the template's "Alternatives Considered" column (folded into Rationale) · *minimum surface, maximum discipline*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`job-queue-design.md`, `printer-registry-design.md`), both spec files
- Enumerated: 2 LLDs, 8 EARS specs (`QUEUE-001`–`005`, `REG-001`–`003`)
- Code/tests: none present; 0 `@spec` references; no `docs/arrows/` overlay
- Configuration: Full mode declared, `- Version: 1.4.0` matches the installed plugin (no version-walk needed)

**Out-of-scope:** none — Full mode reviews the whole project.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.