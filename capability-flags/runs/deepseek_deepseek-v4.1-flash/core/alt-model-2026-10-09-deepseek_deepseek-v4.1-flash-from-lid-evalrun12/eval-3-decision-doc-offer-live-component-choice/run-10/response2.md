Wrote `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the LLD's Decisions row. It follows the decision-doc shape — Context, Decision Elements (five weighted criteria, no gates, since both options satisfy the HLD tenets), per-option analysis with verdicts, and Selection.

The two things you called out:

- **Why we'd still consider field-aware merge** — its strongest case is carried honestly: it wins the review-workload/export-readiness criterion outright (disjoint edits combine without a coordinator) and its review surface is small. Selection names the trigger to revisit: if unrelated-edit review volume outgrows what two coordinators can clear before the Friday CSV, and the team will maintain and verify species/observer merge rules, the tradeoff flips.
- **What tablet and export must accommodate** — spelled out under Selection as explicit downstream obligations: tablet-sync retains base revision IDs, submits whole visits, and surfaces the returned review state (so a worker sees an edit became a competing revision); review-export builds the revision-comparison screen, a resolve action naming the full open set, and holds unresolved visits out of the export. Storage is sized to snapshots + base revision IDs, not base snapshots.

Two things still open before Phase 3:

1. Do you approve the LLD and its resolution model as written, so I can draft the EARS updates?
2. Triage the three deferred items in Open Questions & Future Decisions (retention horizon, history pagination, distinct error code for the simultaneous no-base race) — fold any into the LLD now, or leave deferred?