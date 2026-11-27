# LID coaching report: printfarm

**Posture: solid design, arrow not yet built, with one unrecorded trade-off.**

**Scorecard**
- ✓ Arrow foundations: HLD, two LLDs, and spec files are present and linked by prefix
- ✓ Mode and configuration: Full mode is declared, and the plugin version (1.4.0) matches the instruction file
- ✓ HLD discipline: the HLD carries architecture and rationale with no schemas or signatures
- ✓ EARS form: every spec has a WHEN trigger, and IDs are unique and namespaced by prefix
- ⚠ Status honesty: every spec is marked implemented, but no code or tests exist yet
- ⚠ Tenet cascade: the in-memory queue works against the "walk away" tenet

The design layer is clean and well-scoped. Each LLD owns one component, the HLD has real tenets, and every spec states its trigger. The fastest wins are reconciling the spec status markers with what exists, and deciding whether the in-memory queue is a trade you intend against the "walk away" tenet.

**Findings (10 total · 3 high · 5 medium · 2 low)**
- **F1 (high):** all six specs are marked `[x]`, which in LID means code and tests exist for them; this repo has neither. Consider `[ ]` until code lands, or point to where the code lives · *coherence is adjacency*: each level should agree with the next, and a spec marked implemented with nothing beneath it is a seam nobody is checking
- **F2 (high):** accepted jobs live only in memory (`job-queue-design.md:14`), so a restart loses anything undispatched. The LLD's own context names unattended updates and power blips as expected restarts (`:10`) · *tenets shape the design*: the tenet "a submitted job is a promise" (HLD:20) meets this mechanism under conditions the doc itself describes, and no Decisions row records the trade
- **F3 (high):** QUEUE-003 marks a printer "suspect" (`job-queue-specs.md:5`), but the registry's states are idle, busy, and unreachable (REG-002). No spec says whether a suspect printer still receives dispatches · *LLDs close enough of the solution space*: an implementing agent will have to guess the missing edge
- **F4 (medium):** the in-memory queue is a live decision a cold reader would question, yet it has no row in Decisions & Alternatives · *decision capture*: a row would name the rejected alternative (for example, persisting the queue in the SQLite file the registry already uses) and the accepted cost
- **F5 (medium):** several LLD behaviors have no spec: the acceptance rule (`job-queue-design.md:20`), staff-before-member priority (`:25`), and content-hash file reuse (`:14`) · *effective intent-tree alignment*: behavior with no spec has nothing to test against
- **F6 (medium):** QUEUE-002 depends on the registry "reporting" a printer idle, but REG-002 only says to mark the state. Neither node owns the notification · *intent attaches at the lowest node that dominates it*: the contract for this seam currently sits in neither doc
- **F7 (medium):** tenet 3 ("the service stays small") reads more like a constraint than a lean, and the three tenets are unordered even though tenets 1 and 3 can conflict (see F2) · *tenets capture forward-looking preference*: an ordered list tells a future session which way to lean
- **F8 (medium):** the Approach describes a member and staff web UI and printer network APIs (HLD:9), but neither has a design node and neither appears in Non-goals · *canonical arrow shape*: consider a node for each, or a Non-goal that marks them deferred
- **F9 (low):** the HLD has no target-users or success-measure section, and "fair access" (HLD:27) has no way to be checked · *HLD is architecture and rationale*: a short success measure makes the goal testable
- **F10 (low):** the upload-limit row (`job-queue-design.md:33`) gives a rationale but not the cost accepted: a legitimate print over 64 MB cannot be uploaded at all · *decision capture*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, and both spec files (six specs)
- Enumerated: 2 LLDs, 2 spec files, 6 EARS specs, no arrow overlay
- Code and tests: none in the working tree, so there was no arrow-path sampling and no `@spec` linkage metric
- Not checked: the project's full git history. The snapshot shows one recent commit, `fixture`. If code was committed earlier, F1 changes shape

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.