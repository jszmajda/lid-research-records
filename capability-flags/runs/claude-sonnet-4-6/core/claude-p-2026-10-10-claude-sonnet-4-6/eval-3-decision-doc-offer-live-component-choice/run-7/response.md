---

**Phase 1 — HLD check**

The HLD covers the domain and doesn't need architectural changes. I updated the record-store row status from "Drafted; concurrency choice open" to "Drafted" to reflect the settled choice. No stop needed here — the HLD was already coherent and the update is bookkeeping.

---

**Phase 2 — LLD update**

The updated `docs/intent/record-store/record-store-design.md` now commits to whole-visit revisions and fills in the full contract. Here's what changed:

**Removed:** the "Open Design Choice" and "Downstream Contract Work" placeholder sections.

**Added:**

- **Submission envelope** — the full field set a tablet sends, including `base_revision_id` (null for first submission) and a note that `base_revision_id` referencing a different visit is rejected
- **Revision model** — three-rule conflict detection: first-ever submission → resolved; base matches current → linear advance, still resolved; anything else → competing, unresolved
- **Visit states** — `resolved` / `unresolved`, with the rule that a resolved visit can return to unresolved on a late stale-base submission
- **Current-state response** — what retrieval returns, and that competing payloads are only visible through the coordinator interface
- **Coordinator operations** — conditional resolution (second concurrent resolution is rejected, not silently overwritten), plus manual-combination revision with null base and provenance in the resolution record
- **Decisions & Alternatives** — five rows covering the concurrency choice, conflict trigger, late-submission acceptance, resolution atomicity, and the manual-combination base question

---

**LLD-level edge-case probe**

I ran the probe ("what happens when…") against this LLD's own gaps. Here are the findings and how I resolved each:

| Gap | Finding | Resolution recorded |
|---|---|---|
| Concurrent coordinator resolution | Two coordinators resolve the same visit simultaneously. Last-write-wins loses one coordinator's work without notice. | LLD: conditional execution — second coordinator is rejected and shown the current accepted revision and the first coordinator's identity. |
| Manual combination base | A coordinator-authored revision has no single logical parent. The submission envelope's `base_revision_id` field can't represent multiple contributing revisions. | LLD: coordinator-authored revisions carry `base_revision_id: null`; full provenance is in the resolution record's `contributing_revision_ids`. |
| Stale-base submission against no prior revisions | Tablet sends `base_revision_id: <some UUID>` but no revisions exist yet for the visit. | LLD: if no prior revisions exist, accept regardless of base and treat it as the first revision. |

All three resolutions are now in the Decisions & Alternatives table. Please verify the resolutions match your intent — particularly the concurrent-resolution behavior (reject second coordinator) and the manual-combination provenance model.

---

**Decision doc offer**

The concurrency choice clears the bar for a decision doc: two credible options traded against multiple criteria, and tablet-sync and review-export are both about to be sized around this result. A cold reader of the record-store design would plausibly question it. I can write `docs/intent/record-store/decisions/concurrency-policy.md`, with the Decisions & Alternatives row as the alternative if you'd rather keep it inline. Let me know either way.

---

Ready for your review. Once you approve the LLD (with any corrections), I'll move to Phase 3 — updating the EARS specs to cover the revision model, conflict detection, and coordinator operations.