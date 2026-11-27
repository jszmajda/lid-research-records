Reading is done; here is the report.

# LID Coach — printfarm

## Executive summary

**Posture:** *Clean, well-shaped intent layer; one design choice pulls against the project's lead tenet, and the arrow stops at specs.*

**Scorecard**
- ✓ Intent-tree shape — two HLD nodes, two LLDs, two spec files, with prefixes (`QUEUE`, `REG`) that resolve cleanly
- ✓ Mutation hygiene — every doc reads as current intent, with no changelog residue or chat-dependent phrasing
- ⚠ Tenet cascade — the job-queue's in-memory queue works against "a submitted job is a promise"
- ⚠ Decision capture — two Decisions rows are exemplary, but the most questionable choice has no row
- ⚠ LLD ↔ spec coherence — several designed behaviours have no spec, and one spec has no design behind it
- ✗ Arrow completeness — there are no tests or code, yet all eight specs are marked `[x]`

**Headline:** The design tree is small, legible and honestly written, and the scheduling and job-identifier rows name both the rejected alternative and the accepted cost. The most valuable next step is to reconcile the in-memory queue with the "upload and walk away" tenet, either by changing the design or by recording the exception on purpose.

## Findings (10 total · 3 high · 5 medium · 2 low)

- **F1 (high):** The job-queue holds accepted jobs only in process memory, so an overnight OS update or power blip (both named in the LLD's own Context) drops every undispatched job. That defeats the tenet "a submitted job is a promise" and the goal "evening upload, overnight print, morning pickup — with no member present". · *tenet cascade* — leaf designs should lean the way the HLD's tenets say.
- **F2 (high):** The in-memory queue appears only in Architecture prose, with no Decisions & Alternatives row. A cold reader would question it at once, since G-code is already on disk and the registry already has a SQLite file, and cannot tell what was traded or whether it was deliberate. · *docs carry current intent, read cold* — live decisions need their reasoning on the page.
- **F3 (high):** All eight specs are marked `[x]`, but the repo has no tests, no code and no `@spec` annotations, so the markers claim more than the arrow can show. · *canonical arrow shape* — HLD → LLD → EARS → tests → code, each phase present.
- **F4 (medium):** Several LLD behaviours have no spec: staff-before-member priority with FIFO within class, rejecting jobs whose class has no registered printer, content-hash storage, 90-day slug recycling, and printer registration. · *effective intent-tree alignment* — unspecced behaviour drifts because nothing tests it.
- **F5 (medium):** QUEUE-005 ("record the reordering visibly") has no design behind it. The LLD never says what is recorded, where, or for how long, although this spec carries the "queue explains itself" tenet. · *LLDs close enough of the solution space* — two agents should land on compatible implementations.
- **F6 (medium):** The job-queue marks printers "suspect" (QUEUE-003), but the registry owns printer state and has no such state, no exit from it, and no stated effect on dispatch. · *intent attaches at the lowest node that dominates it* — a contract shared by siblings needs a clear owner.
- **F7 (medium):** Dispatch has one trigger, "registry reports a printer idle". The docs do not say what happens when a job arrives while a printer is already idle, or whether "idle" means the bed is clear, which matters for unattended overnight runs. · *LLDs close enough of the solution space*.
- **F8 (medium):** The restart path says "members resubmit" lost jobs, but nothing in the design or QUEUE-004 says members are told. This is the visible edge of F1. · *coherence is adjacency* — specs should carry the LLD's whole behaviour.
- **F9 (low):** The three tenets are unordered, yet "a job is a promise" and "the service stays small" are exactly the pair that collide in F1. Consider ranking them so the tie-breaker is on the page. · *tenets capture forward-looking preference*.
- **F10 (low):** QUEUE-001 is scoped to "when a member uploads", which leaves staff uploads ambiguous: exempt from the 64 MB limit, or simply unmentioned? · *scope disambiguation* — a spec's scope should be exactly what its trigger says.

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- **Enumerated:** 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`) and 5 Decisions rows, all swept.
- **Code and tests:** none exist in the repo, so there are 0 `@spec` references and nothing to sample.
- **Overlay:** there is no `docs/arrows/`, so no structural audit was available.
- **Dispatch:** fully configured, Full mode, LID 1.4.0, so this was a full review.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into; F1 and F2 are the natural pair to start with.

If you have broader questions about using LID for this project — where tests and code should land relative to the spec markers, when a node deserves a sub-HLD, how to record a deliberate exception to a tenet — I can help with those too.