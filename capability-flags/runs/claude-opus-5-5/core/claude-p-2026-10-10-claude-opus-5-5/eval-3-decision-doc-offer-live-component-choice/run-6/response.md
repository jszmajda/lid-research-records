The record-store design is drafted around whole-visit revisions and is ready for your review. I've stopped before touching the EARS specs. Nothing is committed.

## What the design now says

Full text is in `docs/intent/record-store/record-store-design.md`.

- **Revisions:** every accepted submission is a complete visit, stored as one immutable revision that names the revision it was edited from (its base). The server assigns revision IDs.
- **Visit state:** a visit is `settled` when exactly one revision has nothing built on it; that one is the current revision. It is `unresolved` when two or more do; those are the competing revisions.
- **Stale edits:** an edit whose base has already been built on is accepted as a competing revision, never rejected. Author, tablet and arrival order play no part.
- **Resolution:** a coordinator submits a complete visit and names every competing revision they reviewed. If another revision arrived in the meantime, the resolution is rejected and returns the present set.
- **Retrieval:** a visit (current revision, or all competing ones), its full revision history, and the list of unresolved visits, which is the review queue.
- **Downstream:** tablets keep base revision IDs and send complete visits. Export reads only current revisions, so unresolved visits stay out of the CSV.

I also updated `docs/high-level-design.md` so it no longer describes the concurrency choice as open.

## Choices I made that you should check

Each is a row in the Decisions table:

1. **An unresolved visit has no current revision at all.** The catch is that a visit exported one Friday can drop out of the next CSV if a competing revision arrives in between.
2. **Identical competing payloads still go to review.** Settling them automatically would shrink the queue, but the state rule would then depend on comparing content.
3. **Coordinators may write a combined visit when resolving**, not only pick one side. Picking one side would discard the other worker's unrelated correction.
4. **Server-assigned revision IDs.** Tablets must therefore submit queued edits to one visit in order, each waiting for the previous acceptance.

## Gaps from a cold-read probe

A reader given only the HLD and this design raised these. Tell me which to fix now and which to defer.

1. **Coordinator corrections to a settled visit:** the design doesn't say whether a coordinator can submit an ordinary revision. I'd allow it.
2. **Previously exported visits that become unresolved:** the row vanishes from the next CSV and the store keeps no record of what was exported. I'd leave "what was exported" to review-export, but this touches the inspectability tenet, so it is your call.
3. **Rejected submissions after 48 hours offline:** an edit rejected for an invalid payload or unknown plot exists only on a shared tablet, invisible to coordinators. The alternative is to store it and send it to review.
4. **Plot ID changing between revisions of one visit:** unstated. I'd allow it as a correction like any other field.
5. **Who may edit which visit:** I assumed any authenticated worker can edit any visit, and that "author" means the logged-in account, not the observers listed.
6. **Smaller items:** what happens to the rest of an offline queue when one edit is rejected, how tablets learn of a resolution, what counts as an "identical" retry, which rejection wins when several apply, and how far validation goes beyond field types.

## Three other questions

- **Scope of review:** I assumed competing revisions are the only review work the record store knows about. If "reviewed CSV" means coordinators approve every visit before export, does that approval belong here or in review-export?
- **Decision doc:** the revisions-versus-merge choice is one a later reader may want to reopen, and two more designs are about to be sized around it. Do you want a full decision doc in `docs/intent/record-store/decisions/`, or is the table row enough?
- **Site-catalog wording:** `site-catalog-design.md` still calls the concurrency choice "pending" in two sentences. May I update them? It is a different node, so I left it alone.

Once you approve the design, the next step is the EARS specs. REC-004 and REC-005 need rewording for the new model, and the state rule, resolution and rejections need new specs.