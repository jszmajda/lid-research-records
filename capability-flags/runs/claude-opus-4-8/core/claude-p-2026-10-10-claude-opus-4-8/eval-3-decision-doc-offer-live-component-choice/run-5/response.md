I've read the skill, the HLD, the record-store LLD + specs, and the site-catalog design for coherence. Here's where I've landed.

---

**Picking up / coherence pre-flight.** HLD ↔ record-store LLD ↔ REC specs are mutually coherent for this segment; no tests exist yet, and no drift to repair. The only stale spot is downstream: the HLD still marks record-store "concurrency choice open," which I'll correct once the design lands (flagging that small upward edit now rather than making it silently).

**Scope.** I'll finish record-store only. Tablet-sync and review-export are separate segments; the whole-visit-revisions choice creates obligations for both (base-revision tracking on tablets; a revision-comparison view + holding unresolved visits out of the CSV on review/export). Those are **cross-segment cascades**, so I'll pause on them — which matches your "after that."

**No capability flags apply to my configuration**, so nothing there needs routing to you beyond the normal stops.

---

## The model I'll build the record-store LLD around (whole-visit revisions)

- A visit is a **lineage of complete revisions**. Each accepted edit attaches as a child of the **base revision** it names; the creating submission is the root (no base). A revision stores the full scientific-field snapshot plus author, server receipt time, base revision ID, and idempotency key.
- **Fork = a revision with more than one child.** A visit is *resolved* (has a single current state = its one leaf) or *unresolved* (more than one leaf — competing revisions). Arrival order never decides a winner; two edits off the same base both stand (satisfies REC-004 and the "don't silently discard" tenet).
- Submission, validation, and idempotency (REC-001/002/003) carry over unchanged; the only new envelope field is **base revision ID**.
- Retrieval reports current state vs. "unresolved review work exists" (REC-005); resolution records coordinator identity + contributing submission IDs (REC-006).

Two choices genuinely fork the contract and shape what tablet-sync/review-export will consume, so I want you to settle them before I write the LLD:

**1. What a resolution produces** (shapes REC-006 and the review/export workflow):
- **(a) Pick a winner** — coordinator promotes one competing revision intact; the other is retained but not current. Simplest; purest "whole-visit" intent.
- **(b) Pick a winner, or hand-author a reconciled revision** when neither competing visit is wholly right. Still no automatic combining — the coordinator types it. *(My recommendation: keeps whole-visit intent as the default while leaving a manual escape hatch for genuinely mixed cases; both paths record contributing submission IDs.)*
- **(c) Always hand-author a new reconciled revision.** Closest to manual merge; more coordinator effort every time.

**2. An edit that arrives while a visit is already unresolved** (sizes tablet-sync's retry behavior):
- **Accept and stack** it as another competing revision (resolution then handles an N-way fork). *My lean* — never rejects a valid submitted edit, consistent with "don't silently discard" and your "bigger review queue is fine."
- **Reject until resolved** — smaller review items, but bounces a worker's valid edit back.

Everything else from my Phase 2 edge probe I can decide and record, pending your nod: base-revision ID that is missing/unknown/belongs to another visit → reject at validation; an edit naming a pre-resolution revision after a visit was resolved → re-opens as a new fork (consistent with the model); full snapshot per revision (fine at ~6k visits/season).

---

## Decision-doc offer

The concurrency selection clears the bar for a standalone decision doc — credible competing options traded across review workload, implementation burden, scientific-relationship safety, and whole-visit preservation, with two sibling nodes about to be sized around it. I'd put it at `docs/intent/record-store/decisions/concurrent-visit-edits.md`. Want the **full decision doc**, or just a **Decisions & Alternatives row** in the LLD (my default if you'd rather stay light)?

---

**This is the Phase 2 stop.** Tell me (1) a/b/c, (2) stack-or-reject, (3) doc-or-row, plus any changes to the model above, and I'll write the record-store LLD, then stop again before EARS.