Phase 2 LLD draft is complete. Here is the stop for your review.

## Phase 2 — record-store LLD updated

I've resolved the open concurrency choice to **whole-visit revisions** and written the downstream contract around it. The full doc is at `docs/intent/record-store/record-store-design.md`. What changed from the open-choice draft:

- **Revision model** — a visit accumulates revisions; each is a complete state with a server-assigned revision ID, author, receipt time, payload, and the **base revision** it was edited from. Placement by base: first submission → first revision; base = current → linear successor; base = a superseded revision → a **competing revision**, and the visit now holds **unresolved review work** with no single current revision. Forks can be N-way.
- **Resolution** — a coordinator designates the new current revision (a competing revision kept intact, or a reconciled revision they author); the server never field-merges. Records coordinator identity, contributing revision IDs, outcome; all original submissions preserved.
- **Public contract** — submission envelope (adds `baseRevisionId`), acceptance response (`current` vs `competing`), current-state retrieval (single current revision vs. the competing set), submission-history retrieval, and the resolution operation's data contract. Coordinator-UI specifics are explicitly deferred to review-export.
- **Decisions & Alternatives** — a row recording whole-visit revisions over field-aware three-way merge, with your rationale (larger review queue preferred over merge rules that can silently combine scientifically related edits), plus a row that the server never reconciles fields on its own.

## Decision to record

You settled this among two sketched options, other nodes will be sized around it, and a cold reader would re-litigate it without the competing options — so it clears the bar for a **decision doc** (`docs/intent/record-store/decisions/`), which would lay out context, criteria, both options, and the selection at enough depth to re-run the judgment. The lighter alternative is the **Decisions & Alternatives row** I've already added, and nothing more. **Want the full decision doc, or is the row enough?**

## Edge-probe gaps to triage

A blind probe of the LLD (within-component only) surfaced these. Please triage each: **fix in the LLD now**, or **park in Open Questions**. I'd flag the first three groups as load-bearing.

1. **Revision lifecycle while unresolved** — The doc defines base = none / current / superseded, but during unresolved work there's no current revision and the competitors are neither. What happens to a submission whose `baseRevisionId` names a *competing* revision? And are new submissions even accepted while a visit is unresolved, or only after resolution? (The only exit from "unresolved" the doc gives is resolution.)
2. **Resolution operation semantics** — Several unstated: winner ID that isn't in the competing set; what `contributingRevisionIds` must be (subset? all? must every competitor be accounted for?); resolving a visit that isn't forked or is already resolved; **two coordinators resolving the same visit at once** (ordering undefined — notable given the node's "arrival order isn't authoritative" stance); and whether a coordinator-authored reconciled revision is itself validated and whether it appears in submission history.
3. **Submission validation & lineage** — Base-revision lineage isn't validated the way field types and plot refs are: unknown `baseRevisionId`, a base belonging to a *different* visit, and a no-base submission arriving for a `visitId` that already has revisions (a stale retry or two tablets originating the same UUID — new first revision, competing, or error?).
4. **Idempotency semantics** — Key uniqueness scope (global / per-visit / per-author) is unstated, as is whether the identical-payload check also compares `baseRevisionId`/`plotId`. Also: a retried key returns the *original* resulting state, so a replay can report `competing` after the fork was resolved — is that stale status intended?
5. **Error shapes** — Not-found / invalid-input behavior for retrieval, history, and resolution against an unknown `visitId` is undescribed.

## One upstream note

The HLD's architecture table still lists record-store as *"Drafted; concurrency choice open"* and says the two downstream designs "must wait for its contract." That cell will be stale once this lands. Since that's an edit to the parent node, I'd rather ask than touch it silently: **want me to update that HLD State cell** (e.g. to "Designed") as part of this, or leave the HLD alone?

On your approval (and your triage decisions), I'll move to **Phase 3 — EARS specs**: refining REC-004/005/006 to the revision vocabulary and adding specs for base-revision placement, competing-revision creation, and the resolution operation.