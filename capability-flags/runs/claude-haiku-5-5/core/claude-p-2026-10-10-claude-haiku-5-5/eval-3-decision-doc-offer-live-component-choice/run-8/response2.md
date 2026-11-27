I wrote the decision doc at `docs/intent/record-store/decisions/concurrency-policy.md`. It covers:

- **The decision:** whole-visit revisions, with a stated cost. Coordinators will resolve more conflicts, including conflicts between unrelated corrections.
- **Why the other approach is still considered:** field-aware merge is a real option, not a strawman. It would reduce review volume and submission size, and it would get more visits to the Friday export. The doc names three measured conditions under which it should be reconsidered, and notes that a narrowed hybrid is the most likely future form.
- **What tablet-sync must accommodate:** base revision IDs on each draft, display of pending competing revisions, and a rebase path when a draft's base has been superseded.
- **What review-export must accommodate:** a revision comparison view and an export rule that holds out any visit with unresolved competing revisions.

Still open:

- **Friday export and held-out visits.** The doc doesn't decide how the partner's CSV reports visits that were excluded because they're unresolved. This needs your call before review-export is designed.
- **Link from the record-store design.** The design doc has no Decisions table yet, so the link to this doc will go in during Phase 2, when I rewrite the design doc's OPEN section.
- **Tenet candidate.** I haven't added the tenet about coordinator review over automatic combination to the HLD. The doc cites only the two existing tenets. Say the word if you want the new one added, and how you'd word it.
- **Phase 2.** Once you approve this and the HLD change, I'll draft the record-store LLD and then the EARS changes, with a stop after each.