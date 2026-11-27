**Coherence pre-flight** (resuming work, record-store segment): HLD ↔ record-store LLD coherent; REC-001–006 all trace to LLD sections, with REC-005/REC-006 deliberately policy-neutral pending this choice. No tests or code exist yet, so nothing downstream is stale. site-catalog untouched by the selection. No drift to repair.

**Phase 1 — HLD check.** Whole-visit revisions doesn't change the architecture: record-store still owns concurrency, and the node boundaries stand. Two lines recorded the choice as open, so they were stale as of your selection. I made only those edits to `docs/high-level-design.md`:

1. record-store's State column: `Drafted; concurrency choice open` → `Drafted`.
2. The paragraph after the table, now:

> The concurrency mechanism belongs to record-store, not this HLD. Concurrent edits to one visit are kept as competing whole-visit revisions that a coordinator resolves. Tablet-sync and review-export are sized around that node's contract: it determines submission metadata, the shape of review work, and which record states can enter an export. Both link back to record-store rather than restating concurrency semantics.

Problem, Approach, Tenets, Goals, and Non-Goals all still read true — nothing there assumed merge semantics.

Three things for you before I draft the record-store design:

1. **HLD edits** — good as above, or would you rather the root not name the revision shape at all and just point at record-store?
2. **A tenet from your reasoning.** "I'll take a bigger review queue over maintaining merge rules that can combine scientifically related edits without noticing" reads as a lean that will govern choices no spec anticipates — review-export will face it again (auto-accepting "trivial" differences), and so will tablet-sync. The existing tenets don't cover it: "do not silently discard a submitted edit" is about loss, not about silent combination. Candidate: **"Prefer visible review work over automatic reconciliation the team cannot audit."** Its opposite is a real choice another project could make, so it passes the defensible-opposite test. Add it, or keep the tenet list as is?
3. **How to record the choice.** This one stays live for a cold reader — field-aware merge is genuinely attractive (fewer unresolved visits, more exported on Friday), the two options traded against more than one criterion, and two sibling nodes are about to be sized around the result. So I'd offer a full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, laying out both options, the criteria (review workload, implementation burden, preservation of whole-visit scientific intent, export readiness) and the selection. The lighter alternative is a single Decisions & Alternatives row in the record-store LLD. Which do you want?

Once you've ruled on these I'll draft the finished record-store design — submission envelope with base revision ID, revision/competing-revision model, current-state and unresolved-work representation, and the resolution operation — then run the Phase 2 edge-case probe before we touch specs. Tablet-sync and review-export stay untouched, as you said.