Whole-visit revisions are now written into the record-store design. This is the Phase 2 (LLD) stop, so I haven't touched the specs, tests, or code.

## What changed

**`docs/intent/record-store/record-store-design.md`**
- **Revision model:** every accepted submission is a complete visit that names its base revision. A visit with more than one head has competing revisions and unresolved review work. A submission based on any revision other than the sole head becomes a competing head, so arrival order never decides which one is current.
- **Retrieval:** a visit with competing revisions reports unresolved work and lists the competing heads. It presents none of them as current.
- **Resolution:** a coordinator records a resolution revision that names every current head. It is rejected if a new head arrived after the coordinator opened the comparison.
- **Contract table:** tablet-sync retains base revision IDs and sends full visits. Review-export builds a revision comparison and excludes unresolved visits from the CSV.
- **Decisions & Alternatives:** I recorded the choice as a row, including the merge-rule maintenance and scientific-intent reasoning you gave.

**`docs/high-level-design.md`**
- The record-store state cell and the paragraph that said concurrency was open now state the whole-visit choice.

## Please check these drafted rules
These two follow from the tenets, but you haven't said them:
- A resolution is rejected if the head set changed.
- Retrieval presents no competing revision as current, not even the last settled one.

## Two decisions I need from you
1. **Resolution content.**
   - **(a) Pick one:** the resolution must equal one competing head's content. This is simple, but a visit with two unrelated corrections loses one of them from the current record, and the lost one survives only in history.
   - **(b) Compose:** the coordinator may compose a new visit from several heads. This keeps both corrections, but the comparison screen must support editing and the resolution carries a coordinator-authored payload.
   - Which do you want?
2. **Revision IDs.**
   - **(a) Server-assigned:** tablets must wait for acknowledgement before submitting a second offline edit to the same visit.
   - **(b) Client-supplied:** a tablet can queue a chain of edits while offline, but the server must accept IDs it did not mint.
   - Which do you want?

## Edge-case gaps for you to triage
I ran this probe in-context, not with a subagent.
1. **Out-of-order chain:** an edit arrives whose base is a not-yet-received revision from the same tablet. This depends on decision 2.
2. **Identical competing content:** two workers made the same correction. As drafted, this still creates review work.
3. **Self-resolution:** a coordinator who authored one of the competing revisions resolves it. Nothing forbids this.
4. **Archived plots:** the draft validates plot references but doesn't say whether new submissions to an archived plot are accepted.
5. **No settled ancestor:** a visit's first two revisions compete. Retrieval returns no current state at all, and the tablet-sync display behavior needs to cover that.
6. **No-op revision:** a submission whose payload equals its base.

## Cascade items
- **Decision doc:** this choice will stay live for a cold reader, and tablet-sync and review-export will be sized around it. Do you want a full decision doc in `docs/intent/record-store/decisions/`, or is the table row enough?
- **Cross-segment, awaiting your go-ahead:** `site-catalog-design.md` still says tablet-sync's reconciliation is "pending that choice". I haven't edited it since it sits in another segment.
- **Phase 3:** REC-004's phrase "regardless of the concurrency policy's outcome" will need rewording.

Reply with numbered feedback, including the two decisions, and I'll move on to the EARS specs.