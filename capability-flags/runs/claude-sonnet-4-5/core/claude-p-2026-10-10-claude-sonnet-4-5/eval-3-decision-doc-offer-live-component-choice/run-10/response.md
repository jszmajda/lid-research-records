## Phase 2 — Updated Record-Store LLD

I've updated the record-store LLD to incorporate the whole-visit revisions choice and defined the core contracts:

**Key additions:**
- Whole-visit revision model with revision chains and competing revisions
- Submission contract (envelope format, validation, acceptance response)
- Current state retrieval (resolved/unresolved/not found cases)
- Resolution operations (selection and manual merge)
- Idempotency rules
- Submission history retrieval
- Decisions & Alternatives table documenting the choice

**Updated file:** `docs/intent/record-store/record-store-design.md`

**Edge-case probe findings:** The probe identified 30 gaps in the current design, grouped into:

1. **State transitions** (9 questions) — e.g., what happens when an edit arrives while visit is unresolved? Can edits reference competing revisions as base?
2. **Unstated invariants** (5 questions) — e.g., are revision IDs strictly sequential? Is there always a revision 1?
3. **Error shapes** (5 questions) — e.g., what's returned when base revision doesn't match? Validation rejection format?
4. **Ordering assumptions** (3 questions) — e.g., ordering of competing revisions in responses, revision history
5. **Resolution mechanics** (4 questions) — e.g., validation rules for merged revisions, can visits be re-resolved?
6. **Idempotency** (3 questions) — e.g., time window for key validity, retry handling during processing
7. **Edge cases** (1 question) — e.g., can visits be deleted?

Which gaps should I address in the LLD now, and which should be deferred as open questions for implementation?