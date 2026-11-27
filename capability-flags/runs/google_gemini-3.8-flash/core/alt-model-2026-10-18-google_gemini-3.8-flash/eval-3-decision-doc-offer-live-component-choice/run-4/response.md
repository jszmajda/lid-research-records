I have completed Phase 2 for `record-store`, updating the Low-Level Design to specify the **Whole-Visit Revisions** concurrency model.

The updated design document has been written to `docs/intent/record-store/record-store-design.md`.

---

### Record Store Low-Level Design (`docs/intent/record-store/record-store-design.md`)

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

The record store manages visit persistence and establishes the authoritative visit state when multiple field workers submit independent edits. In TidePlot, 24 field workers use 12 shared Android tablets across 320 permanent coastal vegetation plots. Tablets may operate offline for up to 48 hours. Field workers frequently compare paper field notes and independently submit corrections for the same plot visit.

The design adheres to three core tenets:
1. **Never silently discard a submitted edit**: every accepted submission is preserved immutably with full author and arrival provenance.
2. **Preserve whole-visit scientific integrity**: field observations consist of interrelated data (observation dates, observer rosters, species determinations, and percentage cover estimates). The system treats a visit as a cohesive scientific observation rather than a bag of disjoint fields, avoiding automated merges that could pair incompatible revisions.
3. **Explicit review before export**: concurrent edits produce competing revisions that require coordinator resolution. Unresolved records are quarantined from the downstream scientific export.

## Architecture

The record store provides four main capabilities:
- **Authenticated Submission**: Ingests complete visit records with idempotency and base revision tracking.
- **Current-State Retrieval**: Serves the current authoritative revision or flags the visit as requiring coordinator review.
- **Submission History**: Provides full audit trails of original submissions, author identities, and server receipt timestamps.
- **Coordinator Resolution**: Enables coordinators to resolve competing revisions into a single authoritative head revision.

```
       +-----------------------+
       |   Field Tablet Sync   |
       +-----------------------+
                   |
                   | POST /submissions (Envelope with base_revision_id)
                   v
       +----------------------------------------------------+
       |                   Record Store                     |
       |                                                    |
       |  +--------------------+    +--------------------+  |
       |  | Stored Submissions |    |   Revision Tree    |  |
       |  | (Immutable audit)  |    | (Branch & Resolve) |  |
       |  +--------------------+    +--------------------+  |
       +----------------------------------------------------+
              |                                  ^
              | GET /visits/{id}                 | POST /visits/{id}/resolve
              v                                  |
       +----------------------------------------------------+
       |              Review & Export Service               |
       |  - Compares competing whole-visit revisions        |
       |  - Resolves conflicts                              |
       |  - Generates Friday CSV (clean records only)       |
       +----------------------------------------------------+
```

## Data Model & Submission Envelope

### Visit Identification and Scientific Payload

A visit represents a single survey event on a permanent plot. It is identified by a client-generated UUID (`visit_id`) and references a stable catalog plot UUID (`plot_id`).

The scientific payload contains:
- `plot_id`: UUID referencing the site catalog
- `observation_date`: ISO 8601 calendar date (`YYYY-MM-DD`)
- `observers`: Ordered list of observer names or identifier strings
- `species_records`: List of records, each containing `species_id` or botanical taxon code, and `cover_percent` (numeric estimate)
- `notes`: Free-text field observations and plot condition notes

### Submission Envelope

Every submission sent from a tablet uses the following envelope:

```json
{
  "submission_id": "c7a1024e-4f3b-4835-a1c1-424b94c39832",
  "visit_id": "8f8b39a2-9721-4f11-9a72-748a3d420001",
  "base_revision_id": "a1b2c3d4-0000-0000-0000-000000000001",
  "idempotency_key": "9c12e847-b715-46aa-a3ef-b209d846c820",
  "payload": {
    "plot_id": "plot-uuid-032",
    "observation_date": "2026-10-18",
    "observers": ["J. Miller", "S. Vance"],
    "species_records": [
      { "species_id": "SP-DIST-01", "cover_percent": 35.0 },
      { "species_id": "SP-SALIC-02", "cover_percent": 12.5 }
    ],
    "notes": "Transect line submerged at high tide mark."
  }
}
```

- `submission_id`: Client-generated UUID uniquely identifying this transmission attempt.
- `visit_id`: Client-generated UUID identifying the surveyed visit.
- `base_revision_id`: UUID of the server revision that this edit was based on. For the initial creation of a visit, `base_revision_id` is `null`.
- `idempotency_key`: Client-generated token to guarantee safe network retries.
- `payload`: The complete whole-visit scientific data.

### Ingestion Response

`POST /submissions` returns HTTP 201 Created on acceptance:

```json
{
  "submission_id": "c7a1024e-4f3b-4835-a1c1-424b94c39832",
  "visit_id": "8f8b39a2-9721-4f11-9a72-748a3d420001",
  "revision_id": "b1111111-0000-0000-0000-000000000001",
  "visit_status": "clean",
  "received_at": "2026-10-18T14:22:00Z"
}
```

If the submission branched the visit into competing revisions, `visit_status` is returned as `"in_review"`.

### Storage Representation

1. **Submissions Log (Immutable Audit)**:
   - `submission_id`: UUID (Primary Key)
   - `visit_id`: UUID
   - `base_revision_id`: UUID (nullable)
   - `author_id`: Authenticated worker ID
   - `idempotency_key`: String
   - `received_at`: Server timestamp (UTC)
   - `raw_payload`: Complete JSON payload as received

2. **Revisions (Version Tree / DAG)**:
   - `revision_id`: UUID (Primary Key)
   - `visit_id`: UUID
   - `parent_revision_ids`: Array of UUIDs (empty for initial root revisions; multiple parents when created by coordinator resolution)
   - `submission_id`: UUID (references Submissions Log; nullable if created by coordinator resolution)
   - `is_head`: Boolean flag indicating if this revision is a current leaf
   - `scientific_data`: Normalized scientific fields
   - `created_at`: Server timestamp (UTC)

3. **Resolution Log**:
   - `resolution_id`: UUID (Primary Key)
   - `visit_id`: UUID
   - `resulting_revision_id`: UUID (references Revisions)
   - `coordinator_id`: Authenticated coordinator ID
   - `resolved_head_revision_ids`: Array of UUIDs representing the competing heads resolved
   - `contributing_submission_ids`: Array of UUIDs representing the original submissions reviewed
   - `resolution_notes`: Free-text explanation of the reconciliation
   - `resolved_at`: Server timestamp (UTC)

## Concurrency & Revision Management

The record store implements **Whole-Visit Revisions**:
- Edits submit complete visit snapshots, not field deltas.
- Concurrency conflicts are detected by evaluating `base_revision_id` against the current head revision(s) of the visit.
- Disjoint field edits arriving concurrently are not automatically merged. All concurrent branches branch into competing head revisions.

### Revision Transitions

```
Case 1: Clean Linear Progression
(Initial creation)
R0 (base: null) -> [Head: R0, Status: clean]

(Sequential edit)
R0 -> R1 (base: R0) -> [Head: R1, Status: clean]

Case 2: Competing Revisions (Conflict)
R0 -> R1a (base: R0) [arrived first; Head: R1a]
   \
    -> R1b (base: R0) [arrived concurrently; Heads: {R1a, R1b}, Status: in_review]

Case 3: Coordinator Resolution
R0 -> R1a \
   \       -> R2_resolved (Head: R2_resolved, Status: clean)
    -> R1b /
```

1. **Initial Creation (`base_revision_id == null`)**:
   - If no revisions exist for `visit_id`, a root revision `R0` is created. Status is `clean`.
   - If one or more revisions already exist for `visit_id`, a second submission claiming `base_revision_id == null` represents a concurrent independent creation. It is accepted, stored, and attached as a competing root revision. The visit status transitions to `in_review`.

2. **Sequential Update (`base_revision_id == current_head`)**:
   - When the visit is in `clean` status and `base_revision_id` matches the single head revision, the submission cleanly advances the revision tree.
   - The prior head has `is_head` set to `false`, the new revision becomes the sole `is_head = true`, and status remains `clean`.

3. **Concurrent / Branching Edit (`base_revision_id != current_head`)**:
   - If `base_revision_id` points to an ancestor revision that is no longer the sole head (or if the visit already has multiple heads in `in_review` status), a branch is formed.
   - The submission is accepted, stored immutably in the submissions log, and instantiated as a new competing leaf revision (`is_head = true`).
   - The visit status becomes `in_review`.
   - No automatic merging of fields is attempted.

4. **Idempotent Resubmissions**:
   - Re-submitting with an existing `idempotency_key` and identical payload returns the prior acceptance response and revision ID without duplicating records.
   - Re-submitting with an existing `idempotency_key` but a altered payload is rejected with HTTP 409 Conflict, preserving the existing record intact.

## State Retrieval & Unresolved Work

Callers retrieving visit state receive unambiguous metadata detailing whether the visit is immediately usable or requires coordinator review.

### GET /visits/{visit_id}

Returns the current state representation:

```json
{
  "visit_id": "8f8b39a2-9721-4f11-9a72-748a3d420001",
  "status": "in_review",
  "head_revisions": [
    {
      "revision_id": "b1111111-0000-0000-0000-000000000001",
      "submission_id": "sub-101",
      "author_id": "worker-14",
      "received_at": "2026-10-18T14:22:00Z",
      "base_revision_id": "a1b2c3d4-0000-0000-0000-000000000001",
      "payload": {
        "plot_id": "plot-uuid-032",
        "observation_date": "2026-10-18",
        "observers": ["J. Miller", "S. Vance"],
        "species_records": [
          { "species_id": "SP-DIST-01", "cover_percent": 35.0 },
          { "species_id": "SP-SALIC-02", "cover_percent": 12.5 }
        ],
        "notes": "Transect line submerged at high tide mark."
      }
    },
    {
      "revision_id": "b2222222-0000-0000-0000-000000000002",
      "submission_id": "sub-102",
      "author_id": "worker-09",
      "received_at": "2026-10-18T15:05:30Z",
      "base_revision_id": "a1b2c3d4-0000-0000-0000-000000000001",
      "payload": {
        "plot_id": "plot-uuid-032",
        "observation_date": "2026-10-18",
        "observers": ["J. Miller", "S. Vance", "A. Gomez"],
        "species_records": [
          { "species_id": "SP-DIST-01", "cover_percent": 40.0 },
          { "species_id": "SP-SALIC-02", "cover_percent": 12.5 }
        ],
        "notes": "Added Gomez to observers. High tide line observed."
      }
    }
  ]
}
```

- When `status == "clean"`: `head_revisions` contains exactly one revision. Its scientific payload represents the authoritative current state.
- When `status == "in_review"`: `head_revisions` contains two or more competing revisions. Callers are informed that unresolved coordinator review work exists.

### GET /visits/{visit_id}/history

Returns the complete chronological audit trail of all submissions received and resolutions enacted for the visit:

```json
{
  "visit_id": "8f8b39a2-9721-4f11-9a72-748a3d420001",
  "submissions": [
    {
      "submission_id": "sub-100",
      "author_id": "worker-14",
      "base_revision_id": null,
      "received_at": "2026-10-18T10:00:00Z"
    },
    {
      "submission_id": "sub-101",
      "author_id": "worker-14",
      "base_revision_id": "a1b2c3d4-0000-0000-0000-000000000001",
      "received_at": "2026-10-18T14:22:00Z"
    },
    {
      "submission_id": "sub-102",
      "author_id": "worker-09",
      "base_revision_id": "a1b2c3d4-0000-0000-0000-000000000001",
      "received_at": "2026-10-18T15:05:30Z"
    }
  ],
  "resolutions": []
}
```

### GET /reviews

Returns an enumerated list of all visits currently in `in_review` status, with their competing revision counts, involved observer/author IDs, and timestamps, allowing coordinators to prioritize reviews prior to export deadlines.

## Coordinator Resolution Workflow

When a visit is in `in_review` status, two regional coordinators have authority to review competing revisions and record a resolution.

### POST /visits/{visit_id}/resolve

Request envelope:

```json
{
  "coordinator_id": "coord-01",
  "resolved_head_revision_ids": [
    "b1111111-0000-0000-0000-000000000001",
    "b2222222-0000-0000-0000-000000000002"
  ],
  "contributing_submission_ids": [
    "sub-101",
    "sub-102"
  ],
  "chosen_base_revision_id": "b2222222-0000-0000-0000-000000000002",
  "resolution_notes": "Confirmed with Vance that Gomez was present. Adopted cover estimate of 40% per field notebook.",
  "resolved_payload": {
    "plot_id": "plot-uuid-032",
    "observation_date": "2026-10-18",
    "observers": ["J. Miller", "S. Vance", "A. Gomez"],
    "species_records": [
      { "species_id": "SP-DIST-01", "cover_percent": 40.0 },
      { "species_id": "SP-SALIC-02", "cover_percent": 12.5 }
    ],
    "notes": "Added Gomez to observers. High tide line observed."
  }
}
```

Resolution mechanics:
1. Validates that all currently competing head revisions match `resolved_head_revision_ids`.
2. Creates a new revision `R_resolved` containing `resolved_payload`, with `parent_revision_ids` set to `resolved_head_revision_ids`.
3. Marks all previous competing heads as `is_head = false`.
4. Marks `R_resolved` as the single new head (`is_head = true`).
5. Appends an entry to the Resolution Log capturing the coordinator ID, timestamps, resolved head revision IDs, contributing submission IDs, and notes.
6. Transitions visit status back to `clean`.

## Downstream Contracts

### Tablet-Sync Contract

1. **Base Revision Tracking**: Tablets must store `revision_id` alongside cached visit data. When a field worker edits an existing visit, the tablet includes that `revision_id` as `base_revision_id` in the submission envelope.
2. **Offline Draft Handling**: Local draft updates queue locally. On reconnect, the tablet submits the full visit payload with its stored `base_revision_id` and unique `idempotency_key`.
3. **Competing State Reflection**: When syncing, if the server reports `status: "in_review"`, the tablet marks the local visit record as "Pending Coordinator Review" rather than attempting local automatic merging or overwriting server data.

### Review-Export Contract

1. **Review Queue**: The review interface consumes `GET /reviews` and `GET /visits/{id}` to present side-by-side whole-visit diffs between competing revisions, showing author IDs, receipt timestamps, and field-level discrepancies.
2. **Resolution Submission**: The coordinator UI submits reconciled data via `POST /visits/{id}/resolve`.
3. **Export Eligibility (Friday CSV)**: The export pipeline queries visits for export. Any visit with `status == "in_review"` is strictly quarantined and excluded from the generated CSV export. Only visits with `status == "clean"` are included in the regional scientific partner's export.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrency policy for independent visit edits | Whole-visit revisions | Field-aware three-way merge | Whole-visit revisions preserve each field worker's observation as an intact, coherent unit. Botanical observations have coupled dependencies (e.g. re-identifying a species alters valid cover percentage estimates) that automated field merges cannot safely understand. Whole-visit revisions eliminate the risk of silent scientific corruption, trading automated field merging for a larger coordinator review queue that two coordinators can explicitly manage. |
| Idempotency validation mechanism | Client-provided UUID key with payload verification | Server-generated payload hashing; deduplication by (visit_id, author_id, timestamp) | Flaky cellular connections cause client retries. A client-generated UUID provides unambiguous intent. Validating that a repeated key matches the original payload prevents accidental or malicious reuse while guaranteeing exactly-once ingestion. |
| Export eligibility for conflicted records | Quarantine unresolved visits (`status: in_review`) from CSV export | Export last-arrived revision with warning flag; export common ancestor base revision | The regional partner requires verified scientific data without post-export spreadsheet cleanup. Including unreviewed concurrent revisions risks publishing inaccurate data; holding conflicted records ensures export integrity. |

## Open Questions & Future Decisions

### Resolved
1. **Concurrency policy**: Selected whole-visit revisions over field-aware 3-way merge to ensure scientific integrity and eliminate automated merge logic errors.
2. **Resolution mechanism**: Manual coordinator resolution creating a successor head revision and logging contributing submission IDs.
3. **Export quarantine**: Conflicted visits remain excluded from partner CSV exports until resolved.

### Deferred
1. **Coordinator resolution tooling**: Whether the review UI allows coordinators to selectively copy specific fields from competing revisions into the resolution form (owned by `review-export`).
2. **Archival & retention**: Duration of raw submission payload retention after season closing (to be evaluated based on storage growth).

## References

- `docs/high-level-design.md` - TidePlot system goals, tenets, and architecture.
- `docs/intent/site-catalog/site-catalog-design.md` - Plot catalog references and UUID stability.
```

---

### Decision Doc Option

The concurrency policy is a foundational decision traded across data integrity, merge complexity, and review workload, sizing both `tablet-sync` and `review-export`. 
- Would you like this recorded as a dedicated standalone decision doc (`docs/intent/record-store/decisions/concurrency-policy.md`)?
- Or should it remain as the row in the `## Decisions & Alternatives` table of `record-store-design.md`?

---

### LLD Edge-Case Probe Findings

An independent probe ran against the updated LLD. Please triage which of these gaps should be addressed directly in the LLD now versus deferred to implementation or future design nodes:

1. **Concurrent In-Flight Submissions During Resolution**: What happens if a field tablet submits an edit branching from a head while a coordinator is in the middle of executing `POST /visits/{id}/resolve`? (e.g., optimistic lock / revision tag required on resolve).
2. **Simultaneous Submissions with Same Base**: What specific transaction isolation or row locking guarantees atomic head transitions when two workers submit edits against the same `base_revision_id` concurrently?
3. **Late-Arriving Sync on Already-Resolved Visits**: If Tablet C comes online after 48 hours and submits an edit based on an ancestor revision that was already resolved into a clean state, does it immediately throw the clean visit back into `in_review`?
4. **Validation of `base_revision_id`**: What happens if a submission provides a non-existent UUID or a `base_revision_id` belonging to a different `visit_id`?
5. **Plot ID and Observation Date Mutability**: Is `plot_id` immutable across the lifetime of a `visit_id`, or can a revision change the plot reference?
6. **Idempotency Key Scope**: Is the idempotency key unique per worker/visit or globally unique across the whole system?

---

How would you like to resolve the edge-case gaps above, and do you approve this LLD to proceed to Phase 3 (EARS specs update)?