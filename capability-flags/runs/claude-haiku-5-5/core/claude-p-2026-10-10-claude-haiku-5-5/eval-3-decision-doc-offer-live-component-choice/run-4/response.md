**Phase 1: HLD check (stopping for your review)**

I read "finish the record-store design" as the full phase sequence for record-store, with a stop at each phase boundary. This is the first stop. Nothing has been edited yet.

**Choice recorded:** Whole-visit revisions is the concurrency policy for record-store. The HLD already places this choice in record-store and says tablet-sync and review-export wait on its contract, so the choice does not change the HLD's architecture.

**Proposed HLD edit (not applied):** In the Architecture table, change the record-store State from "Drafted; concurrency choice open" to "Drafted; whole-visit revisions selected."

**Coherence pre-flight:** The HLD, the record-store design, and specs REC-001 to REC-006 agree with one another. Two items belong to later phases:
- The design's "Open Design Choice" section still presents both options. Phase 2 will replace it with the selected policy.
- REC-004 says "regardless of the concurrency policy's outcome." Once the LLD names the policy, that wording should name it too.

**Tenet to check:** Whole-visit revisions enlarge the review queue. That touches the tenet "Prefer workflows two coordinators can operate without a dedicated systems administrator." You have already accepted the larger queue, so I'll treat it as your trade-off. I can also note it in the LLD as a known cost of this policy.

**Decision doc:** This choice will stay live for a cold reader. They will ask why not field-aware merge, and tablet-sync and review-export will be sized around the answer. I suggest recording it as a decision doc at `docs/intent/record-store/decisions/concurrency-policy.md`, with a Decisions row in the record-store LLD that links to it. Would you like the doc, or just the row?

**Please reply with:**
1. Approve the HLD state-cell edit above?
2. Decision doc or Decisions row?
3. Should the LLD name the coordinator review-load cost?

Once you approve, I'll move to Phase 2 and draft the record-store LLD.