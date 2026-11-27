Phase 2 (LLD) is drafted and the edge probe is back. Here's where things stand — this is the Phase 2 stop.

## What I changed

**`record-store-design.md`** — resolved the open concurrency choice to **whole-visit revisions** and finished the node's public contract:

- **Revisions & reconciliation** — every edit is stored as a complete, immutable snapshot that names its `baseRevisionId`. Base = current revision → linear extension; base = a superseded revision → a *competing revision*, and the visit goes *under review*. Nothing is auto-ranked or auto-combined, so related field edits are never split by the server.
- **Public contract** — spelled out the four pieces the node promised downstream: submission envelope (adds `baseRevisionId`), current-state response (carries `unresolvedReviewWork`), unresolved-work representation (the competing snapshots + their shared base), and the resolution operation (coordinator selects which revision becomes current; losers kept in history; contributing submission IDs recorded).
- **Downstream contract obligations** — recorded as *cascade notes only*, not designed: tablet-sync keeps/sends the base revision and shows pending competes; review-export does the whole-visit comparison and holds `unresolvedReviewWork` visits out of the CSV. We do those segments next, as you said.
- **Decisions & Alternatives** — the whole-visit-vs-merge choice with your rationale (bigger queue over merge rules that can silently cross scientific relationships), plus one secondary row: an edit arriving for a visit already under review is kept as another competing revision rather than rejected (rejecting would discard a submitted edit).

**`high-level-design.md`** — the architecture table's record-store status cell said "concurrency choice open"; I refreshed it to "whole-visit revisions" since the HLD itself flagged that as the open item. No architecture change.

I held EARS and everything downstream for the next stop.

## Decision doc — offer

This choice clears the bar for a full decision doc: credible options traded on more than one criterion, and two sibling nodes will be sized around it. I've recorded it as a **Decisions & Alternatives row** (above). If you'd like the competing options and criteria preserved at re-litigation resolution, I can also write a full decision doc under `docs/intent/record-store/decisions/`. The row alone is the alternative — your call.

## Edge probe — gaps for you to triage

A blind reader given only the draft surfaced these internal gaps. Tell me which to pin down in the LLD now vs. defer (I've only *resolved* #1 below in the draft; the rest are open):

1. **N-way resolution** — with 3+ competing revisions, does selecting one resolve the *whole* set (others → history) or only pairwise, leaving the visit still under review? I assumed whole-set; worth confirming.
2. **Editing off a competing revision** — a worker can only retrieve the resolved current state, so bases are always resolved revisions. But should an edit that names a *competing* (unresolved) revision as its base be rejected, or accepted? Currently unstated.
3. **`currentRevision` while under review** — absent/null vs. last-resolved revision in the response.
4. **Resolution validation** — resolving an already-resolved visit, or selecting a `revisionId` that isn't one of the competing revisions: what's the error shape?
5. **Idempotency-key scope & "identical payload"** — is the key per-visit or global, and does "payload" mean the whole envelope (so a differing `baseRevisionId` counts as different → rejected) or just `fields`? This touches existing specs REC-002/003.
6. **Concurrency of two same-base edits** — is acceptance serialized so exactly one extends and the other forks, or could both race in as linear extensions?
7. **Base-presence validation** — first submission carrying a base, or a later one omitting it.
8. Already deferred in the LLD: whether a coordinator may author a *corrected* resolving revision rather than pick one as-is, and the no-op edit case (base is current, payload identical).

Once you've reviewed the LLD, decided on the decision doc, and triaged these, I'll fold your answers in and move to the EARS update (Phase 3) — which will need new specs for base-revision naming, fast-forward-becomes-current, competing-revision creation, unknown-base rejection, and resolution-selects-current, alongside the existing REC-001–006.