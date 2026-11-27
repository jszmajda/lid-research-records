The record-store design is finished around whole-visit revisions. This is the Phase 2 stop — please review before I cascade to specs.

**What changed**

- `docs/intent/record-store/record-store-design.md` — completed. The open-choice section is replaced by the contract it was holding a place for: the revision model (base=current becomes current; base=older becomes a pending competing revision; unknown/pending bases rejected), the submission envelope (visit ID, base revision ID, idempotency key, full payload, author), current-state and history retrieval, and the resolution operation (coordinator picks a winner; everything is retained; resolution record keeps coordinator identity + contributing submission IDs).
- `docs/high-level-design.md` — record-store's state is now "Designed", and the dependency paragraph reflects the selection instead of the open choice.

**Edge-case probe — decisions I made that deserve your eyes**

The Phase 2 probe (delegated) found the ordering rules were the draft's soft spot. I resolved them as follows; confirm or adjust:

1. **Current is frozen while unresolved.** Any submission arriving mid-competition joins the pending set — current moves only by resolution, so the coordinator's comparison target never shifts under them.
2. **Resolution names the revision set it reviewed.** If a submission arrived mid-review, the resolution is rejected and the coordinator re-reviews the refreshed set; the same rule arbitrates two coordinators resolving concurrently.
3. **Rejected submissions are logged, not dropped** — retained with their rejection reason, but never revisions, never in review or export.
4. Per-visit receipt-order serialization resolves the near-simultaneous-submission race; idempotency keys are globally unique with byte-identical retries; self-competition and stale-base resubmission after resolution are ordinary pending competitors.

**Open questions for you**

1. **Resolution amendment** — may a coordinator modify fields while resolving (creating a coordinator-authored revision atop the chosen one), or is resolution strictly pick-one? Pick-one is auditable but forces re-typing when two workers' changes should both survive.
2. **First submissions to an archived plot** — the catalog already excludes archived plots from the new-visit picker; should the store also reject such first submissions, or is the picker rule sufficient?

**Decision-doc offer**

The whole-visit choice is recorded in the LLD's Decisions & Alternatives table. Since tablet-sync and review-export are about to be sized around it, and a cold reader may be tempted to reverse it ("why not auto-merge disjoint edits?"), I can memorialize it as a full decision doc under `docs/intent/record-store/decisions/` — want that, or is the table row enough?

On your approval of the above, I'll proceed to Phase 3: updating the REC specs (existing REC-001–006 stay valid; new specs needed for base-revision handling, frozen current, resolution semantics, and the rejected-submission log). There's no code in this project yet, so tests and implementation come later.