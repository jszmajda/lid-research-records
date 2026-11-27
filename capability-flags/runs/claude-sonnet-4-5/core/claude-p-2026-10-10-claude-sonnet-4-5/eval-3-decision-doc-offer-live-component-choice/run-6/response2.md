I've completed the record-store design with the whole-visit revisions approach. Here's what's now specified:

## Updated Design Sections

**Revision-Based Concurrency** — Each submission names its base revision ID. Concurrent edits create competing revisions that a coordinator resolves. Includes full state transition diagram showing how visits progress from creation through competing revisions to resolution.

**Validation and Rejection** — All submissions (worker and coordinator) validate plot IDs, field types, and authentication. Invalid submissions are rejected without storage.

**Complete API Contracts:**
- **Submission Envelope**: visit_id, idempotency_key, base_revision_id, author_id, visit_data
- **Current-State Response**: current_revision_id, visit_data, has_competing_revisions, competing_revision_ids
- **Competing Revisions Representation**: array of complete revisions with metadata
- **Resolution Operation**: resolved_visit_data, contributing_revision_ids, coordinator_id

**Idempotency and Retry Safety** — Full specification of retry behavior, idempotency scope (per-key, not per-visit), and network failure handling.

## Downstream Implications (New Section)

**Tablet-Sync Requirements:**
- Must retain base revision IDs in local storage
- Handle three submission outcomes: accepted as current, accepted as competing, rejected
- Workers may submit successfully without becoming current—local view diverges until next sync
- Workers editing before syncing create additional competing submissions

**Review-Export Requirements:**
- Side-by-side whole-visit comparison interface
- Coordinator selects or synthesizes resolution
- Export eligibility excludes visits with `has_competing_revisions: true`
- Resolutions themselves are revisions—visit history may include multiple coordinator resolutions

## Decisions & Alternatives (Expanded Rationale)

**Concurrent edit handling:** Now explains field-aware merge's benefits (reduced coordinator workload, smaller payloads, finer provenance, automatic combination of unrelated edits) and why we still chose whole-visit revisions (preserve scientific coherence, avoid maintained merge rules that can't detect related field changes like species ID paired with cover estimate).

**Three additional decisions recorded:**
- Revision identifier scope (server-assigned vs client-generated hash)
- Export eligibility (exclude unresolved vs include current)
- Resolution provenance (record contributing IDs vs opaque)

## Open Questions (10 Deferred)

Implementation-level decisions deferred:
1. Historical base handling (competing vs reject)
2. Submission based on competing revision
3. Concurrent coordinator resolutions
4. Resolution during active transaction
5. Semantic validation boundaries
6. Size limits for data and arrays
7. Retrieval of nonexistent visit (404 vs 200)
8. Idempotent retry metadata (original vs new timestamp)
9. Competing revision ancestry (flatten vs preserve)
10. Authorization granularity (enforce vs advisory)

## HLD Updated

Architecture table now shows record-store as "Drafted" (choice made) and summarizes the revision approach for tablet-sync and review-export to size their work against.

The record-store contract is now complete enough for tablet-sync and review-export design to proceed.