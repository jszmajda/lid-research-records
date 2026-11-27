The decision doc is at `docs/intent/record-store/decisions/concurrency-policy.md`. Here's a summary of what it covers:

**Context** — sets up why the mechanism matters: it determines submission metadata, the review interface, and export eligibility.

**Decision elements** — two gates (no-discard applies to both, so it doesn't select between them) and five criteria. The two marked major are *preservation of whole-visit scientific intent* and *risk of silent correctness error* — both trace to the same underlying problem (server can't infer scientific relationships from field names). Review workload and implementation burden are moderate; tablet metadata is minor.

**Options** — each option gets its strongest honest representation and a per-criterion verdict. Three-way merge scores strong on workload and partial/weak on the two major criteria. Whole-visit revisions scores strong on both majors and partial on workload (every concurrent edit creates a task, even when edits are unrelated).

**Selection** — names the two major criteria as the turning point, acknowledges the workload trade-off is real but argues the expected conflict rate is low enough that two coordinators can absorb it, and flags the maintenance burden of merge rules as a reinforcing consideration.

**Downstream obligations** — explicit section naming what this forecloses and what it requires of tablet-sync (retain revision_id across restarts, display pending-conflict state to workers) and review-export (side-by-side comparison, resolution workflow, exclusion of conflicted visits from export).

Still waiting on your review of the full Phase 1–3 output from the prior stop, and your triage of the four probe gaps (invalid base_revision_id, invalid resolution target, GET for unknown visit, resolution attempted on non-conflicted visit).