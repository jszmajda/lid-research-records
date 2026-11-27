# LID Coach — printfarm

## Executive summary

**Posture:** *Bootstrapping — design tree in place and clean; one design choice works against the project's own promise, and the arrow stops at the specs.*

**Scorecard**
- ✓ Configuration and mode — LID directives, `Mode: Full` and the standard directories are all present, and Full fits a two-node project.
- ✓ Intent-tree alignment — both HLD nodes have an LLD with a `prefix:`, and every `QUEUE-*` / `REG-*` ID resolves to its leaf.
- ✓ Mutation hygiene — no changelog residue, obsolete markers or "as discussed" prose; the docs read cold.
- ⚠ Tenet cascade — the job-queue persistence design leans against the first tenet and the first goal.
- ⚠ LLD ↔ spec coherence — several designed behaviors have no spec, and a few specs have no design behind them.
- ✗ Arrow completeness — there are no tests or code in the repo, yet every spec is marked `[x]`.

**Headline:** The HLD is lean and architectural, and the Decisions tables are good: the FIFO row names what was rejected and the cost accepted, which is why its tension with the "fair access" goal is not a finding. The most valuable next step is to settle whether accepted jobs may be lost on restart (F1), because it decides whether "upload and walk away" is true.

## Findings (7 total · 3 high · 3 medium · 1 low)

- **F1 (high):** The job queue lives only in process memory, so any restart drops accepted-but-undispatched jobs "and members resubmit them". The same LLD says the mini-PC takes unattended OS updates and power blips. An overnight update therefore breaks "a submitted job is a promise" and the "no member present" goal. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say.
- **F2 (high):** The in-memory queue has no Decisions & Alternatives row. A cold reader would question it immediately, since the registry next door already persists to SQLite, and cannot tell what was weighed or whether "the service stays small" was the reason. · *decision capture* — a choice a reader would want to reverse needs its trade-off on the page.
- **F3 (high):** The repo holds only docs, with no tests, code or `@spec` annotations, yet all 8 specs carry `[x]`. Either the implementation lives elsewhere and that isn't noted, or the markers are ahead of reality. · *canonical arrow shape* — HLD → LLD → specs → tests → code, each phase present or its absence explicit.
- **F4 (medium):** Some designed behaviors have no spec:
  - staff-before-member priority and FIFO within a class (so "head job" in `QUEUE-002` is undefined at spec level);
  - accepting a job only if its class has a registered printer;
  - content-hash storage of uploads;
  - 90-day slug recycling;
  - the loss of queued jobs on restart.
  
  · *coherence is adjacency* — each level should agree with its neighbor. `/arrow-maintenance` can enumerate these precisely if you install the overlay.
- **F5 (medium):** Some specs have no design behind them:
  - `QUEUE-005` (reordering recorded visibly) has no mechanism in the job-queue LLD;
  - `REG-002` (recovery from unreachable) and `REG-003` (retire) are not described in the registry LLD.
  
  · *LLDs close enough of the solution space* — two agents reading the LLD should build compatible things.
- **F6 (medium):** "Mark the printer suspect" (job-queue LLD, `QUEUE-003`) crosses into the registry, whose LLD and specs have no suspect state. Nothing says who owns it, whether a suspect printer still gets dispatches, or how it clears. As written, a failing job returns to the head and can be re-sent to the same idle printer. "Printer class" is also used by both nodes and defined in neither, nor in the HLD. · *intent attaches at the lowest node that dominates it* — what two siblings share belongs in their parent or in an explicit contract.
- **F7 (low):** The three tenets are an unordered list, though "a job is a promise" and "the service stays small" pull against each other (see F1). The second tenet also reads partly as a rule ("no silent reordering") already covered by `QUEUE-005`. · *tenets capture forward-looking preference* — ordered tie-breakers, not triggered rules.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files.
- Enumerated: 2 design nodes, 8 specs (5 `QUEUE`, 3 `REG`), 5 Decisions rows, all swept.
- Code and tests: none in the repo to sample; 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not installed.
- Git history: a single commit, so there was no cascade or tests-first evidence to assess.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into; F1 and F2 are the natural pair to start with.

If you have broader questions about using LID for this project — where code for a docs-only repo should live, when a node like job-queue should split, how to phase in tests — I can help with those too.