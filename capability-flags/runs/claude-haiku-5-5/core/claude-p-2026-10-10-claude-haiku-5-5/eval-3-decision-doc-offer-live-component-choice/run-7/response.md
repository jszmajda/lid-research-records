**Phase 1: HLD check (record-store concurrency policy)**

I have not changed any files. This stop covers the HLD check only. The LLD and EARS drafts come after you approve.

**Coherence pre-flight.** The CAT-001 to CAT-004 specs trace to `site-catalog-design.md`. The REC-001 to REC-006 specs trace to `record-store-design.md`, but REC-004 is written around the open choice, and that design doc still has its "OPEN" section. Both change in Phase 2. There is no code or test yet, so there is nothing to check there.

**HLD.** The HLD covers this change and needs no architectural revision. The HLD assigns the concurrency mechanism to record-store, so the selection belongs in record-store's LLD. One HLD line goes stale. The record-store State cell reads "Drafted; concurrency choice open." Proposed replacement: "Drafted; whole-visit revisions selected; contract pending."

**Tenets.** Whole-visit revisions fit "Do not silently discard a submitted edit" and "Keep the path from a submitted observation to an exported value inspectable." They work against "Prefer workflows two coordinators can operate without a dedicated systems administrator," because unrelated concurrent edits now create review items. You accepted that cost, so I plan to record it as a stated consequence in the LLD's Selection, not as an open conflict.

**Decision record.** A cold reader would ask why unrelated field edits aren't combined automatically. The answer rests on review load, merge-rule maintenance, and the scientific relationships the server can't see. Tablet-sync and review-export both depend on this choice. That makes it live enough to warrant a full decision doc. Which do you want?
- (a) A decision doc at `docs/intent/record-store/decisions/concurrency-policy.md`, linked from a Decisions row in `record-store-design.md`.
- (b) A Decisions row only.

**Fork to settle in Phase 2.** The design has to define "concurrent." My proposed reading: an edit is concurrent when its starting revision is no longer the visit's current revision when it arrives. Under that reading, a worker's sequential edits from the latest state don't compete. Please confirm this reading, or give a different one.

**Needed from you:**
1. Approve the HLD State cell change above, or suggest different wording.
2. Choose (a) or (b) for recording the decision.
3. Confirm the "concurrent" definition.

Once you reply, I'll draft the record-store LLD and EARS specs (Phases 2 and 3) and stop again for review. Tablet sync and review/export come after that.