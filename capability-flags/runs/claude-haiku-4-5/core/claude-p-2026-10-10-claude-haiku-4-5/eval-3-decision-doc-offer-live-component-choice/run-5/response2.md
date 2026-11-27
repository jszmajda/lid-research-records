---

## Phase 2-3 Stop: Record-Store LLD & EARS Review

### Completed Design

**Record-store-design.md** now contains:

1. **Context** — visit persistence for a 6,000/season dataset with offline capture and independent corrections
2. **Architecture** — authenticated submission, retrieval, and review-outcome operations
3. **Submission Envelope** — visit ID, base revision ID, complete record, author, idempotency key, timestamp
4. **Revision States** — each submission gets a revision ID; competing revisions (same base, different edits) trigger review work
5. **Current Revision Logic** — latest uncontested revision; if competitors exist, marked unresolved
6. **Revision History** — chains preserve the edit lineage; abandoned branches are still auditable
7. **Resolution Operation** — coordinator selects competing revision; selection recorded with identity and timestamp
8. **Decisions & Alternatives** — rationale for whole-visit revisions (auditability + scientific integrity > automation) over field-aware merge
9. **Downstream Implications** — specific accommodations for tablet-sync and review-export

**record-store-specs.md** contains 20 EARS specifications organized by concern:
- Submission envelope and acceptance (REC-001–004)
- Revision creation and tracking (REC-010–012)
- Competing revision detection (REC-020–022)
- Current revision and unresolved state (REC-030–033)
- History preservation (REC-040–041)
- Resolution operations (REC-050–053)
- Immutability of original submissions (REC-060)

### Consistency Verification

**Coverage check**: All behaviors described in the LLD have corresponding EARS specs. Submission flow, idempotency, revision mechanics, competing detection, current selection, resolution, and audit trail are all specified. ✅

**Contradiction check**: No specs contradict each other. Competing-revision logic (REC-020–022) and resolution (REC-050–053) are consistent. ✅

**Implicit scoping check**: All major specs use explicit WHEN or While clauses. REC-001–004 scope to authenticated submission, REC-030–033 scope to retrieval and unresolved states. No universal "the system shall" masking a context-dependent rule. ✅

**Context-free reading**: Each spec can be understood via grep without surrounding conversation. Terms like "base revision," "competing revisions," and "current revision" are clear from their EARS context, though the LLD provides fuller context if needed. ✅

### LLD-Level Edge Cases (gaps identified and addressed in design)

1. **Invalid base revision ID**: LLD mentions validation; REC-004 requires the base ID in the envelope. Handling a missing base ID (whether it's treated as invalid, or whether orphaned revisions are allowed) is open and will be clarified during tablet-sync design when the retry strategy is sized.

2. **Coordinator never resolves competing work**: Allowed by design. Unresolved visits remain held out of export (review-export concern, not record-store). No timeout or auto-resolution is specified — coordinators resolve on their schedule.

3. **Resubmission against an abandoned competing revision**: REC-053 specifies it creates a new competing branch. This allows recovery paths if a worker re-syncs and resubmits old edits; the design doesn't prevent it, requiring review-export to explain this to coordinators.

4. **Simultaneous submissions by two workers**: Covered by REC-020-021. Both create revisions; both compete. Arrival order doesn't matter (no "first edit wins").

5. **Field validation scope**: REC-004 requires validation; specifics (which fields, what plot references are valid) belong to site-catalog or a separate validation spec. Record-store enforces "submission structure is valid," not botanical correctness.

### Readiness Assessment

The record-store design is **complete and ready for Phase 4 (intent-narrowing edge audit)**, which will examine cross-spec and cross-segment interactions with tablet-sync and review-export before tests are written.

**Proceed to Phase 4?**