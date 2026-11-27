---

## Record-Store Design Complete: Phase 3 Stop

I've documented the whole-visit revisions decision with full reasoning, implications for downstream work, and open questions. Here's what's now in place:

**Decision Documentation** (`docs/decisions/record-store-concurrency-strategy.md`):
- **Problem**: Competing edits from offline tablets; two coordinators must resolve before Friday export
- **Criteria**: Preservation, review workload, implementation scope, explainability, correctness under scientific uncertainty
- **Options compared**: 
  - Whole-visit revisions (selected): higher coordinator workload, but coordinators control merges where domain knowledge matters
  - Field-aware merge (not selected): auto-combines disjoint fields, but risks scientific relationships the rules cannot see
- **Rationale**: Correctness > reduced workload. The coordinators know which fields are related; the system doesn't.
- **Downstream obligations**:
  - Tablet-sync: Include base revision ID; show competing revisions on conflict; no auto-merge
  - Review-export: Unresolved queue with side-by-side comparison; export only resolved visits
- **Open questions**: How coordinators author manual merges; peak-season capacity; retention policy after resolution

**Updated LLD** (`record-store-design.md`):
- Decisions & Alternatives row links to the decision doc
- Full specification of submission envelope, current-state representation, and resolution operations

**Complete EARS Specs** (`record-store-specs.md`):
- REC-001 to REC-005: Submission & idempotency
- REC-010 to REC-015: Resolution status & export eligibility  
- REC-020 to REC-022: Resolution operations (selection, manual merge, immutability)

**Status Update** (HLD):
- Record-store marked "Drafted; whole-visit revisions selected"
- Tablet-sync and review-export marked "Ready to draft"

The design is ready for Phase 4 (intent-narrowing edge audit) to surface any cross-segment interactions or ambiguities before specs move to testing. Proceed?