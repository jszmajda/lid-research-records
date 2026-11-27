I've completed the record-store LLD with the whole-visit revisions approach. Here's what changed:

## Updated LLD Sections

**Replaced "Open Design Choice"** with concrete specifications:

1. **Revision-Based Concurrency** — Each submission names its base revision ID; concurrent edits create competing revisions for coordinator resolution

2. **Submission Envelope** — Defines fields: `visit_id`, `idempotency_key`, `base_revision_id`, `author_id`, `visit_data`

3. **Current-State Response** — Returns current revision, full visit data, and competing revision flags

4. **Competing Revisions Representation** — How coordinators retrieve and compare competing complete visits

5. **Resolution Operation** — How coordinators select or synthesize a visit from competing revisions, recording contributing revision IDs and coordinator identity

6. **Decisions & Alternatives** table — Records the whole-visit revisions choice with rationale: preserving worker's submitted visit as a unit, avoiding merge rules that could misinterpret scientific relationships

## Edge-Case Probe Findings

The probe identified 23 gaps within this component:

**State Transitions (5 gaps)**
1. Submission with base pointing to historical (already-superseded) revision
2. When first competing revision arrives—what becomes "current" vs "competing"
3. Submission based on a competing revision while unresolved
4. Coordinator resolution racing with another coordinator's resolution
5. Worker submission matching old current after coordinator just resolved

**Validation & Invariants (5 gaps)**
6. `base_revision_id` null for existing visit_id—competing, reject, or replace?
7. Validation failure handling—reject, store separately, or error state?
8. Validation of coordinator's `resolved_visit_data`—same rules as worker submissions?
9. Structurally valid but semantically incomplete data (empty arrays, missing dates)
10. Same idempotency key reused for different visit_id

**Error Shapes (5 gaps)**
11. Retrieving nonexistent visit_id—error, empty, or nulls?
12. Retry with same key/payload but different metadata (re-authenticated author_id)
13. Resolution citing revisions not in competing set or never submitted
14. Empty `contributing_revision_ids`—is synthesized-from-scratch allowed?
15. Authenticated identity doesn't match claimed author_id/coordinator_id

**Ordering & Concurrency (3 gaps)**
16. Simultaneous submissions with same base—both compete, or timestamp wins?
17. Submission with base_revision_id not yet received (out-of-order, clock skew)
18. Multiple coordinators submitting different resolutions simultaneously

**Boundary Conditions (5 gaps)**
19. Very large competing_revision_ids set (50+ concurrent edits)—limits before forcing resolution?
20. Size limits on visit_data, observers[], species_estimates[]
21. Idempotency returning original result—original or new metadata?
22. Retrieval during active resolution—intermediate state representation?
23. Competing revisions from different bases (revision ancestry chains)—flatten or maintain?

Which gaps should I address in the LLD now, and which should I defer as open questions?