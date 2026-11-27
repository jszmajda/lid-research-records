The record-store LLD is now written around whole-visit revisions, and the HLD’s stale “concurrency choice open” state is corrected. Tablet-sync and review-export were left untouched.

**Core contract now in `docs/intent/record-store/record-store-design.md`**
- Each accepted edit is an immutable complete revision with a server-assigned ID and a `baseRevisionId`.
- Revisions form a head set; resolved = exactly one head, unresolved = competing heads.
- A stale base is accepted as a competing head rather than rejected or rebased.
- A coordinator resolution selects exactly one submitted revision, with the reviewed head set as a precondition so a newly arrived competitor cannot be missed.
- Unresolved visits are not exportable; export uses the single current revision.
- The submission envelope, retrieval shape, unresolved queue, resolution request, and downstream obligations are specified.

**LLD edge-probe gaps for your triage** (I clarified the meaning of “contributing revisions” and the sole-head transition while fixing the draft):
1. Idempotent create retry — does idempotency lookup run before the “null base for an existing visit is rejected” rule?
2. Replay after the head set changes — return the stored response verbatim, or the same revision ID with the current head set?
3. Plot ID identity — is the plot immutable across a visit’s revisions, and which copy is authoritative?
4. “Identical payload” scope — whole submission envelope versus `visit` field only; and does a rejected submission bind its key?
5. Concurrent resolutions — what guarantees a single winner when two coordinators resolve the same head set at once?
6. Resolution retry — no resolution idempotency key; a lost response makes retry indistinguishable from a failed resolution.
7. Error contract — conflict versus invalid, and whether rejection returns the refreshed head set.
8. Retrieval symmetry — resolved responses omit author/base/receipt time; “head revision summaries” is undefined.
9. History ordering — resolution placement and ties in server receipt time.

Which of these should I fold into the LLD now, and which should become deferred open questions?

Two other stops before I proceed:
- **Cross-segment edit:** `site-catalog-design.md` still says tablet-sync’s behavior “remains pending that choice.” Updating it crosses into the site-catalog segment — may I revise that sentence?
- **Decision record:** this choice will stay live for a cold reader and now sizes two sibling nodes. Record it as a full decision doc under `docs/intent/record-store/decisions/`, or keep only the Decisions & Alternatives row?

On approval I’ll move to Phase 3 and update the record-store EARS specs; tablet-sync and review-export remain for the following work.