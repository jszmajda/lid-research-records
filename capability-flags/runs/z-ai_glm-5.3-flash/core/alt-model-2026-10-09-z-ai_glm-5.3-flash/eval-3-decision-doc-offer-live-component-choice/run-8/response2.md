The decision doc is written: `docs/intent/record-store/decisions/concurrent-edit-policy.md`.

It covers what you asked for:

- **Why the other approach stays credible** — the Selection section explicitly does not foreclose field-aware merge: the retained base revisions carry everything a three-way merge would need (base state, competing payloads), so the options *compose in that order* — whole-visit revisions first, merge revisit later if review volume outgrows two coordinators. What's foreclosed now is automatic combination without human review.
- **What tablet-sync must accommodate** — retain base revision IDs on drafts, submit complete payloads not diffs, handle an "unresolved — competing revisions pending" outcome, and present that to field workers without implying their edit was lost.
- **What review-export must accommodate** — side-by-side revision comparison views (payloads, authors, receipt times), export eligibility limited to linear revision chains (unresolved visits held out of the Friday CSV), and resolution only through the record store's Resolve operation.

It also records why the decision is criterion-driven rather than gate-driven: the "no silent loss" gate passes under both options, so it turns on the two major criteria — merge-rule burden and whole-visit scientific intent — with the larger review queue accepted deliberately as the visible, correctable alternative to an invisible wrong merge.

The LLD's Decisions row and Open Questions now link to the doc.

Still open from the Phase 2 stop: the **edge-case probe triage** (10 gaps listed last message — my suggestion was fixing 1–3 and 9–10 structurally now, 4–8 as one-liners alongside). Tell me which to fix in the LLD and which to defer, and record-store is done; then we move to tablet-sync and review-export as planned.