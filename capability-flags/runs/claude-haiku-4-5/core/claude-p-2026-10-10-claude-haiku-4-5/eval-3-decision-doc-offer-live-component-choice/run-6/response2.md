---

## Phase 2 (LLD Check/Draft) — Complete

I've finalized the record-store design with the whole-visit revisions choice and created supporting documentation. Here's what's ready for your review:

### Updated Files

**1. HLD updated** (`docs/high-level-design.md`)
- Record-store row now shows "Drafted; whole-visit revisions selected"
- Tablet-sync and review-export now marked "Ready to draft" — they have the contract they need

**2. Record-store LLD** (`docs/intent/record-store/record-store-design.md`)
- Replaced the open-choice section with concrete **Concurrency Model: Whole-Visit Revisions** describing:
  - Three visit states: Current, Unresolved, Resolved
  - Submission envelope contents (UUID, plot reference, base revision ID, complete visit data, author, idempotency key, server receipt timestamp)
  - Current-state retrieval responses (different shapes for Current vs. Unresolved visits)
  - Coordinator resolution paths (select competing revision, or manually merge)
  - Preservation guarantees (all submissions retained, idempotency keys valid indefinitely)
  - **Downstream Contract Work** — concrete obligations for tablet-sync and review-export

**3. Record-store EARS specs** (`docs/intent/record-store/record-store-specs.md`)
- Expanded from 6 generic specs to 20 concrete specs, organized into sections:
  - Submission Acceptance and Idempotency (REC-001 to REC-003)
  - Visit State Transitions (REC-004 to REC-007)
  - Retrieval (REC-008 to REC-010)
  - Coordinator Resolution (REC-011 to REC-013)
  - Preservation and Audit Trail (REC-014 to REC-016)
  - Error Handling and Edge Cases (REC-017 to REC-020)

**4. Decision doc** (`docs/intent/record-store/decisions/concurrent-edit-strategy.md`)
- Full context: why this decision is needed (offline tablets, independent corrections, audit requirements)
- Decision elements: 2 gates (inherited from HLD) and 5 weighted criteria (workload, intent preservation, implementation burden, downstream complexity, explainability)
- Both options fully analyzed:
  - **Whole-visit revisions:** weak on workload, strong on intent preservation, implementation simplicity, downstream simplicity, explainability
  - **Field-aware merge:** strong on workload, weak on intent preservation and implementation burden, moderate downstream complexity
- Selection rationale: intent preservation and coordinator control win; the larger review queue is an accepted tradeoff
- Downstream obligations spelled out for tablet-sync and review-export

### Coherence Check

**Coverage:** All design sections map to specs. No spec references behavior not in the design.

**Contradiction:** None found. All specifications align with the design.

**Implicit scoping:** Specs clearly mark when they apply (first submission, subsequent, older revision, unresolved, resolution). No universal specs that actually apply only to one context.

**Context-free reading:** Each spec stands alone; a reader grepping `REC-011` would understand it without the surrounding design.

### Ready for Review

Please confirm:
1. Does the whole-visit revisions design match your intent?
2. Does the decision doc capture the tradeoffs accurately? (Especially: is the "coordinators prefer manual control" the right priority?)
3. Are the downstream obligations (what tablet-sync and review-export must do) what you expected?

Once approved, I'll proceed to Phase 3 (EARS consistency check) and Phase 4 (intent-narrowing edge audit).