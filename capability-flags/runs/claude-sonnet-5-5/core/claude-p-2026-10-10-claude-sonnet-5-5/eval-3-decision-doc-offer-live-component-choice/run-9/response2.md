The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md`. The record-store Decisions row now links to it. Nothing is committed.

**What the doc covers**
- **Context:** the offline, shared-tablet situation and why a visit's fields can't be treated as independent.
- **Decision elements:**
  - Two gates: no original submission is lost, and capture continues offline.
  - Six weighted criteria, each tied to a tenet or goal: fidelity to what was submitted, risk of combining related fields, review volume, maintenance burden, export-readiness, and tablet storage.
- **Options:** both approaches are described as their advocates would, with a fit verdict against each criterion.
- **Selection:** whole-visit revisions, turning on the "do not silently discard" and "inspectable path" tenets and the non-goal of inferring scientific intent.
- **Why the other approach stays credible:** if review volume outgrows what two coordinators can clear before Friday, field-aware merging becomes the better trade, possibly only for fields with no scientific relationships such as notes. Because originals and base revisions are all kept, a merge policy could be applied to new submissions later without reinterpreting history. The signals to revisit are sustained queue growth, or many review items that coordinators resolve by keeping both edits unchanged.
- **Obligations on tablet-sync:**
  - Keep each draft's base revision ID and send it with every submission.
  - Store whole visits, not change sets.
  - Show which of a worker's submissions are pending against competing revisions.
  - Keep the idempotency key and base revision of an unacknowledged submission so a retry is identical.
- **Obligations on review-export:**
  - A comparison view of competing complete revisions, and the resolution operation.
  - Exclude unresolved visits from the CSV.
  - Report how many were held out, so the Friday export is explainable.

**Still waiting on you**
- The LLD review: the three open questions are unchanged (what a resolution may contain, what retrieval returns while unresolved, and first submissions with no head). The doc deliberately doesn't settle them. The tablet and export obligations above hold under any answer. Question 2 will shape how tablet-sync's pending view is fed, and question 1 will shape the export-side resolution screen.
- Approval of the LLD so I can move to Phase 3 (the EARS specs).