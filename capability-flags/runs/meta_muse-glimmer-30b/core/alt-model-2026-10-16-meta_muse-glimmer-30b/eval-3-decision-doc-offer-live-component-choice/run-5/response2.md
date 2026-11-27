Updated the record-store design to write up the choice properly.

`docs/intent/record-store/record-store-design.md` now includes:

**Concurrency Policy: Whole-Visit Revisions**
* Definition of `baseRevisionId`/`revisionId` competition, retention of all submissions, and that Tablet-sync tracks base IDs and Review-export holds unresolved visits out of CSV and provides a revision comparison screen.

**Why Whole-Visit Revisions Is Chosen**
The team prioritizes inspectability over review volume. Field-aware merging would reduce coordinator reviews by automatically combining disjoint field changes, but the server cannot reliably know which field relationships are scientifically coupled — e.g., species identification and its cover estimate are different fields but scientifically related. Automatic combination could silently merge an identification from one worker with a cover estimate from another. Whole-visit revisions keep each worker’s submission intact and force explicit human choice where scientific coupling may exist.

**Alternative Considered: Field-Aware Three-Way Merge**
Credible alternative for projects that can maintain merge rules and accept silent-coupling risk. Each edit supplies base state + structured change set; disjoint changes combine automatically, overlaps require review. Benefits: lower review volume, faster export readiness, field-level provenance.

Still considered because:
* Review workload is a real operational cost for two coordinators
* Merge rules are manageable for simple scalars and observer lists
* Field-level provenance could improve export explainability

Not chosen here because:
* Maintaining correct merge rules for species entries, observer lists, and notes requires ongoing domain knowledge and testing
* Automatic combination can cross scientific relationships the rules do not understand, violating *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable*
* Implementation burden shifts to Tablet-sync to retain base snapshots and send structured changes, and to Review-export to maintain field-level provenance and merge rule documentation

**Downstream Accommodations**

*Tablet-sync*
* Store `baseRevisionId` of the revision viewed and attach it to next submission
* Retain last known `revisionId` locally to detect stale-base edits
* Surface pending competing revisions to the worker, e.g., “This visit has unresolved edits from another worker since you opened it”
* Retry logic stays idempotency-key based; no structured change set required

*Review-export*
* Provide revision comparison screen showing two+ competing complete visit payloads side-by-side with author and submission time
* Export eligibility: visit is exportable only when `hasUnresolved` is false; unresolved visits held out of Friday CSV
* Resolution workflow records coordinator identity, chosen `revisionId`, contributing submission IDs, and makes resolution auditable in export lineage
* No field-level provenance or merge rule maintenance required; UI must make whole-visit diffs readable for non-technical coordinators

Submission Envelope, Current-State Retrieval, Unresolved Work Representation, and Resolution Operation sections remain as defined, with Decisions & Alternatives table recording the choice.

`docs/intent/record-store/record-store-specs.md` already reflects the whole-visit contract with REC-007 to REC-010.

Confirm this write-up captures the trade-off and downstream implications, and whether you want the edge-case probe items closed in the LLD now before moving to Phase 4 intent-narrowing edge audit.