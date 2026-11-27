# Phase 2 — Low-Level Design: Record Store

The record store design (`docs/intent/record-store/record-store-design.md`) has been updated to incorporate whole-visit revisions as the concurrency mechanism, establishing contracts for downstream nodes (`tablet-sync` and `review-export`).

### Summary of Completed Design

1. **Revision Model & States:**
   - Every visit maintains an immutable history of revisions (`revision_id`, `visit_id`, `plot_id`, `base_revision_id`, `resolved_revision_ids`, `author_id`, `server_received_at`, `payload`).
   - Visits operate in either `clean` (unambiguous current active revision) or `conflicted` (unresolved competing revisions exist) state.

2. **Submission Envelope & Ingestion (`POST /visits/{visit_id}/submissions`):**
   - Envelope requires `idempotency_key`, `plot_id`, `base_revision_id`, and structured visit payload (`observation_date`, `observers`, `species_cover`, `notes`).
   - Idempotent retries return the original result; mismatched payloads for an existing key return `409 Conflict`. Unknown `base_revision_id` returns `400 Bad Request`.
   - Linear submissions against the current head remain `clean`. Branching submissions (older base revision, competing base revision, or concurrent initial creation) transition the visit to `conflicted`.

3. **Retrieval & Export Gating (`GET /visits/{visit_id}` & `GET /visits/review-queue`):**
   - Retrieval explicitly signals whether unresolved review work exists (`state: "conflicted"`, `has_unresolved_review: true`), returning all competing revisions and their base revision.
   - Visits in `conflicted` state are withheld from partner CSV export.

4. **Coordinator Resolution (`POST /visits/{visit_id}/resolutions`):**
   - Coordinators resolve forks by choosing an existing competing revision (`select_revision`) or authoring a synthesis (`custom_revision`).
   - Resolution creates a new revision citing all resolved revision IDs, sets the coordinator as author, clears review flags, and returns the visit to `clean`. Resolving only a subset of competing revisions is rejected.

5. **Downstream Obligations:**
   - `tablet-sync`: Must track and submit `base_revision_id`, preserve local drafts when server indicates `conflicted`, and persist idempotency keys.
   - `review-export`: Must provide a side-by-side revision comparison view and enforce export exclusion for visits with open conflicts.

---

### Decision Doc Offer

Because this concurrency choice traded review queue volume against data integrity and merge complexity—and directly sizes downstream contracts in `tablet-sync` and `review-export`:

**Would you like to record this choice as a full decision doc (`docs/intent/record-store/decisions/concurrent-visit-revisions.md`), or keep it documented within the LLD's Decisions & Alternatives table?**

---

### LLD Edge-Case Probe (For Triage)

The following edge cases were identified during the internal component probe. Please indicate which you would like incorporated into the LLD vs. deferred to implementation:

1. **Submission while already in `conflicted` state:** If an edit arrives referencing one of the unreviewed competing revisions (a branch off a branch), should it append as an additional competing branch under the same visit, or be rejected until the initial conflict is settled?
2. **Payload-level invariants:** Should the record store enforce scientific constraints (e.g., rejecting duplicate `species_code` within the same stratum or total cover > 100%), or treat scientific plausibility checks as soft warnings handled in review?
3. **Resolution race condition:** If a worker's competing revision arrives while a coordinator's resolution is being processed, should it immediately re-conflict the visit or be rejected with a concurrency error prompting the tablet to fetch the resolved head?