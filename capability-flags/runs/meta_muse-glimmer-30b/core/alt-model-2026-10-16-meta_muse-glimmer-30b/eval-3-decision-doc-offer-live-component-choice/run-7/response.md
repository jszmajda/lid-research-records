Phase 2 LLD check complete for `record-store`.

**Coherence pre-flight**
- HLD `docs/high-level-design.md` covers the domain and notes the record-store concurrency choice is open.
- LLD `docs/intent/record-store/record-store-design.md` existed but left the concurrency policy open.
- EARS specs `docs/intent/record-store/record-store-specs.md` were generic and traceable to the prior open design. No drift detected.

**LLD updated**
`docs/intent/record-store/record-store-design.md` now finalizes whole-visit revisions:

- Context and Design Philosophy: preserves each submitted visit as an intact unit; coordinators resolve competing whole-visit revisions.
- Architecture: submission, current-state retrieval, history retrieval, review-outcome operations; original payloads never discarded.
- Submission and Retrieval
  * Submission envelope: `visitId`, `baseRevisionId`, `revisionId`, `idempotencyKey`, `authorId`, `receivedAt`, `payload` – complete visit record.
  * Current-state response: `visitId`, `resolvedRevisionId`, `resolvedRevision`, `pendingRevisions[]` with `revisionId`, `baseRevisionId`, `authorId`, `receivedAt`, `payload`. Presence of pending revisions marks the visit unresolved for export.
  * Resolution operation: coordinator selects a pending revision → becomes new resolved revision; operation records `visitId`, `chosenRevisionId`, `coordinatorId`, `resolvedAt`; coordinator identity and contributing submission IDs retained.

- Decisions & Alternatives
  * Decision: Concurrent edit policy → Chosen: Whole-visit revisions. Alternatives considered: Field-aware three-way merge. Rationale: preserves submitted visit as intact unit, avoids merge rules that could combine scientifically related edits without noticing, matches preference for larger review queue over maintaining merge rules.

- Open Questions & Future Decisions
  * Resolved: Concurrency policy selected as whole-visit revisions.
  * Deferred: auto-resolve when only one pending revision remains with base matching current resolved; retention policy for superseded pending revisions.

The LLD is context-free, alternatives are recorded in the Decisions & Alternatives table, and the contract points tablet-sync and review-export to this node.

**LLD-level edge-case probe**
- What happens when `baseRevisionId` does not exist? → needs rejection rule.
- What happens when a submission arrives with `baseRevisionId` pointing to a pending revision? → chain of pending revisions possible.
- What happens on first submission for a new visit where `baseRevisionId` is null? → first resolved revision behaviour not defined.
- What happens when coordinator resolves with no pending revisions? → no-op vs error.
- Concurrent coordinator resolutions on same visit → needs idempotency.
- Submission after resolution with base pointing to resolved revision → should create new pending revision.

These gaps are captured as deferred questions.

**EARS specs drafted for Phase 3**
`docs/intent/record-store/record-store-specs.md` now includes REC-007 to REC-010 for whole-visit revisions:
- REC-007: When a submission includes a baseRevisionId, the system SHALL store the baseRevisionId with the revision.
- REC-008: When a caller retrieves a visit, the system SHALL return the resolved revision if one exists and a list of pending revisions.
- REC-009: When a visit has one or more pending revisions, the system SHALL be considered unresolved for export.
- REC-010: When a coordinator resolves a visit by choosing a pending revision, the system SHALL set that revision as the resolved revision and record the coordinator identity and resolution time.

Post-draft consistency check: coverage of submission envelope, current-state, unresolved signalling, and resolution is present; no contradictions found; scopes are explicit.

**STOP for user review**
Please review the updated LLD `docs/intent/record-store/record-store-design.md` and the edge-case gaps above. Confirm the whole-visit revisions design and contract, and indicate any changes to the Decisions & Alternatives rationale, the submission envelope fields, or the deferred questions before I proceed to Phase 3 formal EARS review and Phase 4 intent-narrowing edge audit.