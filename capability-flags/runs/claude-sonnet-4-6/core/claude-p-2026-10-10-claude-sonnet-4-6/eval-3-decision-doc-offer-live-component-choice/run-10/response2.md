Decision doc written and linked. Here's what landed:

**`docs/intent/record-store/decisions/visit-concurrency-policy.md`**

The doc covers:

- **Gate**: no silent discard (both options pass — no option gets eliminated on this).
- **Two major criteria** that actually decide it: scientific interpretability (exported record must trace to one identified submission) and scientific relationship preservation (server cannot infer that species ID and cover estimate are coupled; merge rules would have to encode domain knowledge the team doesn't hold). Whole-visit revisions is strong on both; field-aware merge is partial/weak.
- **Field-aware merge's honest strongest case**: the coordinator review volume criterion, where it wins clearly — disjoint edits (observer name correction + species addition) never reach the queue, so review work tracks actual conflicts rather than any co-edited visit. That's a real operational win, and the doc doesn't minimize it.
- **Selection** names the tenets the decision turns on (*inspectable path from observation to export* and the non-goal *no inference of scientific intent*) and is explicit that the queue cost is accepted, not dismissed.
- **Downstream obligations** section covers exactly what you asked for: tablet-sync must track revision IDs per visit and surface needs-review outcomes to workers; review-export must provide a side-by-side comparison screen, coordinator selection action, and exclude needs-review visits with a queue count before export. The tablet state-loss case (no stored revision ID) is called out as an open question for tablet-sync to resolve.

Still at the Phase 2 stop — the four deferred questions from the edge probe (submission-while-needs-review, null base with existing revisions, post-resolution late submissions, concurrent resolution race) are open. Ready to proceed to EARS specs (Phase 3) whenever you're satisfied with the LLD and the doc.