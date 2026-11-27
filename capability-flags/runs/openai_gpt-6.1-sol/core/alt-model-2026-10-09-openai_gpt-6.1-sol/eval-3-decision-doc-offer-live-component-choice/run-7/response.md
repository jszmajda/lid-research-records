Updated `docs/intent/record-store/record-store-design.md` with the **whole-visit revisions** design. The choice and your rationale are recorded in its Decisions & Alternatives table.

This is the **LLD review stop**. The draft establishes the revision contract; coordinator resolution still needs your judgment before it is implementation-ready.

<details>
<summary>Full record-store design draft</summary>

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting revision was fetched. Arrival order does not establish scientific authority.

Each submission is a complete, immutable whole-visit revision. Edits to an observer name, species identification, cover estimate, or notes remain together as the worker submitted them. Competing revisions go to coordinator review, including revisions that edit unrelated fields. Scientific relationships between fields make preservation of the submitted unit more important than reducing review volume.

Tablet-sync and review-export consume this node's contracts. Their local storage, user interfaces, transport scheduling, and CSV production belong to their own designs.

## Architecture and Stored State

The record store exposes authenticated submission, visit retrieval, history retrieval, and coordinator resolution operations. A per-visit transaction serializes changes to its review state and revision references. Acceptance, revision persistence, idempotency result persistence, and review-state changes commit together; an interrupted operation cannot leave a partially accepted edit. A transactional uniqueness constraint on author ID and idempotency key also coordinates simultaneous uses of a key across different visits.

| Stored item | Meaning |
|---|---|
| Visit ID | Stable client-generated UUID identifying one visit, independent of plot and observation date |
| Revision ID | Server-generated immutable identifier of one complete visit payload |
| Base revision ID | Revision of this visit from which the submitted edit was made; null for initial creation |
| Submission ID | Server-generated identifier of an accepted submission, linking its envelope, original payload, authenticated author, and server receipt time |
| Current revision ID | Usable whole-visit revision when the visit has no unresolved competition |
| Review version | Opaque token changing whenever the visit's unresolved work changes, used to reject outdated resolutions |
| Resolution history | Coordinator identity, server resolution time, reviewed submission IDs, and resulting revision ID |

The full payload includes the plot UUID, observation date, observer list, species cover estimates, and notes. Authenticated author identity is separate from the scientific observer list. Original submission envelopes and payloads remain retrievable after subsequent edits or resolutions. History links revisions to submissions and resolutions so a reader can reconstruct the source of any current value.

The catalog supplies stable plot references, including archived plots for historical lookup. Payload validation checks field types and resolvable plot IDs; it does not infer scientific intent. Detailed field constraints are an open design question below.

## Submission Contract

The logical submission operation receives:

| Field | Meaning |
|---|---|
| `visitId` | Visit UUID |
| `idempotencyKey` | Stable key for this submission attempt and its retries |
| `baseRevisionId` | Known revision belonging to this visit, or null for creation |
| `payload` | Complete visit snapshot, not a field patch |

The server derives author identity from authentication and receipt time from its own clock. Client clocks do not determine precedence.

For this draft, idempotency keys are scoped to the authenticated author across visits. Equality compares the submitted visit ID, base revision ID, and structured payload, ignoring object-member order but preserving array order. An identical retry returns the original acceptance response, even if the visit has subsequently changed; fresh visit retrieval provides its present state. Reuse with a different envelope returns `idempotency_mismatch` without mutation.

An acceptance response contains `submissionId`, `revisionId`, `receivedAt`, and the visit's state at acceptance. Acceptance means durable preservation, including when review is required; it does not mean that the revision is ready for export.

Invalid authentication or payloads are rejected before acceptance. An unknown base or a base belonging to another visit returns `invalid_base_revision`; the client retains its local work and obtains the missing server state rather than treating rejection as acceptance. A recognized historical base is valid even when it is no longer current.

## Revision and Review State Transitions

Two states describe concurrency: `current` and `unresolved`. The latter holds competing whole revisions and blocks export eligibility. Concurrency readiness is distinct from any scientific approval the review/export workflow may require.

| Existing state and submission | Result |
|---|---|
| Visit does not exist; base is null | Store the revision and make it current |
| Visit does not exist; base is non-null | Reject as an invalid base |
| Visit is current; base equals current revision ID | Store the revision and advance current to it |
| Visit is current; base is a different known revision, or null | Store the revision; enter unresolved review with the formerly current revision and the incoming revision |
| Visit is unresolved; base is known or null | Store the revision and add it to unresolved review; keep the visit unresolved |

An identical-key retry is handled before these transitions. Separate submissions with distinct keys remain separate revisions even when their payloads happen to match; the store does not collapse them based on apparent scientific equivalence.

During unresolved review, the previously current revision is available as context, not as an exportable fallback. Retrieval sets `currentRevisionId` to null until resolution. The review work includes all unresolved submissions and their bases; history supplies intermediate and earlier revisions for comparison. A new edit made from a competing revision does not silently dispose of earlier review work.

Example: revision R1 is current. Worker A submits R2 based on R1, which becomes current. Worker B submits R3 based on R1, making R2 and R3 competing revisions. R1 remains their recorded base. No observer, species, cover, or notes fields are automatically combined. A later R4 submitted during this review is retained and adds to the review work.

## Retrieval Contract

Visit retrieval returns a coherent snapshot containing:

- Visit ID and state (`current` or `unresolved`).
- Current revision ID and complete payload for a current visit.
- For an unresolved visit: review version, competing revision and submission IDs, their base revision IDs, and the previously current revision ID for context.
- A concurrency-readiness indication: unresolved visits are ineligible for CSV export.

History retrieval supplies original complete payloads, base links, submission authors and receipt times, and resolution records. History remains available for submissions that a coordinator does not select. Missing visits produce `visit_not_found` rather than an empty successful visit response.

Tablet-sync can retrieve a pending submission's revision for continued local editing, but it must distinguish that revision from a usable current revision. A retrieval result does not retroactively change an earlier acceptance result.

## Coordinator Resolution Contract

Only an authenticated coordinator can resolve unresolved review. A request identifies the visit, the review version inspected, the reviewed submission IDs, and the outcome. Resolution records preserve the coordinator's identity, server resolution time, contributing submission IDs, and resulting revision ID, corresponding to REC-006.

Resolution and submission acceptance use the same per-visit serialization boundary. If the inspected review version is no longer active when resolution commits, the operation returns `review_changed` without modifying the visit's present state. Two coordinators cannot both resolve the same review version; the later attempt obtains fresh state. This prevents a newly arrived revision from being omitted by an outdated review screen and preserves a successful resolution when another coordinator retries an outdated request.

Successful resolution makes a whole revision current and closes the reviewed work without deleting its original submissions. A subsequent edit based on an older revision can reopen review. The outcome's allowed shape remains a user decision: selecting an existing whole revision only, or additionally allowing a coordinator-authored complete replacement. If replacements are supported, they need their own immutable revision and explicit provenance; automatic field merging remains outside this policy.

The resolution request's retry identity is also open below. These two decisions must be settled before the resolution operation becomes an implementation-ready contract.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent edits | Whole-visit revisions with coordinator review | Field-aware three-way merge | Preserving scientifically related edits as one submitted unit outweighs a larger review queue. Field-aware merging reduces unrelated conflicts but requires maintained rules that can miss scientific relationships. |
| Submission representation | Complete payload plus base revision ID | Base snapshots and structured field changes | Whole-visit comparison needs revision identity and intact snapshots; field patches would introduce merge semantics and additional client state. |
| Review state | Explicit unresolved state with no usable current revision | Export the formerly current revision while competition is pending | Excluding unresolved visits prevents an apparently settled CSV from concealing an outstanding competing observation. |
| Persistence boundary | Atomic per-visit acceptance and resolution | Independent writes of submission history and current state | A retry or concurrent request must not expose a state whose accepted submissions are missing or unaccounted for. |

## Downstream Obligations

- **Tablet-sync:** retain base revision IDs, complete local visit payloads, and stable submission keys across retries; distinguish durable acceptance from current status; expose unresolved server outcomes while preserving local work.
- **Review-export:** compare complete submitted revisions with their bases and provenance; submit the review version it inspected; refresh after `review_changed`; exclude unresolved visits from the CSV. Any additional scientific approval rules belong to review-export.
- **Site-catalog:** the existing stable-UUID and historical-lookup contract supplies plot validation. Its explanatory text about the concurrency choice needs reconciliation with this design.
- **HLD:** responsibility remains with record-store. The architecture's open-choice wording needs reconciliation with this design.

These obligations are recorded here for the sibling designs to consume. Their implementation details require their own design reviews.

## Open Questions & Future Decisions

1. **Resolution authority:** may a coordinator only select an existing whole revision, or also author a complete replacement using the reviewed submissions as evidence? The latter can retain corrections from both submissions under explicit human judgment but needs editing, validation, and replacement provenance.
2. **Resolution retries:** use a coordinator-scoped idempotency key with a durable original outcome, as for submissions, or require fresh retrieval after an uncertain resolution result? Keys ease retries after connection loss but add a second durable request-result contract.
3. **Scientific payload validation:** confirm date constraints, species-entry identity, allowed cover ranges, duplicate species handling, and observer-list constraints. Structural validation must not silently rewrite submitted scientific values.
4. **Reviewed-set validation:** must the resolution's reviewed submission IDs exactly match the active review work, and what error identifies missing, unrelated, or duplicate IDs?
5. **Retry validation ordering:** does accepted-key replay precede fresh payload validation, and which error wins when a reused key has both a changed envelope and an invalid base?
6. **Resolution errors:** specify outcomes for a missing visit, a visit without active review, and an authenticated caller without coordinator authority.

## References

- [High-level design](docs/high-level-design.md)
- [Record-store EARS](docs/intent/record-store/record-store-specs.md)
- [Site-catalog design](docs/intent/site-catalog/site-catalog-design.md)

</details>

### Review findings and decisions needed

The independent gap probe found two issues addressed in the draft: author-wide retry keys need cross-visit uniqueness, and an outdated coordinator request must preserve an already-resolved visit. The six remaining questions are listed above for your triage.

Please reply with numbered feedback, especially:

1. **Resolution authority:** selection of an existing revision only, or also a coordinator-authored complete replacement?
2. **Resolution retries:** durable idempotency keys, or retrieval after an uncertain result?
3. **Remaining gaps:** which of questions 3–6 should we settle now, and which should remain explicitly deferred?

Two scope/recording checks also need your approval:

4. May I reconcile the HLD and site-catalog’s stale “choice pending” wording? Those edits cross this segment’s boundary.
5. This tradeoff could be revisited by someone trying to reduce the review queue. Would you like a standalone decision document in record-store’s `decisions/` directory, or keep the rationale in the existing table?

`git diff --check` passed. Approve or revise this LLD before I cascade it into the EARS specs.