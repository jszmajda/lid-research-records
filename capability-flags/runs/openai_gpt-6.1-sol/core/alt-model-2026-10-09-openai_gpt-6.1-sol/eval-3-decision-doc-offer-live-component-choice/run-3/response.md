Updated `docs/intent/record-store/record-store-design.md` with the whole-visit revision design and your rationale: preserving scientifically related edits outweighs reducing review volume.

This is the **LLD review stop**. The draft contract is below; the edge-case probe found several choices that need your judgment before it can be finalized.

## Record-store design

### Submission and persistence

Each authenticated submission contains:

| Field | Meaning |
|---|---|
| `visitId` | Client-generated UUID identifying the visit |
| `idempotencyKey` | Stable identity for retries of this submission |
| `baseRevisionId` | Revision the worker edited; null for an initial submission |
| `payload` | Complete visit: plot ID, observation date, observers, species cover estimates, and notes |

The server assigns a revision ID and retains the immutable original envelope, authenticated author ID, and receipt time. The submitting author is distinct from the visit’s observer list.

Fresh submissions validate field types, plot references, and base-revision membership. A non-null base must belong to the same visit. Invalid requests create no revision. Archived plot references remain resolvable through the catalog.

After authentication and key-ownership checks, accepted retries are checked before fresh-submission validation:

- Identical envelope content returns the original acceptance result without another revision.
- Different content under an accepted key is rejected.
- Comparison uses parsed values, ignoring JSON whitespace and object-key order.
- Key ownership across workers remains an open question.

### Visit state and acceptance

Each visit has a last-established current revision, an unresolved-review flag, and a changing state version. The state version detects changes to review work even when the current revision stays the same.

Storing a revision, changing visit state, and recording its retry result happen atomically. Concurrent operations on a visit serialize their state checks.

| Starting state and submission | Result |
|---|---|
| Visit absent; base null | Establish the initial revision as current |
| Visit resolved; base equals current | Establish the complete submitted revision as current |
| Visit resolved; base is any stored non-current revision | Retain the competing revision and open review |
| Review already open; base belongs to this visit | Retain the additional revision and keep review open |

The server never automatically combines fields. Arrival of a competing revision makes the visit unresolved; the last-established current revision then serves as a comparison reference, not an exportable winner.

Acceptance returns the visit ID, revision ID, resulting state, and state version. A retry returns its original result, even if the visit has since changed; callers retrieve live state separately.

### Retrieval and review work

Current-state retrieval returns the state version, review flag, last-established current revision ID, and complete payload.

History retrieval exposes immutable revisions with their bases, authors, receipt times, and resolution outcomes. Each retrieval response represents one consistent snapshot; separate calls may observe different versions.

Unresolved-work retrieval supplies complete competing revisions, their provenance, the comparison revision, and the state version.

Unresolved visits are ineligible for CSV export. Resolving concurrency does not itself imply scientific approval; review-export will own any additional approval rules.

### Resolution

A coordinator submits a decision against an expected state version and an explicit set of submissions considered.

The store retains:

- Coordinator identity and resolution time.
- Contributing submission IDs.
- The complete outcome.
- All original submissions, including those not selected.

Resolution and its state change are atomic. A state-version mismatch rejects the operation without clearing review, protecting against another coordinator’s decision or a newly arrived submission.

A completed resolution establishes one complete current revision and advances the state version. Later competing submissions can reopen review.

The allowable outcomes, candidate coverage, and resolution retry contract still need decisions below.

### Decisions recorded

| Decision | Rationale |
|---|---|
| Whole-visit revisions rather than field-aware merging | Preserve scientific relationships the server cannot infer; accept a larger review queue and avoid maintained merge rules |
| Immutable submissions with separate resolution outcomes | Keep the path from submission to current value inspectable |
| State-version checks for resolution | Detect new review work even when the current revision ID has not changed |

### Downstream obligations

Tablet-sync will retain base revision IDs, send complete payloads with stable retry keys, and distinguish historical retry results from live visit state.

Review-export will compare whole revisions and provenance, submit version-checked decisions, and exclude unresolved visits from CSV export.

## Questions from the edge-case probe

Please indicate which to settle now and which to defer:

1. **Resolution outcomes:** must coordinators select an existing whole revision, or may they author a new complete revision? Selection preserves one worker’s intact visit but may require another correction submission. An authored outcome supports explicit scientific reconciliation and needs additional validation and provenance.
2. **Duplicate creation:** when an existing visit ID arrives with a null base, retain it as a competitor or reject it for tablet-side recovery?
3. **Retry ownership:** are submission keys worker-scoped or global across workers/tablets? Resolution requests also need their own retry identity and replay rule.
4. **Review candidates:** show every revision accepted during review, or only branch tips while retaining predecessors in history?
5. **Validation:** precise field constraints and error codes remain to be specified.
6. **Resolution coverage:** must a decision acknowledge the entire live review set, or can coordinators resolve part while the visit remains unresolved? Resolution preconditions also need to cover absent/resolved visits, invalid submission IDs, and outcomes outside the considered set.

The probe also exposed ambiguous non-current bases, retry-validation ordering, and retrieval consistency; the draft now makes those explicit. Existing REC specs remain compatible but do not yet cover the expanded contract. `git diff --check` passed.

Two documentation decisions accompany this review:

- **Decision record:** this tradeoff will shape both future designs and could reasonably be revisited. Would you like a standalone decision document, or is the recorded Decisions & Alternatives row sufficient?
- **Consistency cascade:** the HLD and one site-catalog sentence still describe the choice as pending. May I update those references to the selected record-store contract?

**Do you approve the draft’s settled portions, and how would you like to resolve or defer the numbered gaps?**