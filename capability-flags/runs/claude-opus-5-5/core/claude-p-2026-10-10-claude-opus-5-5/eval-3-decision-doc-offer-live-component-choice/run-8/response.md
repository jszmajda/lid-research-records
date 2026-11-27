The record-store design is drafted around whole-visit revisions, but not finished: an independent gap probe turned up one hole in the contract and a few calls that are yours. Nothing is committed, and the EARS specs are untouched until you approve this design.

## What the design now says

The full text is in `docs/intent/record-store/record-store-design.md`.

- **Revisions:** every accepted submission is a complete, immutable copy of the visit with a server-assigned revision ID, author, receipt time and parent(s).
- **State:** a visit's heads are the revisions no other revision names as a parent. One head means `settled`, and that head is the current revision. Two or more means `unresolved`, with no current revision.
- **Submission envelope:** idempotency key, visit ID, base revision ID (absent when creating the visit) and the complete visit fields. The author comes from authentication.
- **Acceptance:**
  - A submission based on a current head replaces that head.
  - A submission based on an older revision, or one with no base for a visit that already exists, is added as a competing head.
  - Two edits from the same base always end up competing, whichever arrives first.
- **Rejection:** rejected submissions are not stored and name a reason: `unauthenticated`, `invalid_fields`, `unknown_plot`, `unknown_base` or `key_reused`.
- **Retrieval:**
  - Get visit returns the state plus the current revision, or all competing revisions in full.
  - Get visit history returns every revision.
  - List visits can be filtered by state.
- **Resolution:** coordinator only. It names the competing revisions reviewed and supplies the complete visit to settle on. It is rejected as `stale_resolution` if the heads have changed since the coordinator fetched them.

I made three design calls beyond your choice; each is recorded in the Decisions table, so say if any is wrong:

- **Unresolved visits have no current revision.** The alternative was to keep serving the last revision from before the edits diverged.
- **A coordinator can compose the resolved visit from several revisions.** The alternative was pick-one only.
- **Workers can keep editing an unresolved visit.** The edit advances their competing revision; the alternative was to reject edits until review is done.

## Changes outside record-store

- **High-level design:** I removed "concurrency choice open", restated the contract paragraph, and added a Vocabulary section (revision, base revision, competing revisions, unresolved visit). The terms sit there because tablet-sync and review-export will both use them.
- **Site catalog (not changed):** its design still says tablet-sync's behavior "remains pending that choice". That is now stale, but it is another node's document, so I left it. Question 9 below asks whether to fix it.

## Questions for you

1. **Chained offline edits.** Revision IDs are server-assigned, so a worker who edits a visit twice before syncing can only name the same base twice and ends up competing with themselves. I recommend the tablet assign the revision ID, which then doubles as the idempotency key, so a queued edit can name the pending one as its base. The alternative is to require the tablet to collapse queued edits into one submission. Which do you want?
2. **Identical competing revisions.** Two workers who compare notes and make the same correction still produce review work in this draft. Should competing revisions with identical fields settle automatically, or still go to a coordinator?
3. **Shared-tablet retries.** If worker A's submission is accepted but the response is lost, and the retry goes out under worker B's login, it is rejected as `key_reused`. I recommend keeping that, returning the original revision ID and author in the rejection, and obliging tablet-sync to send queued edits under the login that made them. OK?
4. **Changing plot or date.** May a later revision change a visit's plot or observation date? I recommend yes, since a wrong plot is a legitimate correction and it goes through the same revision rules.
5. **Validation scope.** "Field types" is too loose. I propose requiring plot, date and at least one observer; notes optional; species list may be empty; cover between 0 and 100; nothing else checked. Please correct this to your domain.
6. **Resolution note.** A resolution can contain values found in none of its parents, with nothing recording why. I recommend an optional free-text note on resolutions, to keep the path to an exported value inspectable.
7. **Rejected edits.** A rejected submission lives only on the tablet. I recommend accepting that, since rejection is explicit and not silent, and noting an obligation for tablet-sync to keep the draft. OK?
8. **Decision record.** The revisions-versus-merge choice is one a later reader may want to reopen, and two more designs are about to be sized around it. It currently has a row in the Decisions table. Do you want a full decision doc with both options and the criteria, or is the row enough?
9. **Site catalog.** Shall I update its stale sentence?

## Fixes I'll make unless you object

- **Idempotency first:** the idempotency check runs before every other check, so retrying an accepted resolution returns the original result, not `stale_resolution`.
- **Key memory:** keys are remembered indefinitely, and a key from a rejected submission can be reused.
- **New rejection reasons:** `unknown_visit` for a visit that does not exist, and `not_unresolved` for a resolution against a settled visit.
- **Rejection order:** when several reasons apply, a fixed order decides which is reported.
- **Retry response:** a retry returns the heads as they are now, and "identical" means the same field values, with list order significant.
- **Revision kind and ordering:** kind follows the operation used, not the caller's role, and history is ordered by receipt time.

Once you've answered, I'll revise the design and then move to the EARS specs. REC-004 and REC-005 need rewording for the chosen policy, and most of the contract above has no spec yet.