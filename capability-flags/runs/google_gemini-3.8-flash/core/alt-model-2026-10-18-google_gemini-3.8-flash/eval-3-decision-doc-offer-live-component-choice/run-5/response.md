I have completed the record-store Low-Level Design incorporating the whole-visit revisions model in `docs/intent/record-store/record-store-design.md` and updated `docs/high-level-design.md`.

### Phase 2 Summary: Record Store LLD
- **Concurrency Model**: Revisions form an explicit tree rooted at creation (`base_revision_id: null`). Linear updates (`base == head`) advance the head cleanly (`ready`). Competing edits based on the same or older revisions branch into whole-visit candidate heads without automated merging (`in_review`).
- **Ingestion & Idempotency**: Authenticated worker submission envelope with client UUID `idempotency_key`. Exact re-submissions return original acceptance without duplicate branches; conflicting payloads with identical keys fail loud (`409 Conflict`).
- **Lifecycle & State Model**: `ready` (single head, eligible for export), `in_review` (competing heads, held out of export), and `resolved` (coordinator resolution recorded, eligible for export).
- **Store Operations**: Endpoints for submission ingestion, current-state retrieval (surfacing `unresolved_review` and competing revisions), complete revision history retrieval, and coordinator resolution.
- **Downstream Contracts**: Explicit contracts for `tablet-sync` (tracking base revision IDs and reflecting review status) and `review-export` (side-by-side whole-visit comparison and filtering export queries to `ready` and `resolved` visits).
- **Decisions & Alternatives**: Recorded the concurrency model selection, idempotency strategy, and export exclusion criteria with rationale.

---

### Questions for User Ruling

#### 1. Decision Doc Offer
Because the whole-visit revisions vs. field-aware merge choice is an architectural decision that trades criteria across multiple downstream nodes (`tablet-sync`, `review-export`), would you like to:
- **Record a standalone decision doc** (`docs/intent/record-store/decisions/concurrency-model.md`) detailing the full criteria, options analysis, and downstream implications, OR
- **Keep the Decisions & Alternatives row** in `record-store-design.md` as the sufficient record?

#### 2. LLD Edge-Case Probe (Triage)
The LLD-level edge-case probe surfaced the following questions regarding internal record-store gaps. Which of these would you like clarified directly in the LLD before we draft EARS specs, and which should be deferred as open questions?

1. **Concurrent Ingestion Isolation**: When two submissions referencing the same `base_revision_id` arrive concurrently, what isolation or locking mechanism guarantees exactly one becomes head and the other branches to `in_review` rather than both claiming a clean linear advance?
2. **Late Ancestor Submissions on Resolved Visits**: If a late-arriving offline submission points to an older ancestor or unselected revision after a coordinator has marked the visit `resolved`, does the visit revert to `in_review`, or is the late edit rejected / branched into a new review queue?
3. **Submissions During Active Review**: If a worker submits against one of the competing heads while the visit is already `in_review`, does that branch advance linearly under the active review state, or does it trigger a distinct handling state?
4. **Out-of-Order Chained Offline Edits**: If a tablet submits chained edits ($R_0 \to R_1 \to R_2$) and network jitter causes $R_2$ (`base: R_1`) to arrive before $R_1$, does the server reject $R_2$ immediately (`422`), or buffer pending parent arrival?
5. **Coordinator Resolution Race**: If two coordinators resolve the same visit concurrently, does `POST /resolutions` enforce optimistic locking (e.g. requiring the exact set of active competing revision IDs being closed)?
6. **Plot ID Immutability**: Can a subsequent revision mutate `plot_id` (e.g., correcting an erroneously selected plot code in the field), or is `plot_id` an immutable invariant for the life of `visit_id`?