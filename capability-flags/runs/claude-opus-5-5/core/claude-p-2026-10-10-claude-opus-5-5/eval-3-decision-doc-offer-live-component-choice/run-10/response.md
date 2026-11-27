The record-store design is rewritten around whole-visit revisions and is ready for your review. It is uncommitted, and the EARS specs are untouched until you approve this.

## What I changed

- **`docs/intent/record-store/record-store-design.md`**: the open choice is replaced by the full contract, shown in full below.
- **`docs/high-level-design.md`**: two wording changes only. The record-store state now reads "Drafted", and the sentence saying the other two designs "must wait" now says they build on the record-store contract.

## The design

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Concurrent edits are handled as whole-visit revisions: every submission is a complete visit, the server never combines fields from different submissions, and edits that compete for the same starting state go to a coordinator. Tablet-sync and review-export build on the contract defined here rather than defining their own concurrency semantics.

## Architecture

The record store exposes authenticated submission, visit retrieval, revision-history retrieval, review-queue listing, and resolution operations. Persistence keeps every accepted submission unchanged, with its author and server receipt time.

A visit's scientific fields are observation date, observer list, species cover estimates, and notes. Some edits to them are unrelated, such as correcting an observer name and adding a missing species. Others are related, such as revising a species identification and its cover estimate. The server cannot infer all such relationships from field names, so it treats the visit as the unit a worker vouches for.

## Revisions

A **revision** is one accepted submission: a complete set of the visit's fields, immutable once accepted. Each revision records:

| Field | Source | Meaning |
|---|---|---|
| Revision ID | Server | Identifies the revision; returned in the acceptance result |
| Visit ID | Client | The visit this revision belongs to |
| Base revision ID | Client | The revision the worker was editing from; absent when the worker created the visit and on a revision a resolution produced |
| Resolution ID | Server | Present only on a revision a coordinator supplied through a Replace resolution |
| Payload | Client | Plot ID, observation date, observer list, species cover estimates, notes |
| Author ID | Server, from authentication | The worker or coordinator who submitted it |
| Receipt time | Server | When the server accepted it |

A revision **supersedes** its base, and a resolution supersedes the competing revisions it does not keep. A revision nothing has superseded is a **head**. A revision **descends from** its base and from everything its base descends from; a revision a resolution produced descends from every revision that resolution resolved. A visit's state follows from its heads:

- `settled` — exactly one head. That head is the visit's current revision.
- `in_review` — two or more heads. These are the visit's **competing revisions**, and the visit has no current revision until a coordinator resolves them.

Competing revisions arise whenever an accepted submission's base has already been superseded, or two submissions create the same visit. The server applies no other test: it does not compare payloads, authors, or receipt times to decide whether two edits conflict or which should prevail. Two workers who correct unrelated fields of the same visit from the same base therefore produce an `in_review` visit.

A revision whose base is one of several competing revisions supersedes only that base. The visit stays `in_review` with the same number of heads, and the worker's newer revision takes its base's place among the competing revisions.

Because a base may have been superseded long before a tablet reconnects, a revision can compete with a head that a coordinator has already produced by resolution. The visit returns to `in_review`; earlier resolutions remain in its history.

## Submission

### Envelope

| Element | Required | Notes |
|---|---|---|
| Idempotency key | Yes | Client-generated; unique per intended edit |
| Visit ID | Yes | Client-generated UUID |
| Base revision ID | When editing an existing visit | Omitted only when the worker created the visit on the tablet |
| Payload | Yes | The complete visit, not a set of changed fields |

The author comes from the authenticated session, never from the envelope.

### Acceptance

The server authenticates the worker, validates field types and the plot reference, and checks that a named base revision exists and belongs to the named visit. An accepted submission becomes a revision. The acceptance result carries the new revision ID, the visit's resulting state, and the visit's head revision IDs, so a tablet learns immediately whether its edit is current or competing and with what.

Acceptances for one visit are applied one at a time, so the heads reported in a result reflect every earlier acceptance.

### Rejection

A rejected submission creates no revision and changes no visit state.

| Reason | Cause |
|---|---|
| `unauthenticated` | No valid worker session |
| `invalid_payload` | A field fails type validation, or the plot ID does not resolve in the catalog |
| `unknown_base` | The base revision ID does not exist or belongs to a different visit |
| `idempotency_conflict` | The idempotency key was already accepted with a different envelope |

A superseded base is not a reason for rejection; it produces a competing revision.

### Retries

A retry with a previously accepted idempotency key and an identical envelope returns the original revision ID and creates nothing. The state and heads in that response describe the visit as it is at the time of the retry, since the tablet needs the present state rather than a replay of the past one.

## Retrieval

**Visit retrieval** returns the visit's state and:

- when `settled`, the current revision;
- when `in_review`, every competing revision in full, plus their common starting point when one exists: the most recent revision from which every competing revision descends. It is supplied for comparison only and is not the visit's current revision.

Callers cannot obtain a single "current" payload for an `in_review` visit. Any consumer that needs one value per visit, including the partner export, must treat `in_review` visits as not ready.

**Revision history** returns every revision of a visit with its author, receipt time, base, and what superseded it (a later revision or a resolution), together with every resolution. History is the inspectable path from any submitted observation to the visit's current value.

**Review queue** lists the visits currently `in_review` with their competing revision IDs and the receipt time of the earliest competing revision, so review work can be sized and ordered without retrieving every visit.

## Resolution

A coordinator resolves an `in_review` visit by naming the competing revision IDs they reviewed and one outcome:

- **Select** — one of the competing revisions becomes the visit's current revision, unchanged.
- **Replace** — the coordinator supplies a complete visit payload, which is accepted as a new revision authored by the coordinator and becomes the current revision. This is how a coordinator carries forward corrections from more than one competing revision; the combination is the coordinator's own judgment and is attributed to them.

A resolution supersedes every competing revision other than the resulting one, leaving the visit `settled`. The resolution record keeps the coordinator's identity, the time, the competing revision IDs it resolved, the outcome kind, and the resulting revision ID. Superseded revisions remain retrievable through history.

A resolution is rejected with `stale_review` when the named revision IDs are not exactly the visit's current competing revisions — for example, when another competing revision arrived while the coordinator was reviewing. The coordinator then reviews the current set. Resolution is also rejected for a visit that is not `in_review`, for a caller who is not a coordinator, and for a Replace payload that fails submission validation.

## Obligations on Dependent Nodes

Tablet-sync retains, for each visit it holds, the revision ID its local copy was fetched or accepted as, sends it as the base of the next edit, and presents the state and heads from acceptance results to the worker. It submits a worker's successive offline edits to one visit in order, each based on the revision ID returned for the one before.

Review-export presents competing revisions side by side from visit retrieval, submits resolutions naming the revisions shown, and includes only `settled` visits in the partner CSV.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrency policy | Whole-visit revisions; competing revisions go to a coordinator | Field-aware three-way merge: tablets send a base snapshot and structured changes, disjoint field changes combine automatically, only overlapping changes are reviewed, with field-level provenance for the combined record | A merge needs maintained rules for scalar fields, observer lists, and species entries, and those rules can combine scientifically related edits (a species identification and its cover estimate) into a visit no worker submitted, without anyone noticing. A larger review queue is the accepted cost of never doing that: edits to unrelated fields also need a coordinator, and those visits miss the Friday export until resolved. |
| What makes revisions compete | Graph position only: a superseded base, or duplicate creation | Auto-settling when payloads are identical; preferring a revision by the same author as its sibling | Any content or author test is a merge rule in miniature and reintroduces server judgment about which submission is authoritative. |
| Current value of an `in_review` visit | None | Serving the last settled revision as current; serving the most recently received competing revision | Either would let a consumer export a value a pending correction disputes, and the second makes arrival order authoritative. |
| Resolution outcomes | Select a competing revision, or Replace with a coordinator-authored revision | Select only | With Select only, a coordinator facing two valid corrections must discard one and have it re-entered from a tablet. Replace keeps the combination a human, attributed act. |
| Resolution against a changed set | Reject with `stale_review` | Apply to the revisions named and leave later arrivals competing | A coordinator's outcome is a judgment about everything outstanding; applying it past a revision they did not see would settle the visit on incomplete review. |
| Revision ID origin | Server-assigned on acceptance | Client-generated revision IDs doubling as the idempotency key | An ID that exists only once the server accepted the revision cannot name a base the server never saw; the cost is that offline edits to one visit must be submitted in order. |

## Open Questions & Future Decisions

### Deferred

1. Withdrawing a visit entered in error (wrong plot, duplicate entry). No operation removes a visit from retrieval or export.
2. Retention period for superseded revisions and resolution records across seasons.

## References

- docs/high-level-design.md
- docs/intent/site-catalog/site-catalog-design.md — plot ID resolution, including archived plots
```

## Choices I made that you didn't

Each of these has a row in the Decisions table; overrule any of them.

- **Coordinators can Replace as well as Select.** A coordinator can type in a combined visit rather than only pick a winner. Say so if you want pick-one only.
- **Identical competing edits still go to review.** Two workers making the same correction do not auto-settle, which follows your preference but adds queue volume.
- **A visit in review has no current value.** Callers get the competing revisions and their common starting point, never a "current" payload.
- **A resolution is rejected if a new competing revision arrived mid-review.** The coordinator reviews the updated set instead.
- **Revision IDs are server-assigned.** Offline edits to one visit must therefore be submitted in order.

## Gaps for you to triage

A cold-reader subagent probed the draft. It found two drafting defects, which I fixed in the text above: the "common starting point" definition was wrong, and a Replace revision had no defined base. It found nothing wrong in the head-counting rules, which is where it looked hardest. For each of the rest, tell me "fix as recommended", "fix differently", or "defer".

1. **Authorship on shared tablets.** Author and time are taken from the session at sync, so worker A's queued edits synced under worker B's login are attributed to B at sync time. This works against the "inspectable path" tenet. I recommend adding a tablet-recorded author and edit time to the envelope, kept alongside the authenticated submitter.
2. **Rejected offline edits.** A rejected submission leaves no server record, so it exists only on a shared tablet, and any later queued edit to that visit has no base. This strains "do not silently discard a submitted edit". I recommend the server keep rejected submissions with their reason, visible to coordinators; how the tablet re-bases belongs to tablet-sync.
3. **Changing a visit's plot.** Nothing stops a revision from naming a different plot than its base, while the deferred "withdraw a visit" item implies a wrong plot isn't correctable. I recommend allowing it as an ordinary revision.
4. **Resolution errors and races.** Only `stale_review` has a name, two coordinators resolving at once is unspecified, and resolutions have no idempotency key. I recommend naming all the rejections, applying resolutions in the same per-visit order as submissions, and adding an idempotency key.
5. **Idempotency details.** The design does not say whether a key is scoped to its author, whether a rejected key can be reused with a corrected envelope, or whether a retry is re-validated. I recommend: scoped to the author, reusable after rejection, not re-validated.
6. **Review-queue age.** "Receipt time of the earliest competing revision" can make a long-disputed visit look fresh, or a just-reopened one look old. I recommend recording an "entered review at" time instead.
7. **Reopened after export.** A settled visit that already went out in a Friday CSV can return to review and drop out of the next one, and the contract gives review-export no way to notice. I recommend a "state changed since" query here; what the export does about it belongs to review-export.
8. **Workers aren't told their revision lost.** A worker who keeps editing from a superseded revision silently reopens the visit. I recommend that acceptance results say when the base was superseded by a resolution.

## Recording the concurrency choice

Whole-visit revisions versus field-aware merge is currently one Decisions row. A reader facing a full review queue next season will likely want to revisit it, and two more designs are about to be sized around it. I can write it up as a decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, with both options and the criteria laid out, or leave it as the row. Which do you want?

## Left alone

- **Record-store specs.** `REC-004` still says "regardless of the concurrency policy's outcome" and `REC-005` still says "unresolved review work"; revising them is the next phase.
- **Site-catalog design.** One line says tablet-sync's behaviour "remains pending that choice". It is now stale, but it is another node's document; say the word and I'll update it.

Reply with approval or numbered changes to the design, your triage of the eight gaps, and the decision-doc answer. I'll then revise the specs for your review.