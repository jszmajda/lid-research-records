The decision is written up, and the record-store LLD now records it. Nothing is in code yet, so there are no tests to run.

**New file: `docs/intent/record-store/decisions/whole-visit-revisions.md`**
- **Criteria:** silent combination of related edits (major), each submitted visit staying a recognizable unit (major), coordinator review workload (major), maintained merge-rule burden (moderate), and submission size (minor). Each is tied to a tenet where one applies.
- **Options:** both approaches are described in full, with a worked example and a verdict on each criterion.
- **Why whole-visit revisions:** the field-aware merge's review-volume advantage is real, but its failure is a wrong record that looks correct. The server cannot infer that a species identification and its cover estimate belong together. That failure would reach the Friday CSV unnoticed.
- **Why we'd still consider the other approach:** the decision should be revisited if coordinators can't clear the queue before Friday for a season, or if most conflicts differ only in fields with no scientific relationship. In that case the revisit would cover only those fields, not full merging.
- **What tablet-sync and review-export must accommodate:**
  - Tablet-sync stores the base revision ID for each visit. It shows a worker when their revision is pending against a competing one, and it doesn't present a visit as settled while revisions compete.
  - Review-export provides a comparison of competing revisions. It excludes visits with unresolved competitors from the Friday set and shows which visits were excluded and why. Its coordinator interface is sized to the larger queue.

**Updated: `docs/intent/record-store/record-store-design.md`**
- The OPEN section is replaced by a Concurrency Policy section that links to the decision doc.
- A Decisions & Alternatives row records the choice.
- Stale "open choice" wording in Context and Submission and Retrieval now points to the downstream contract work.
- The body is otherwise unchanged. The submission envelope, current-state response, unresolved-work representation, and resolution operation are still undefined.

**Still open**
- The tenet "Prefer workflows two coordinators can operate without a dedicated systems administrator" is in tension with the larger queue. I left the HLD tenet as written. Should it stay, or be reworded?
- Next is the record-store LLD draft, which defines the contract. It will raise any forks it finds, such as what retrieval returns for a visit with competing revisions. I'll stop there for your review before the EARS specs.