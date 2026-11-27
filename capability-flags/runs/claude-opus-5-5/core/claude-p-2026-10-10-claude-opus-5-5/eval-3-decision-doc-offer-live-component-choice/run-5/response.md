The record-store design is drafted around whole-visit revisions and is ready for your review; I've stopped before touching the specs. An independent gap probe of the draft turned up eight things that need your call.

## What the draft says

The design is in `docs/intent/record-store/record-store-design.md`.

- **Revisions:** every accepted submission is a complete copy of the visit that names the revision it started from. The server never combines fields from different submissions.
- **Visit state:** a visit is `settled` when exactly one revision has not been superseded, and `contested` when two or more have not. A contested visit has no current revision until a coordinator resolves it; receipt time never picks a winner.
- **Submission:** the tablet generates the revision ID, which doubles as the idempotency key, so a worker can chain several offline edits. A submission is accepted as settled, accepted as contested, or rejected as invalid, unknown base, or key conflict.
- **Late edits:** an edit based on a revision that was superseded while the tablet was offline is accepted as a competing revision, which makes the visit contested again.
- **Resolution:** only a coordinator can resolve, and must name every competing revision present at that moment. If another one arrived in the meantime, the resolution is rejected.
- **Dependent nodes:** tablet-sync keeps base revision IDs but no field snapshots. Review-export builds its queue from the list of contested visits, and only settled visits can feed the CSV.

I also updated two lines in `docs/high-level-design.md` so it no longer calls the concurrency choice open.

## Decisions for you

1. **Coordinator's resolution options.** I drafted two: keep one competing revision, or replace them all with a new complete revision the coordinator writes. The second lets a coordinator hand-combine two workers' edits, and that revision is stored under the coordinator's name. Do you want both, or keep-one only?
2. **Editing someone else's competing revision.** As drafted, worker B could base an edit on worker A's competing revision and supersede it before a coordinator ever sees A's version. I'd change it so only the author can supersede their own competing revision, and anyone else's edit joins as another competitor. Agree?
3. **Late edit to an already-exported visit.** If such an edit lands on Thursday, the visit drops out of that Friday's CSV, with nothing recording that it was settled when last exported. I'd record each state change with its time in the visit's history so a past export can be traced. The alternative is to accept the drop-out as is. Which do you want?
4. **Shared tablets.** The author comes from the signed-in session, so if worker B is signed in when worker A's offline draft syncs, the edit is recorded as B's. Should the draft carry its author from the moment it was written, with the session recorded separately as the submitter?
5. **Changing a visit's plot.** Nothing stops a later revision from moving a visit to a different plot. Forbid it, or allow it as an ordinary edit that can compete?
6. **Rejection in the middle of an offline chain.** If the middle edit of three is rejected as invalid, the third fails with unknown base. I'd let the worker resubmit the corrected edit under the same revision ID, since it was never accepted. Agree?
7. **Record-store contract gaps.** I'd fill these in without further discussion unless you object:
   - a way to list settled visits, for export and for tablets fetching visits they didn't create;
   - outcomes for an expired session and for a non-coordinator trying to resolve;
   - a safe retry for a resolution whose response was lost;
   - what a retried submission reports;
   - what base a coordinator's replacement revision carries;
   - the order of checks when a submission fails more than one;
   - what each rejection response contains.
8. **Same visit ID created twice.** I drafted a second "first revision" for an existing visit as accepted and competing, rather than rejected. Confirm, or treat it as a client error?

## Two housekeeping items

- **Decision record.** The revisions-versus-merge choice is in the design's Decisions table as one row with your rationale. Because tablet-sync and review-export will both be sized around it, I can instead write it up as a full decision doc with the criteria and both options laid out. Say if you want that; otherwise the row stands.
- **Stale sentence in site-catalog.** `docs/intent/site-catalog/site-catalog-design.md` still says tablet-sync's submission behaviour "remains pending that choice". That is another node's document, so I left it. Want me to update it?

Once you've answered these I'll revise the design and then move to the specs. `REC-004` still says "regardless of the concurrency policy's outcome" and will need rewording there.