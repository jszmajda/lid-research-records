Wrote the decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the LLD's Decisions & Alternatives row.

It records both options at full strength, the weighted criteria (whole-visit intent and maintenance burden as the two majors), why the team still might revisit field-aware merge, and a "Downstream Accommodations" section spelling out what tablet-sync and review-export must each build against — base revision IDs and unresolved-status display versus a competing-revision comparison screen, stale-resolution rejection, and resolved-only export.

Still open from the last round, and I haven't answered them for you:
1. Confirm current-state retrieval returning **no field values** for unresolved visits (REC-013), with tablets reading history instead.
2. Identical competing revisions — auto-resolve or keep in review?
3. Resolutions restricted to tips, or any complete revision?
4. Correct the stale `site-catalog-design.md:24` line about the choice being pending?

No tablet-sync or review-export files were created. Tell me the four calls and whether the LLD/specs are approved as written, or give numbered feedback.