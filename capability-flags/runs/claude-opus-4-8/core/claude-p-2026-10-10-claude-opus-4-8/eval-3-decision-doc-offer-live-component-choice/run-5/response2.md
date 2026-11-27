Phase 2 written. Both artifacts are on disk:

- **`docs/intent/record-store/record-store-design.md`** — revised around whole-visit revisions: a per-visit revision lineage, a **fork** (a revision with >1 child) as the structural conflict condition so arrival order never confers authority, the submission envelope now carrying a base revision ID, resolution semantics, and the handling of edits onto an already-unresolved visit. Plus a Decisions & Alternatives table and a Downstream Obligations section for tablet-sync and review-export.
- **`docs/intent/record-store/decisions/concurrent-visit-edits.md`** — the full decision doc: both options in their strongest honest form, the criteria they turn on, the selection, **why field-aware merge stays on the table** (the lever to pull if review volume proves unsustainable), and the tablet/export obligations.

**Selections I took** (you saw these as open forks last turn — flagging so you can redline):
1. **Resolution = promote-or-hand-author (1b).** Coordinator promotes one competing revision intact, or hand-authors a reconciled one; the server never combines fields.
2. **Edits onto an unresolved visit = accept-and-stack (2).** A valid edit is never bounced; an unresolved visit can hold more than two competitors.

Both are recorded as Decisions rows with their rejected alternatives.

**Two things to check yourself:**
- **Resolution outcome shapes review-export** (the coordinator view and REC-006's provenance). It's the most consequential of the two selections — worth confirming 1b is what you want before it hardens into specs.
- **Pending upward cascade to the HLD** (I did *not* edit it). The architecture table still reads "Drafted; concurrency choice open," and the prose says tablet-sync/review-export "must wait for its contract." Once you approve this LLD, I'd update that row to reflect the resolved choice and soften the prose, since the contract now exists. That's an edit to the root doc, so I'm asking before making it.

**This is the Phase 2 stop.** I have *not* touched the REC specs yet — that's Phase 3, with its own stop. Tablet-sync and review-export remain deferred as separate segments, per your plan.

Give me: any redlines to the LLD or decision doc, confirm or change selections 1–2, and a yes/no on the HLD cascade edit. Then I'll move to the EARS updates.