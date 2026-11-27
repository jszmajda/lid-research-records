## Executive summary

**Posture:** Small, coherent arrow with strong design writing. The restart behaviour of the queue is the one place where design and stated intent pull against each other.

**Scorecard**
- ✓ Configuration: the `## LID` block declares Full mode, and the directive is present.
- ✓ HLD discipline: the HLD holds problem, approach, goals, non-goals and tenets, with no implementation detail.
- ✓ Tenets: three real tie-breakers, each with a defensible opposite.
- ✓ Spec hygiene: EARS phrasing, unique `QUEUE-`/`REG-` IDs matching the LLD `prefix:` frontmatter, and no obsolete or changelog residue.
- ⚠ Decision capture: one live, consequential decision is recorded only as prose, not as a Decisions row.
- ⚠ LLD-to-spec coverage: some designed behaviours have no spec.
- ⚠ Arrow completeness: no tests or code are present to walk to.

**Headline:** The arrow is well-formed and easy to read cold, and the Decisions tables show real trade-off thinking. The most valuable next step is to reconcile the in-memory queue with the tenet "a submitted job is a promise", and to record that decision properly.

## Findings (6 total · 2 high · 3 medium · 1 low)
- **F1 (high):** The job-queue LLD holds accepted jobs only in memory and drops them on restart, which cuts against the first tenet ("upload and walk away"). The LLD's own Context section names the risk, since the mini-PC takes unattended OS updates and power blips, and jobs run overnight with no member present. · *intent leads; code is compiled output* (design should honour declared intent), with *LLDs close enough of the solution space* (no spec says how a lost job is surfaced to the member).
- **F2 (high):** "Queue is in-memory, accepted jobs lost on restart" is a live, consequential decision that appears only in Architecture prose. The Decisions & Alternatives table has no row for it, so a cold reader can't see the rejected alternative (persisting the queue) or the accepted cost. The registry already uses SQLite, so the alternative is plausible. Reporting this separately from F1: F1 questions the choice, F2 is about recording it. · *docs carry current intent, written to be read cold* (decision capture). A fuller table row is enough; a decision doc isn't warranted.
- **F3 (medium):** Some behaviours in the LLDs have no EARS spec:
  - the job-queue rule "accepted only if the class has a registered printer";
  - the two priority classes with FIFO within a class;
  - what a staff reorder does relative to that FIFO order;
  - the 90-day slug recycling;
  - the registry's heartbeat polling and 15 s interval.
  
  · *effective intent-tree alignment* (each designed behaviour should have a spec to test against)
- **F4 (medium):** "Suspect" is used by QUEUE-003 and the job-queue LLD, but the printer-registry design defines no such state. Its states are idle, busy and unreachable. Nothing says who owns the state, how it clears, or whether suspect printers still receive dispatches. This is the kind of cross-node gap a fresh reader can't resolve from the page. · *coherence is adjacency* and *intent attaches at the lowest node that dominates it* (a shared state belongs in the registry's design, referenced by the queue).
- **F5 (medium):** All eight specs are marked `[x]` (implemented), but this checkout has no tests or code, so there is nothing to carry `@spec` annotations. If the implementation lives elsewhere, no action is needed. If it doesn't exist yet, consider marking the specs unimplemented so the status reflects reality. · *tests before code* and *tests carry `@spec` annotations* (the arrow can only be walked if the lower phases exist)
- **F6 (low):** The tenets are unordered, yet two of them can conflict: "a submitted job is a promise" against "the service stays small" (durable queue storage adds weight). Consider ordering them so a future session knows which wins. · *tenets capture forward-looking preference*

## What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 1 HLD, 2 LLDs, 2 spec files (8 EARS specs: 5 `QUEUE`, 3 `REG`).
- Cold-read pass and Decisions-table sweep completed on all docs (5 rows, none `[inferred]`).
- Not found: no source files, no tests (so `@spec` linkage was not sampled), no `docs/arrows/` overlay.
- Non-interactive run: no questions were needed. Mode defaulted to the declared Full.

## Offer to help
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into, such as F1 and F2 together.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.