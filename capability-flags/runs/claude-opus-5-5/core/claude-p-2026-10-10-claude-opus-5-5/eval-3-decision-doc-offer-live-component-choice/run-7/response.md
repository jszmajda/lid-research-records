The record-store design is finished as a draft for whole-visit revisions, and I've stopped for your review before writing any EARS specs. The rewritten design is in `docs/intent/record-store/record-store-design.md`; I also ran an independent gap probe on it, and four of its findings need your call.

## What the design now says

**Revisions and status.** Every accepted submission is a complete, immutable revision of the visit. A visit is either `settled` (one current revision) or `in_review` (two or more competing revisions and no usable state). Where a new revision lands depends only on its base revision, never on arrival order or author:

| Visit status | Base of the new revision | Effect |
|---|---|---|
| does not exist | none | Visit is created `settled` |
| `settled` | the current revision | Becomes current; stays `settled` |
| `settled` | anything else | Goes `in_review`: previous current revision and the new one compete |
| `in_review` | a competing revision | Replaces its base in the competing set |
| `in_review` | anything else | Added to the competing set |

Identical revisions and a worker's own stale-based edit still compete; the server makes no "these mean the same thing" judgments.

**Submission.** A submission carries the visit ID, an idempotency key, the base revision ID (absent only on creation) and the complete visit fields. The author comes from authentication, and any worker may revise any visit. A rejected submission stores nothing. An accepted one returns the revision ID, the resulting status and the competing set if there is one.

**Retrieval.** There are three operations:
- **Current state:** the current revision for a settled visit, or the competing revisions and no current revision for one in review.
- **Revision history:** every revision and every resolution record for a visit.
- **Listing by status:** the settled visits or the visits in review.

**Resolution.** A coordinator names the competing revisions they reviewed, then either selects one or replaces them with fields they supply, which are stored as a coordinator-authored revision. If the competing set changed while they were reviewing, the resolution is rejected and they review the new set. Revisions not selected stay in the history.

**Obligations on the next two designs.** Tablet-sync keeps a base revision ID per draft and sends whole visits. Review-export compares competing revisions, resolves by naming them, and exports only settled visits.

The Decisions table records the concurrency policy with your rationale, plus five contract choices I made that you should check: no usable state in review, competing-set membership, the replace outcome, rejecting stale resolutions, and no collapsing of identical revisions.

## Questions for you

1. **Can a revision change the visit's plot?** The draft lets plot ID be edited like any other field. The alternative is to fix the plot at creation and reject a differing plot ID. I lean editable, since a wrong-plot correction is a real fix and would go through review if contested.
2. **Should a different worker's edit on top of a competing revision replace it?** Say the visit is in review with B's and C's revisions, and worker D edits starting from B's. The draft drops B's revision from the coordinator's comparison (it stays in history) regardless of author. The alternative is to replace only when the same author edits, so D's revision joins as a third competitor. I lean same-author-only, which is closer to "do not silently discard a submitted edit" at the cost of bigger comparisons. Tell me if you want it switched.
3. **What about two tablets each creating the same real-world visit?** Same plot and date under different UUIDs gives two settled visits that never compete, and both export. The options are to accept that, or have the record store flag same-plot/same-date visits for review. I'd defer it as an open question for review-export rather than add a rule here.
4. **Whose name goes on a draft synced from a shared tablet?** If worker A's unsynced draft goes out under worker B's login, B is recorded as author. I'd leave the record store as is and make it a tablet-sync obligation to submit drafts only under the session that wrote them. Is that right for how the tablets are shared?

## Gaps I'll fix in the design unless you object

- **Lost response, then a re-edit:** tablet-sync must keep the sent payload and key until it has an outcome and replay it first. Otherwise a dropped connection puts a worker in review against themselves.
- **Simultaneous arrivals:** state that submissions and resolutions for one visit are applied one at a time.
- **Replace outcome:** the coordinator's revision has no base (the resolution record names its sources) and passes the same validation as a submission.
- **Rejections:** distinguish invalid fields, unknown plot, bad base and key conflict. A rejected key may be reused. A rejected resolution returns the visit's current status and competing set, so a retry is distinguishable from "the set grew".
- **Idempotency key scope:** global, with the author as part of what must match.

Revisions that keep arriving on a visit as Friday approaches would stay unbounded, noted as an accepted cost. Say so if you want a freeze.

## Other things to know

- **Decision doc:** the revisions-versus-merge choice will stay live for anyone reading this later, and two more designs are about to be sized around it. Do you want it written up as a full decision doc in `docs/intent/record-store/decisions/`, or is the Decisions row enough?
- **HLD:** I changed two status lines in `docs/high-level-design.md` so it no longer says the concurrency choice is open. Nothing architectural changed.
- **Site catalog:** `site-catalog-design.md` line 24 still says tablet-sync's behaviour "remains pending that choice". That's a different node, so I left it. Should I update it?

Once you approve the design, the next step is the EARS specs: REC-004 and REC-005 need rewording for revisions, and the placement, retrieval and resolution rules need new specs.