LLD written. Now the edge-case probe findings to include in the stop:

**Edge-case probe** (LLD-level gaps):

1. **Concurrent first submissions**: Two workers both submit with `base_revision_id = null` for the same `visit_id`. The first accepted creates the visit clean (condition 1). The second arrives; the visit now has a current revision, so `null ≠ current_revision_id` → condition 3 → unresolved. Handled correctly by the processing rules. No gap.

2. **base_revision_id points to a rejected (post-resolution) revision**: After resolution, a worker submits based on one of the rejected competing revisions. That rejected revision belongs to the visit, so the existence check passes. Its revision_id ≠ current (the coordinator-selected revision) → condition 3 → unresolved again. Coordinator must resolve a second time. This creates a potential recurring cycle; by design, not a gap, but coordinators may encounter it operationally. Noted in Open Questions.

3. **What payload does an unresolved visit return on GET?**: Initially unspecified. Resolved: the last-clean revision's payload, with `visit_state = unresolved`. The competing payloads are in the revision-history endpoint. Added to the LLD and to the Decisions table.

4. **Race between two writes to a clean visit**: Both pass condition 2's read; one commits first, the second finds current has changed → condition 3 → unresolved. The atomicity requirement in the LLD ensures exactly this outcome. No gap, but the atomicity constraint must travel to the implementation.

---

Here is the updated LLD in full for your review:

---

**`docs/intent/record-store/record-store-design.md`**

---
parent: high-level-design  
prefix: REC  
---

**# Record Store**

**## Context and Design Philosophy**

This node owns visit persistence and the rule for determining a visit's authoritative current state when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. Arrival order is not evidence of worker authority.

Tablet-sync and review-export are not yet designed. Their contracts depend on the submission envelope and review operations defined here.

Concurrent edits are handled via **whole-visit revisions**: each submitted edit is a complete revision of the visit. Submissions derived from the same starting revision are competing; a coordinator selects one. This preserves the worker's observation as a whole and avoids maintained merge rules that could silently combine scientifically related fields. The team accepts a larger coordinator review queue in exchange.

**## Revision Model**

A **revision** is the server-side record of one accepted submission. Fields: revision_id (server-assigned UUID), visit_id, base_revision_id (submitter's declared starting point, null for first submission to a new visit), submission_id, author_id, receipt_time.

The revision history is a directed graph of base_revision_id pointers. A linear graph = clean visit. A fork (two revisions share the same base, or a new submission's base is no longer current) = unresolved visit.

**## Visit States**

| State | Condition | Export eligible |
|---|---|---|
| clean | One authoritative revision; no competing revisions outstanding | Yes |
| unresolved | Competing revisions; coordinator has not selected one | No |

Transitions: visit materializes clean on first accepted submission → clean→unresolved when a submission's base ≠ current (stale or concurrent fork) → stays unresolved while competing revisions exist → unresolved→clean when coordinator resolves.

**## Submission Envelope and Response**

Request: visit_id, base_revision_id (null only for first submission), idempotency_key, payload (plot_id, observation_date, observers, species_cover_entries, notes).

Response: submission_id, revision_id (use as next base), visit_state ("clean" | "unresolved" reflecting state at acceptance, not replayed).

**## Submission Processing**

Validation: authenticated worker; valid field types; plot_id in site catalog; base_revision_id (if non-null) belongs to the stated visit_id.

Idempotency: same key + same payload → return original response; same key + different payload → reject.

Conflict detection (atomic per visit_id):
1. No prior revisions + base = null → create first revision; **clean**
2. Visit is clean + base = current revision_id → create new current; **clean**
3. Otherwise → create revision, add to competing set; **unresolved**

**## Retrieval**

`GET /visits/{visit_id}` → current payload (last-clean revision for an unresolved visit), current revision_id, visit_state.  
`GET /visits/{visit_id}/revisions` → all revisions with full fields; competing revisions flagged.  
`GET /visits/unresolved` → visit IDs in unresolved state, for coordinator queue.

**## Resolution**

Coordinator selects one revision_id as authoritative. Server records: selected revision_id, coordinator identity, resolution timestamp, all competing submission_ids at resolution time. Visit becomes clean. Rejected revisions are kept permanently.

**## Export Eligibility**

Only clean visits are export-eligible. Export set = clean visits whose current revision's observation_date falls in the requested range.

**## Decisions & Alternatives**

| Decision | Chosen | Alternatives | Rationale |
|---|---|---|---|
| Concurrent edit model | Whole-visit revisions | Field-aware three-way merge | Avoids merge rules that could combine scientifically related fields silently; user accepted larger queue |
| Conflict signal | Declared base_revision_id | Arrival order; content diff | Arrival order is network-dependent not intent-dependent; declared base is explicit |
| Idempotency response state | State at acceptance time | Current state at replay | Preserves idempotency contract |
| Unresolved retrieval payload | Last-clean revision | Arbitrary competing revision; all competing; no payload | Stable and deterministic reference point for coordinators |
| Visit state model | Two states (clean/unresolved) | Three with distinct resolved state | Coordinator involvement captured in resolution event; third state adds no export information |
| Revision retention | All kept permanently | Delete losing revisions | HLD tenet: do not discard submitted edits |
| Conflict detection atomicity | Per-visit atomic check-and-update | Append-then-repair | Non-atomic check allows both concurrent writes to pass condition 2 silently |

**## Open Questions & Future Decisions (Deferred)**

1. Unresolved visit with many competing revisions — resolution UI pagination?
2. Coordinator-authored synthesized revisions?
3. Deadline alerting for unresolved visits at export time?

---

Does this LLD look right to you? A few things I'd specifically like your read on:

1. **Unresolved retrieval payload** — I chose "return last-clean revision's payload" for `GET /visits/{visit_id}` when a visit is unresolved. The competing payloads are accessible via the revision-history endpoint. If you'd prefer coordinators see one of the competing payloads directly in the current-state response, we should change this.

2. **Already-unresolved visit receiving another stale submission** — condition 3 applies: the new revision joins the competing set and the visit stays unresolved. A coordinator will then see all three (or more) competing revisions. Is that the right behavior, or should there be a cap or a different handling?

3. **Open questions** — any of the three deferred items worth resolving at the record-store level now rather than punting to the later design nodes?