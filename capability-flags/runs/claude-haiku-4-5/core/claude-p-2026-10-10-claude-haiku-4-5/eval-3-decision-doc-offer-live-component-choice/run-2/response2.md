Perfect. Now let me present the completed record-store design for Phase 2–3 review:

---

## Record Store Design — Phase 2 & 3 Complete

I've finalized the record-store design with the whole-visit revisions approach you selected. Here's what's ready for review:

### Design LLD (Phase 2)
**docs/intent/record-store/record-store-design.md** now contains:
- **Concurrency Policy** section replacing the open choice with the whole-visit revisions approach
- **Submission Envelope** specifying what tablets send: `visit_id`, `base_revision_id` (nullable), `author_id`, `idempotency_key`, `fields`, `submitted_at`
- **Server Response** defining what tablets receive: `revision_id`, `is_resolved`, `competing_revision_ids`
- **Current-State Retrieval** contract for both tablets and coordinators
- **Coordinator Resolution Operation** showing how conflicts are settled (select existing revision or construct merged state)
- **Decisions & Alternatives table** with three rows; the primary decision links to the full decision doc

### Decision Doc
**docs/intent/record-store/decisions/concurrent-visit-edits.md** records the choice between whole-visit revisions and field-aware three-way merge, laying out:
- Why whole-visit revisions wins: avoids silent merge errors in scientifically sensitive data, keeps logic auditable and maintainable by coordinators
- Why field-aware merge was genuinely credible: 2–5% conflict rate vs. 10–20% would halve coordinator workload
- Downstream obligations for tablet-sync (track base revision IDs, block new edits if unresolved) and review-export (revision comparison view, hold unresolved visits from export)

### EARS Specs (Phase 3)
**docs/intent/record-store/record-store-specs.md** expanded from 6 to 12 specs grouped by function:
- **REC-001/004**: Submission envelope and first submission
- **REC-002/003**: Idempotency handling
- **REC-005/007**: Conflict detection and state transitions
- **REC-006**: Resolution marking
- **REC-008/009**: Retrieval operations
- **REC-010/012**: Coordinator resolution and forward linkage

### Consistency Verification (Phase 3)

✓ **Coverage**: All behaviors in the LLD have corresponding specs. Whole-visit revision model, base revision tracking, conflict detection, history, and coordinator resolution all covered.

✓ **Contradiction**: No contradictions. REC-005/006/007 form a coherent state machine (concurrent edits → unresolved; no concurrent edits → resolved; unresolved state blocks current update). REC-010/011/012 form a coherent resolution sequence.

✓ **Implicit Scoping**: All specs have explicit scope. Actor and action are named ("When an authenticated worker submits..." vs. "When a coordinator submits..."). No reliance on section headers for meaning.

✓ **Context-Free Reading**: Each spec references only terms defined in the LLD's "Submission Envelope" section. No conversion context needed. A reader encountering these via grep would understand them.

---

The record-store design is now complete and ready to serve tablet-sync and review-export contracts. The design documents context-free for future readers, the decision doc preserves why whole-visit revisions trades higher review volume for auditability and absence of automatic merge risk, and the specs fully specify the public contract (submission format, response shape, conflict representation, resolution operation).

Ready to proceed to Phase 4 (intent-narrowing edge audit) or would you like adjustments to the design or specs?