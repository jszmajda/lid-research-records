**LID Coach report: printfarm**

**Posture:** The design layer is clean and small. One queue decision works against the project's own first tenet, and the tests and code aren't in this repo.

**Scorecard**
- ✓ Linkage and spec format: spec IDs are unique and easy to grep, each prefix matches its design doc's `prefix:` field, and the specs are written in clean EARS form
- ✓ Mutation hygiene: no change history, old versions or leftover planning text in any doc
- ⚠ Tenet alignment: job-queue's in-memory queue conflicts with "a submitted job is a promise," and the tenets aren't ranked
- ⚠ Decision capture: the queue's biggest decision isn't recorded in its Decisions & Alternatives table
- ✗ Arrow completeness: no tests or code in the repo, yet every spec is marked `[x]` (implemented)
- ✓ Mode fit: Full mode suits a two-component project where everything is under LID

**Headline:** The HLD and both design docs are tight, readable cold, and well linked, and most of the Decisions rows record the alternative that was rejected and the cost that was accepted. The most valuable next step is to reconcile job-queue's in-memory queue with the first tenet and the overnight-printing goal, then record whichever way you decide in that design doc's Decisions table.

**Findings (8 total · 3 high · 4 medium · 1 low)**
- **F1 (high):** job-queue loses accepted jobs that haven't been sent to a printer when the service restarts (`job-queue-design.md` §Architecture). The same doc says the mini-PC takes unattended OS updates and power blips, so overnight jobs can quietly disappear. That works against the first tenet ("upload and walk away") and the "evening upload, overnight print" goal · *tenets capture forward-looking preference*: tenets are the tie-breakers leaf designs should lean on
- **F2 (high):** Every spec (QUEUE-001–005, REG-001–003) is marked `[x]` implemented, but the repo has no tests, no code and no `@spec` annotations. Nothing says where the implementation lives · *canonical arrow shape*: HLD → design docs → EARS specs → tests → code, and leaving a phase out should be a documented choice
- **F3 (high):** The in-memory queue is the choice a cold reader will most want to question or reverse. It isn't in the Decisions & Alternatives table: there's no rejected alternative (for example, the SQLite file the registry already uses) and no stated cost ("members resubmit"). This is a separate issue from F1 · *docs carry current intent*: live decisions belong in the Decisions table with what was given up
- **F4 (medium):** QUEUE-003 marks a printer "suspect," but the registry's state model only has idle, busy and unreachable. Which node owns "suspect," and whether a suspect printer still gets jobs, isn't defined anywhere · *intent attaches at the lowest node that dominates it*: a printer state that both components use belongs in the registry that owns printer state
- **F5 (medium):** Some job-queue behaviors have no spec: the staff-before-member priority classes with first-in-first-out within each, and rejecting a job whose class has no registered printer (§Dispatch behavior, §Prioritization) · *effective intent-tree alignment*: every behavior a design doc describes should have a spec to test against
- **F6 (medium):** The three tenets aren't ordered, and they can conflict. "The service stays small" can be read as permission for F1's in-memory queue, against "a submitted job is a promise." Also, "no silent reordering" mostly repeats QUEUE-005, so it's closer to a spec than a tie-breaker · *tenets capture forward-looking preference*: rank tenets when they can pull against each other
- **F7 (medium):** Some wording depends on context that isn't on the page. "Staff" priority could mean jobs uploaded by staff or jobs staff have promoted. QUEUE-001 covers only uploads by members, while the 64 MB limit in the Decisions table applies to every file, so it's unclear whether the limit applies to staff uploads · *scope disambiguation*: a spec's WHEN clause should state exactly who and what it covers
- **F8 (low):** The HLD has goals but no success metrics, so "fair access" and "morning pickup" can't be checked · *HLD is architecture and rationale*: the HLD's rationale includes how you'd know it's working

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and both design docs and spec files under `docs/intent/`
- Counted: 2 design docs, 2 spec files, 8 EARS specs, 5 Decisions & Alternatives rows (all revisited in a separate pass)
- Code and tests: none in the project tree, so there was nothing to sample and zero `@spec` references
- Arrow overlay (`docs/arrows/`) isn't installed
- Dispatch: `CLAUDE.md` has the linked-intent-dev directive and `Mode: Full`, and both standard directories exist, so this was a full review

**Worth a second look:** I couldn't read the core skill's capability-flags reference in this run (I didn't have permission to open it), so I've assumed the flags apply to me. Please check both design docs against your HLD tenets and goals yourself (the tenet-alignment and decision-capture checks), in case I missed a contradiction beyond F1.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick one finding to dig into.

If you have broader questions about using LID for your project, such as multi-repo setups, where PRDs fit, switching modes, or what to do when a segment grows too large, I can help with those too.