**Phase 1 — HLD check (coherence pre-flight).** `docs/high-level-design.md` already covers this domain and assigns the concurrency mechanism to record-store, so no architectural change. I did correct one stale status note: the record-store row no longer says "concurrency choice open," and the paragraph below the table now describes tablet-sync/review-export as building on record-store's contract rather than waiting on an unresolved choice.

**Phase 2 — Record Store LLD (finished):** `docs/intent/record-store/record-store-design.md`

The whole-visit revision model is now written out:

- **Each accepted submission stores one revision** — a complete visit snapshot with a server-assigned `revisionId` and a named **base revision** (or none when creating the visit). Revisions form a tree by base.
- **Revision status:** `open` (leaf, current-eligible), `superseded` (has children), `closed` (leaf a resolution set aside).
- **Visit state:** `resolved` = exactly one open revision (that's the current state); `contested` = two or more open revisions (not exportable). No field merging ever.
- **Submission envelope, current-state response, and unresolved-work representation** are specified, including the `conflict` object (`commonAncestorRevisionId` + `competingRevisions`) that review-export's comparison screen consumes.
- **Resolution operation** — coordinator names the winning `selectedRevisionId`; the store records coordinator identity, selected revision, contributing submission IDs, and time; the winner stays `open`, the rest go `closed`, and all history is retained. A later submission based on a closed/superseded revision reopens the visit as contested.
- The rejected **field-aware three-way merge** is recorded in Decisions & Alternatives with why it lost.

The specs file (`record-store-specs.md`) is unchanged for now — that's Phase 3.

**Decision doc:** this choice is consequential and stays live (the review-queue-vs-merge-rules trade, with tablet-sync and review-export about to be sized around it). Want me to record it as a decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or leave the Decisions & Alternatives row as the record?

**Edge-case probe (Phase 2)** — gaps in the LLD for you to triage:

1. **Resolution scope** — should a coordinator only *select* an existing revision, or also be able to author a new combined revision? I designed select-only (your stated rationale was about not maintaining *automatic* merge rules), but manual combination is a genuine alternative.
2. **Reopening after resolution** — I made a post-resolution submission based on a `closed`/`superseded` revision reopen the visit as contested. Confirm that's intended, vs. rejecting stale bases and telling the worker to refresh.
3. **Identical competing revisions** — two workers submitting byte-identical corrections still produce two `open` revisions and enter the review queue. Acceptable, or should identical payloads collapse?
4. **Unknown/foreign base revision** — I chose to reject a `baseRevisionId` that isn't an existing revision of the visit. Confirm.
5. **Unbounded review queue** — no cap on competing revisions per visit; is that fine for release 1?

Please give numbered feedback / approve, and tell me whether to write the decision doc — then I'll draft the EARS updates for record-store.