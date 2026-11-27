I wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the record-store Decisions row. I haven't moved on to the EARS specs.

## What the doc covers
- **Context:** why concurrent edits matter here (offline tablets, scientifically related fields, two coordinators, the Friday export).
- **Criteria:** each is weighted and tied to a tenet or goal. The two major ones are not combining across scientific relationships the system can't see, and a review workload two coordinators can clear before Friday.
- **Both options:** each described in its strongest honest form, with a fit verdict per criterion. Whole-visit revisions are strong on preserving relationships, inspectability, and maintenance, and weak on review load and export readiness. Merge is the reverse, with partial fit on provenance and tablet cost.
- **Selection:** whole-visit revisions, on the grounds that a wrong combined value enters the CSV looking reviewed, while a held-out visit is visible and recoverable.
- **Why we'd still consider merge:** it becomes the better choice if unrelated-field competing revisions dominate the queue and exports routinely hold out many visits that coordinators only approve unchanged. A narrower form could then be revisited: merge only a short list of known-independent fields, with every combined record still shown to a coordinator, built on the same revision history.
- **What the tablet and export work must accommodate:**
  - **Tablet-sync:**
    - Keep a base revision ID for every local edit and send complete visits.
    - Show a worker when their submission is one of several competing revisions.
    - Handle a visit with no current state because its first two revisions compete.
  - **Review-export:**
    - Provide a comparison view and a way to record a resolution.
    - Hold out every unresolved visit and make those visits visible before the Friday export.
    - Plan for review volume to scale with the number of concurrently corrected visits, not with the number of overlapping fields.

## Left out on purpose
- **Review-queue numbers:** I didn't put in a threshold or an estimated queue size, because we have no data for either. The reconsideration condition is stated qualitatively. If you have a figure from past seasons, tell me and I'll add it.
- **Open questions:** the doc doesn't settle the two deferred questions (resolution revision content, revision identifiers). They remain open in the LLD.

## Still waiting on you
- **Decisions:** the two decisions and the edge-case triage from my previous message are still open. Phase 3 depends on both decisions.
- **Site catalog:** `site-catalog-design.md` still says reconciliation is "pending that choice". It's in another segment, so say the word and I'll update it.