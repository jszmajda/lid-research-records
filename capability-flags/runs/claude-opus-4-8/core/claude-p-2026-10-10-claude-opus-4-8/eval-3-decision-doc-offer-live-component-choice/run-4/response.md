Phase 2 is drafted. Here's where record-store stands, with the edge-case probe for you to triage before we move to specs.

## What I did

Closed the `OPEN` concurrency choice and rewrote `record-store-design.md` around **whole-visit revisions**. The core now reads:

- Each submission is a **complete payload + a `baseRevisionId`**. The server **never combines fields** — two accepted submissions sharing a base stand as **competing revisions** for a coordinator to resolve.
- Every accepted submission is an **immutable revision**; editing appends, never mutates. (Realizes "never silently discard a submitted edit.")
- A visit is **settled** (single line, one current revision) or **unresolved** (a fork exists). A base-is-current edit extends the line; a base-isn't-current edit is accepted as a competitor and forks the visit — never rejected for being late (REC-004).
- `authorId`/`receiptTime` are server-stamped so arrival order and client clocks can't confer authority.
- Retrieval reports the unresolved flag and returns the competing set rather than guessing; resolution records coordinator identity + contributing revision IDs + outcome (REC-006) and keeps the losers in history.
- I recorded the mechanism choice (and the rejected field-aware merge) in the Decisions & Alternatives table, with your "larger review queue over merge rules" rationale.

I left the existing `REC-001..006` spec file untouched — spec edits are Phase 3, after you've signed off on this LLD.

## Edge-case probe — please triage (fix-in-LLD vs defer)

I ran the probe against the drafted doc alone (delegated to a blind reader given only the two files). Grouping to the load-bearing gaps. The first three are **genuine forks** — the doc admits more than one reading, and I don't want to pick for you:

1. **Fork-detection referent while unresolved.** The fork rule says "base is not the current revision," but an unresolved visit has *no* current revision. Does any outstanding fork force the whole visit unresolved, and what does a new edit's base compare against during that window?
2. **Chained edits during the unresolved window / basing off a dead revision.** An edit arrives based on one competitor (or a losing/superseded revision) while the visit is unresolved. Does it deepen that branch, become a third competitor, or get held/rejected until resolution?
3. **Duplicate roots & visitId reuse.** Two submissions both omit `baseRevisionId` for the same `visitId` (or a first submission *carries* a base; or a reused `visitId` describes a different plot). Reject the second, treat as competing roots, or collapse? And is a visit pinned to one plot, or can competitors name different plots?

The rest I'd expect to mostly **fix in the LLD** but want your call on scope:

4. **Resolution mechanics & post-resolution tree.** What `baseRevisionId` does the new current revision carry; how are losers marked; multi-branch/nested forks; resolving an already-settled visit; concurrent coordinators; and whether a *late* competitor can reopen a just-settled visit.
5. **Idempotency comparison scope.** Does "identical payload" include `baseRevisionId`? A retry with the same payload but a different base is currently undefined (dup vs REC-003 conflict vs new fork). (Retention window and whether resolution may author a new reconciling revision are already in Deferred.)
6. **Rejection error shapes.** Malformed payload, unknown plot, foreign base, and idempotency conflict all just "reject" — clients can't yet tell a permanent conflict from a transient one.
7. **Plot-reference binding & authorization.** Snapshot vs live binding when a catalog plot is later archived/renamed; and who may resolve (the "coordinator" role) vs ordinary workers — access control inside this node is currently unstated. (Note the HLD non-goal is only *replacing the identity provider*; a role rule here is still fair game.)

## Two things to decide alongside the LLD

- **Decision doc?** The mechanism choice clears the bar for a full decision doc — two credible options, traded against review-workload vs. implementation-burden vs. scientific-relationship safety, and both downstream nodes will be sized around it. I can write one at `docs/intent/record-store/decisions/` so a cold reader can re-run the judgment, **or** just keep the Decisions & Alternatives row I already added. Which do you want?
- **HLD cascade (pending your OK).** The HLD still says record-store is "concurrency choice open" and that tablet-sync/review-export "must wait for its contract." Once you approve this LLD I'll update that status line and prose to reflect the settled choice — I've left the root untouched for now rather than edit it ahead of your sign-off.

**Stopping here for your review.** Tell me which probe items to fold into the LLD vs. defer (especially forks 1–3), your decision-doc preference, and whether the HLD edit is approved — then I'll revise the LLD and move to Phase 3 (EARS). We'll hold tablet-sync and review-export until record-store is done, as you said.