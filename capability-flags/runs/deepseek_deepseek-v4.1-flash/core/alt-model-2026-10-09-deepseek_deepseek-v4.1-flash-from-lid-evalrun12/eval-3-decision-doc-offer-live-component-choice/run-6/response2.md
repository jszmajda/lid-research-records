Wrote the decision doc and linked it from the LLD's Decisions table.

# Decision doc: `docs/intent/record-store/decisions/concurrent-edit-policy.md`

## Decision: Concurrent Visit Edits

**Context** — Workers edit the same visit independently, days apart and offline; the store must define what a visit's current record is without treating arrival order as authority. Both approaches preserve every original submission (an inherited invariant, not a criterion). The choice actually settles the submission envelope, the review volume, export eligibility, and whether the server carries field-combination rules.

**Decision Elements** (weighted):
- *Preservation of whole-visit scientific intent* (major) — turns on the tenet *Keep the path from a submitted observation to an exported value inspectable* and the non-goal of inferring scientific intent.
- *Implementation and maintenance burden* (major).
- *Review workload and export readiness* (moderate).
- *Operability by two coordinators* (moderate) — turns on the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*.
- *Submission and tablet storage size* (minor).

Latent criteria probed and set aside: time-to-release and automatic resolution of trivial edits.

**Options:**
- **Whole-visit revisions** — each edit names its base and submits a complete visit; competing revisions are resolved by a coordinator selecting a survivor. Analysis: scientific preservation strong, maintenance strong, review workload weak, operability partial, storage strong. *Preserves each visit as a unit at the cost of a larger queue.*
- **Field-aware three-way merge** — each edit supplies base state and structured changes; disjoint changes auto-combine, overlaps go to review, with maintained rules per field kind. Analysis: preservation weak (rules can cross scientific relationships), maintenance weak, review workload strong, operability partial, storage weak. *Cuts review volume at the cost of merge rules and silent-recombination risk.*

**Selection — whole-visit revisions with coordinator resolution.** Turns on the scientific-inspectability tenet: a record is always exactly a visit a worker submitted. Review workload and export readiness cut the other way and are accepted. Downstream obligations named: **tablet-sync** retains base revision IDs, submits the base with the complete visit, and surfaces pending competing revisions; **review-export** provides a revision comparison screen and holds unresolved visits out of the CSV until resolved. The field-aware approach is explicitly not ruled out by requirements — it is set aside, and reconsiderable if the review queue outgrows capacity, at the cost of reopening the merge-rule burden and silent-recombination risk.

The LLD's "Concurrent-edit policy" row now links to this doc; the doc carries `node: record-store` and no spec IDs.

---

That completes the Phase 2 design write-up, but the Phase 2 stop still needs your gap triage before I move to the EARS specs. You didn't weigh in on these yet — same ten from before:

1. Re-resolution contradiction (heads are superseded, yet a later resolution may pick a different survivor).
2. Re-opening on a late edit onto a losing/superseded branch.
3. `base_revision_id` integrity (unknown base, or base from another visit).
4. Null base on an existing visit.
5. Resolution envelope (retry/concurrency control).
6. Coordinator authorization.
7. Idempotency-key scope (per-visit vs global).
8. Error/absent-state shapes.
9. `plot_id` invariant across a visit's revisions.
10. Resolution eligibility and permitted `outcome` values.

For each, tell me **fix in the LLD now** or **keep deferred**. On that, I'll fold in the fixes and then draft the record-store EARS specs.