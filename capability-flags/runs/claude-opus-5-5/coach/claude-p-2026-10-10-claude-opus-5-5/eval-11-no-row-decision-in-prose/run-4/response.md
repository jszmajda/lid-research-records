# LID Coach: printfarm

## Executive summary

**Posture:** Well-shaped design tree, but one core design choice leans against a tenet, and the arrow stops at the specs.

**Scorecard**
- ✓ Configuration and mode fit — Full mode is declared and the navigation table matches the two-node layout.
- ✓ Linkage — `QUEUE` and `REG` prefixes are declared in frontmatter, IDs are unique, and every spec is clean EARS.
- ✓ Mutation hygiene — no changelog residue, obsolete markers or planning text in any doc.
- ⚠ Decision capture — most Decisions rows name the rejected alternative and accepted cost, but the most questionable choice has no row.
- ⚠ LLD ↔ spec coherence — several designed behaviours have no spec, and several specs have no design behind them.
- ✗ Tenet cascade — the queue's restart behaviour works against "a submitted job is a promise".
- ✗ Arrow completeness — every spec is marked `[x]`, but the repository has no tests and no code.

**Headline:** The HLD is short, architectural and carries real tenets, and both LLDs are right-sized with mostly well-reasoned Decisions tables. The most valuable next step is to settle whether accepted jobs may be lost on restart, since the design currently says yes and the first tenet says no.

## Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** `job-queue-design.md` holds the queue only in process memory, so accepted-but-undispatched jobs vanish on restart. The same doc says the mini-PC takes unattended OS updates and power blips, so this defeats the tenet "upload and walk away" and the goal of overnight printing with no member present · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The in-memory queue has no Decisions & Alternatives row. A cold reader will question it at once, because the registry next door already persists to SQLite, and nothing says what was given up or why · *decision capture* — a choice a reader would want to reverse needs its trade-off on the page.
- **F3 (high):** All eight specs are marked `[x]`, yet the repo contains only docs — no tests, no code, no `@spec` annotations. Either the implementation lives somewhere the instruction file doesn't mention, or the markers overstate reality · *canonical arrow shape* — HLD → LLD → EARS → tests → code, each phase present and linked.
- **F4 (medium):** Design and specs disagree at the seam in both directions · *coherence is adjacency* — each level agrees with the one next to it.
  - Designed but unspecified: job loss and resubmission on restart, the "class must have a registered printer" acceptance rule, staff-before-member ordering, content-hash storage, and 90-day slug recycling.
  - Specified but undesigned: `QUEUE-005` (how a reorder is shown), `REG-002` and `REG-003`. Printer registration has neither design nor spec.
- **F5 (medium):** `QUEUE-003` marks a printer "suspect", but the registry — which owns printer state — never defines that state, what it does to dispatch, or how it clears. There is also no retry bound, so a job a printer rejects goes back to the head of the queue indefinitely · *LLDs close enough of the solution space* — two agents reading the design should land on compatible implementations.
- **F6 (medium):** "Class" carries two meanings in the job-queue docs: printer class and staff/member priority class. "Head of its class queue" in `QUEUE-002` and `QUEUE-003` is therefore ambiguous, and "printer class" is never defined against the registry's "three hardware models" · *docs carry current intent, written to be read cold* — in-conversation-only meaning.
- **F7 (medium):** The three tenets are unordered, yet "a submitted job is a promise" and "the service stays small" pull opposite ways on exactly the F1 question · *tenets capture forward-looking preference* — tie-breakers need an order when they can conflict.
- **F8 (low):** `QUEUE-001` applies the 64 MB limit "when a member uploads". Staff use the same UI, so it is unclear whether the limit is deliberately member-only · *scope disambiguation* — a spec's scope should be exactly as wide as its trigger says.
- **F9 (low):** The HLD has no success metrics or key design decisions section. "Fair access to the popular printer classes" in particular has nothing to measure it against · *HLD is architecture and rationale*.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`), 5 Decisions rows.
- Code and tests: none in the repository, so nothing was sampled; 0 `@spec` references.
- Arrow overlay: not installed (`docs/arrows/` absent).
- Git history: a single commit, so there was no evidence either way on tests-first or cascade timing.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are a natural pair to start with.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.