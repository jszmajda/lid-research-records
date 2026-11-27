## printfarm: LID coach report

### Executive summary

**Posture:** Healthy, well-shaped design layer, with one conflict between a design mechanism and the HLD's lead tenet.

**Scorecard**
- ✓ Configuration: `## LID` block with mode and version, navigation table, and standard directories.
- ✓ Design-tree shape: two leaf LLDs under one HLD, each with a matching `prefix:`.
- ✓ Spec hygiene: EARS phrasing, unique namespaced IDs, no obsolete residue, no history narration.
- ✓ HLD discipline: architecture and rationale only, no implementation detail.
- ⚠ Tenet cascade: the queue's in-memory design works against the first tenet and the first goal.
- ⚠ Arrow completeness: specs are marked done, but there are no tests or code in the repo to carry `@spec` links.

**Headline:** The design is compact, readable cold, and cleanly linked (HLD → 2 LLDs → 8 specs), and the Decisions tables already show real trade-offs. The most valuable next step is to settle how an accepted job survives a restart, which is the one place the design and the HLD's "a submitted job is a promise" tenet pull apart.

### Findings (6 total · 1 high · 3 medium · 2 low)

- **F1 (high):** The queue is held only in memory and accepted-but-undispatched jobs are lost on restart, even though the mini-PC takes unattended OS updates and power blips. That works against the tenet "a submitted job is a promise… upload and walk away" and the goal "overnight print… no member present". No Decisions row records the exception. · *tenet cascade: do design nodes lean the way the HLD says to lean?*
- **F2 (medium):** The in-memory queue choice (and its accepted cost, "members resubmit") has no row in job-queue's Decisions & Alternatives, so a cold reader can't tell which tenet was traded against, what was given up, or why. Report it alongside F1. · *decision capture: a live choice should keep its reasoning on the page*
- **F3 (medium):** Tenets are an unordered list, but two of them conflict in this design ("a promise" vs. "the service stays small"), and nothing says which wins. · *tenets capture forward-looking preference (tie-breakers should be ordered when they can conflict)*
- **F4 (medium):** job-queue marks a printer "suspect" (QUEUE-003) but printer-registry defines no such state or its effect on dispatch. REG-001/002 only know unreachable, idle and busy. Consider a REG spec or a design line, since it crosses a node boundary. · *coherence is adjacency / intent attaches at the lowest node that dominates it*
- **F5 (low):** Some LLD behaviors have no spec: "accepted only if the class has a registered printer", the two priority classes with FIFO, and the 90-day slug recycling. Prioritization is part of the "fair access" goal, so it's worth a spec. · *effective intent-tree alignment (LLD behaviors with no spec are unnamed intent that can drift silently)*
- **F6 (low):** All eight specs are `[x]`, but the repo has no tests or source files, so `@spec` linkage and tests-first evidence can't be checked. If the code lives elsewhere or is yet to come, consider marking specs as not yet implemented. · *tests carry `@spec` annotations / tests before code*

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (the whole LID doc set).
- Enumerated: 1 HLD, 2 LLDs, 8 EARS specs (5 `QUEUE`, 3 `REG`), 0 arrow segments (no `docs/arrows/` overlay).
- Code and tests: none present to sample.
- Cold-read pass and Decisions-table sweep covered every doc; all 5 decision rows were checked.

### Offer to help
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together (F1–F3 form a natural cluster)? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.