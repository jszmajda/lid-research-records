# LID Coach: printfarm

## Executive summary

**Posture:** Well-shaped design tree; one design choice pulls against the lead tenet, and the arrow stops at the specs.

**Scorecard**
- ✓ Configuration and mode fit — Full mode is declared and the navigation table matches the two-node tree.
- ✓ Linkage — `QUEUE` and `REG` prefixes are declared in frontmatter, IDs are unique, and every spec is in clean EARS form.
- ✓ Mutation hygiene — no changelog residue, no obsolete markers, and the docs read cold.
- ⚠ Decision capture — most rows name what was rejected and the cost accepted, but the most questionable choice has no row.
- ⚠ Spec coverage — several behaviours the designs describe have no spec.
- ✗ Tenet cascade — the queue's storage design works against "a submitted job is a promise".
- ✗ Arrow completeness — there are no tests or code, yet every spec is marked `[x]`.

**Headline:** The HLD is lean, the two nodes map cleanly onto its architecture, and the Decisions rows for scheduling and job IDs are model examples. The most valuable next step is to resolve the in-memory queue against the "upload and walk away" tenet, either by changing the design or by recording the exception.

## Findings (8 total · 3 high · 4 medium · 1 low)

- **F1 (high):** The job queue lives only in process memory, and the mini-PC takes unattended OS updates and power blips, so an overnight restart drops accepted jobs and "members resubmit them". This works against the tenet "a submitted job is a promise" and the goal "morning pickup with no member present" (`job-queue-design.md:10,14`). · *tenet cascade* — leaf designs should lean the way the HLD's tenets say.
- **F2 (high):** The in-memory queue has no Decisions & Alternatives row, even though the registry next door already persists to SQLite on the same machine. A cold reader would want to reverse this and cannot see what was traded. · *decision capture* — a choice a reader would still question needs its alternative and accepted cost on the page.
- **F3 (high):** All eight specs are marked `[x]`, but the repository holds no tests, no code and no `@spec` annotations. Consider resetting the markers, or noting where the implementation lives if it is elsewhere. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present.
- **F4 (medium):** Several behaviours in the designs have no spec. · *effective intent-tree alignment* — unspecified behaviour has nothing to test against, so it drifts silently.
  - Accepting a job only when its class has a registered printer.
  - Staff-over-member priority and FIFO within a class.
  - Content-hash storage of uploads.
  - Slug recycling after 90 days.
  - Printer registration.
- **F5 (medium):** The queue marks a printer "suspect" on dispatch failure, but the registry, which owns printer state, defines no such state. Nothing says whether a suspect printer still receives dispatches or how it clears, so a failing job returned to the head of the queue could retry all night. · *intent attaches at the lowest node that dominates it* — state shared by two nodes belongs with its owner, here the registry.
- **F6 (medium):** Two terms leave implementers guessing. "Printer class" is never defined against the registry's "three hardware models", and QUEUE-005's "record the reordering visibly" does not say what is shown or to whom. · *LLDs close enough of the solution space* — two agents reading the doc should land on compatible implementations.
- **F7 (medium):** The three tenets are unordered, and F1 is exactly the case where two collide: "a job is a promise" against "the service stays small". Consider ranking them. · *tenets capture forward-looking preference* — tie-breakers only help when the order between them is known.
- **F8 (low):** The HLD has no target users, key design decisions or success metrics sections. Members and staff appear only in passing. · *HLD is architecture and rationale* — the HLD carries the project-level why.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`), 5 Decisions rows.
- Code and tests: none in the repository, so there was nothing to sample and no `@spec` references.
- Arrow overlay: not installed (no `docs/arrows/`).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for this project — where PRDs fit, when a node should split, how to handle a concern that spans both nodes — I can help with those too.