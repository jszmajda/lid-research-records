## Phase 2 Complete: Record-Store LLD

I've finished the record-store design with the whole-visit revisions approach. The design now includes:

**Added sections:**
- **Concurrency Policy**: Whole-visit revisions with explicit rationale
- **Submission Contract**: Complete envelope specification (visit ID, base revision ID, idempotency key, worker ID, payload)
- **Current-State Retrieval**: Three states (Resolved, Unresolved, Not found) with their representations
- **Review-Work Representation**: What coordinators see when resolving conflicts
- **Resolution Operation**: How coordinators select or combine revisions
- **Downstream Contract Summary**: Clear interfaces for tablet-sync and review-export
- **Decisions & Alternatives**: Documents the concurrency policy choice and three other key decisions

**Updated HLD**: The architecture table now reflects that record-store's concurrency choice is resolved and downstream nodes can proceed.

### Edge-Case Probe Findings

The probe identified 35 gaps in the current design, grouped into:

**Critical gaps needing resolution before Phase 3:**
- **Base revision validation** (Q1-3): What happens when base revision IDs are invalid, cross-visit, or null on first submission?
- **Idempotency scoping** (Q6-9): Is idempotency key scoped per-visit or global? What counts as "identical payload"?
- **Resolution API shape** (Q10-15): Single operation or separate? Combined revision semantics unclear
- **Error response structure** (Q19-21): No error format specified

**Design clarifications that strengthen the spec:**
- State transition atomicity (Q5)
- Conflict definition boundary (Q4)
- Concurrent submission handling (Q16-18, Q22-24)
- Worker ID derivation (Q33)

**Implementation details that can be deferred:**
- Payload size limits (Q25)
- Review queue ordering (Q30)
- Visual diff for null-base revisions (Q31)
- Retention policy (Q34)

**Which gaps should I address in the LLD now, and which should I record as Open Questions for implementation-time decisions?**