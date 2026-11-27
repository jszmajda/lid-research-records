I've drafted the Phase 2 record-store LLD in `docs/intent/record-store/record-store-design.md`, replacing the open choice with whole-visit revisions. It is a draft for your review; no specs, tests, or code have changed.

## What the draft says

- **Revisions:** Every accepted submission is a complete, immutable visit revision with a server-assigned ID. It names its base revision, and a first submission has none.
- **Head:** A submission based on the head becomes the new head automatically.
- **Competing revisions:** A submission based on anything else (for example, an edit made over days offline) is stored as a competing revision and opens review work for that visit. The server never combines fields from different submissions, and arrival order never picks a winner.
- **Submission envelope:** visit ID, idempotency key, base revision ID, and the full visit payload. The server adds author, receipt time, and revision ID.
- **Current-state response:** the head revision (absent if the visit has only competing revisions), an unresolved flag, and the list of competing revisions.
- **Unresolved work:** One open item per visit. Review-export holds such visits out of the CSV.
- **Resolution:** A coordinator names the revision that becomes the new head. The record store keeps their identity, the contributing submission IDs, and the outcome.
- **Decisions & Alternatives:** One row records your choice and why, including your reasoning about scientifically related edits being merged without anyone noticing.
- **Residue removed:** The "open choice" section and the "not yet designed" language are gone.

## Edge-case probe (LLD-level gaps)

1. **Coordinator-edited resolution.** Can a coordinator resolve by authoring a new revision, or only by picking an existing candidate?
   - If they can only pick, the "fix an observer name" and "add a species" edits can't both reach the export, because one is lost to history.
   - If they can edit, you need a rule for how a coordinator-authored revision is attributed.
   - I recommend allowing coordinator-edited resolutions, but this changes what the exported value means, so it's your call.
2. **Edits based on a candidate.** Tablets display pending competing revisions, so a worker may edit one. Should that edit attach to the open item as another candidate, or be rejected until resolution?
3. **Second open item.** Competing revisions that arrive while review work is already open: should they join the existing item, or stay separate?
4. **Two first submissions.** If the same visit ID arrives with no base from two tablets, there is no head. The draft opens review work with no head. Is that acceptable?
5. **Idempotent retry after resolution.** A retry should return the original acceptance result even though the revision is no longer competing. I'd carry that into the specs rather than the LLD.

Items 1–3 are listed under Deferred in the LLD; I'd like your decisions on them before drafting EARS.

## Questions for you

- **Triage:** Which of items 1–5 do you want fixed in the LLD now, and which stay deferred? Item 1 is the one that most changes the contract.
- **Decision doc:** This choice sets how tablet-sync and review-export are sized, so a full decision doc could be worth it. Should I write one, or is the Decisions row enough?
- **Cross-segment edits:** Two other files still call the concurrency choice open:
  - `docs/high-level-design.md`: the record-store state reads "concurrency choice open", and it says the two downstream designs "must wait".
  - `docs/intent/site-catalog/site-catalog-design.md`: it says tablet-sync's behavior is "pending that choice".

  Should I update both to match? They sit outside the record-store segment, so I haven't touched them.
- **Next phase:** Once you've ruled on the above, I'll move to Phase 3 and update `REC-*` specs. REC-004 and REC-005 need rewording for revisions and the unresolved flag.