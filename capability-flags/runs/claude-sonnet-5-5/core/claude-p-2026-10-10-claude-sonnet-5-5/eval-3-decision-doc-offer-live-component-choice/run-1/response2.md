I wrote the decision up as a standalone doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`. It is linked from the record-store LLD's Decisions & Alternatives row.

**What the doc covers**
- **Criteria:** one gate (no original submission discarded) and weighted criteria. Those are scientific coherence and coordinator review workload (both major), plus maintenance burden, tablet complexity and export-ready share (moderate). Each is tied to the HLD tenet or non-goal it comes from.
- **Both options:** each is described at its strongest and rated against every criterion. Field-aware merge scores best on review workload and export-ready share, and worse on coherence and maintenance.
- **Why whole-visit revisions:** the server cannot know which field edits are scientifically related, and an unnoticed combination reaches the partner as a wrong observation. A larger queue is visible and clearable.
- **When to reconsider field-aware merging:** if a season's review volume shows two coordinators can't clear competing revisions before Friday, and the unrelated-field edits that dominate the queue can be caught by a small, auditable rule set. Per-field provenance and manual approval of combinations would stay.
- **Tablet-sync must:**
  - keep each draft's base revision ID, immutable across restarts and disconnection;
  - send whole visits with the base revision ID and idempotency key;
  - show workers when their visit has competing revisions;
  - build its retry logic around the immutable base ID.
- **Review-export must:**
  - provide a comparison view of competing revisions, with authors, receipt times and the shared earlier revision;
  - support resolution as record-store defines it;
  - hold unresolved visits out of the CSV and show which were held out before Friday;
  - trace each exported row to its revision and resolution.

**Still open, as before**
- **The four LLD questions are unanswered:** what a resolution outcome may be, an edit based on one of several competing revisions, same-author same-base submissions, and competing first submissions. The doc says "resolution as record-store defines it" because I haven't settled them for you.
- **The HLD still reads "concurrency choice open".** Should I update it, or leave it until you've approved the LLD?
- **The specs are untouched.** After your answers I'll update them next; REC-004 to REC-006 and new specs for the revision graph will need drafting.