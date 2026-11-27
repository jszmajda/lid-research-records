# LID Coach — printfarm

## Executive summary

**Posture:** Well-shaped design tree; one design choice pulls against the lead tenet, and the arrow stops at specs.

**Scorecard**
- ✓ Configuration and mode — directives, `Mode: Full` and the standard directories are all in place, and Full fits a two-node project.
- ✓ Design-tree alignment — the `QUEUE` and `REG` prefixes each resolve to one leaf LLD, and both leaves trace to the HLD's Architecture section.
- ✓ Current-intent hygiene — no change-narration, obsolete markers or changelog residue in any doc.
- ⚠ Tenet cascade — the job-queue's in-memory queue works against "a submitted job is a promise".
- ⚠ LLD-to-spec coherence — several behaviours the LLDs describe have no EARS spec, and one concept crosses the node boundary undefined.
- ✗ Arrow completeness — every spec is marked `[x]`, but the repository holds no tests or code.

**Headline:** The HLD is lean, the two LLDs are right-sized, and the Decisions tables mostly record what was given up. The most valuable next step is to settle whether accepted jobs may be lost on restart, then record or change that choice.

## Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** The queue is "held entirely in process memory" and undispatched jobs "are gone" after a restart, on a mini-PC that takes unattended OS updates and power blips. An overnight restart defeats "upload and walk away" and the no-member-present goal. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The in-memory queue has no Decisions & Alternatives row, so a reader cannot tell what was weighed (for example the SQLite file the registry already uses) or what cost was accepted. · *decision capture* — a choice a cold reader would question needs its trade-off on the page.
- **F3 (high):** All eight specs carry `[x]`, yet there are no tests, no code and no `@spec` annotations in the repository. If the implementation lives elsewhere, the docs don't say where. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, each phase present or its absence explicit.
- **F4 (medium):** Several LLD behaviours have no spec:
  - job acceptance only when the class has a registered printer;
  - staff-before-member ordering and FIFO within a class;
  - loss of undispatched jobs on restart;
  - content-hash storage of uploads;
  - printer registration (only retirement is specified).
  
  · *effective intent-tree alignment* — behaviour with no spec is unnamed intent with nothing to test against.
- **F5 (medium):** job-queue marks a printer "suspect" (`QUEUE-003`), but printer-registry owns printer state and defines no such state. Nothing says what it means for dispatch or how it clears, which matters overnight with no staff present. · *intent attaches at the lowest node that dominates it* — state shared by two nodes belongs with its owner, with a note to the dependent.
- **F6 (medium):** Staff priority reads two ways: "two priority classes: staff and member" versus staff "reordering rights". How a manual reorder interacts with FIFO is open, and so is what `QUEUE-005`'s "record visibly" must show. · *LLDs close enough of the solution space* — two agents should land on compatible implementations.
- **F7 (medium):** The three tenets are unordered, and F1 is exactly the case where "a submitted job is a promise" and "the service stays small" collide. · *tenets capture forward-looking preference* — tie-breakers need an order once they can conflict.
- **F8 (low):** "Slugs recycle after 90 days" does not say 90 days from what, or what happens to chat and LCD references to a recycled slug. · *docs carry current intent, written to be read cold* — the page must stand without the conversation behind it.
- **F9 (low):** The HLD has no Key Design Decisions or Success Metrics sections, so "fair access" has no stated measure. · *HLD is architecture and rationale* — the HLD carries the project-level why.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`), 5 Decisions rows.
- Code and tests: none in the repository (6 tracked files, all docs), so there were 0 `@spec` references to sample.
- Arrow overlay: `docs/arrows/` is not present, so no structural audit inputs.
- History: a single commit, so there was no tests-before-code or cascade-timing evidence to assess.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.