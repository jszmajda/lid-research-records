I have completed the record-store Low-Level Design and authored the standalone decision document.

### Changes Landed

1. **Decision Doc** (`docs/intent/record-store/decisions/concurrent-visit-edits.md`):
   - Formally records the selection of **Whole-Visit Revisions** over **Field-Aware Three-Way Merge**, weighed against project tenets (*Keep the path from a submitted observation to an exported value inspectable*, *Prefer workflows two coordinators can operate without a dedicated systems administrator*).
   - Documents the specific conditions under which field-aware merging would be reconsidered (survey volume expanding beyond coordinator clearance capacity, or empirical proof that conflicts are restricted to non-scientific metadata).
   - Details downstream contract obligations for `tablet-sync` (base revision tracking, whole-payload submission envelopes, conflict notifications) and `review-export` (side-by-side comparison UI, resolution dispatch, withholding conflicting visits from the Friday CSV).

2. **Record Store LLD** (`docs/intent/record-store/record-store-design.md`):
   - Defines the core data model (`Visit`, `Revision`, `Resolution`) and system invariants (submission immutability, deterministic idempotency, resolution traceability).
   - Establishes the lifecycle state transitions across clean linear updates, branching conflicts, subsequent submissions during active conflict, and coordinator resolution.
   - Specifies API request and response envelopes for submission, current-state retrieval, unresolved work inspection, and resolution.
   - Adds the Decisions & Alternatives table linking to the decision doc.

3. **High-Level Design** (`docs/high-level-design.md`):
   - Updated the architecture table to reflect that `record-store` design is complete and establishes the contract for `tablet-sync` and `review-export`.

---

### Phase 2 LLD-Level Edge-Case Probe

An independent edge-case probe of the completed LLD identified the following structural gaps within `record-store`:

1. **Resolution vs. In-Flight Submission Race Conditions**:
   - What happens if a worker submits a new competing revision ($Rev3'$) concurrently with a coordinator submitting `POST /resolve` for $[Rev2, Rev3]$? Does `POST /resolve` fail (e.g., HTTP 409) if its contributing revisions list is no longer exhaustive of active server branches, or does the late-arriving edit immediately re-open a conflict against the newly resolved head?

2. **Branch Graph Tracking During Multi-Edit Conflicts**:
   - If multiple chained edits arrive while a visit is in conflict (e.g., $Rev3' \to Rev3 \to Rev1$), does the server track only leaf branch tips ($[Rev2, Rev3']$) as competing revisions, or every revision in the conflict subtree? Must coordinator resolution reconcile all open branches at once?

3. **Lineage Validation & Boundary Cases**:
   - What error shape and status code is returned if a submission cites a non-existent `parent_revision_id`, a parent belonging to a different `visit_id`, or a `parent_revision_id = null` for a visit ID that already exists?
   - If an edit arrives referencing an older revision on a clean visit (e.g., current head is $Rev5$, but submission cites $Rev2$), does this fork the visit into conflict against $Rev5$ with $Rev2$ as the divergence base?

4. **Resolution Schema Invariants & Base Clearing**:
   - In `POST /resolve`, should the resulting revision's `parent_revision_id` explicitly point to the previous base revision, or should resolution revisions have a dedicated indicator?
   - Upon successful resolution, is `visit.base_revision_id` explicitly reset to `null` to avoid ambiguity in subsequent conflicts?

5. **Idempotency Scope & Resolution Retries**:
   - Is client `Idempotency-Key` uniqueness scoped per `visit_id`, per `author_id`, or globally?
   - Should `POST /api/v1/visits/{visit_id}/resolve` require an `Idempotency-Key` header to protect coordinator resolutions against network retries?

---

Please indicate which of these probe items you would like resolved in the LLD before we advance to Phase 3 (EARS specs), or if any should be recorded under Deferred Open Questions.