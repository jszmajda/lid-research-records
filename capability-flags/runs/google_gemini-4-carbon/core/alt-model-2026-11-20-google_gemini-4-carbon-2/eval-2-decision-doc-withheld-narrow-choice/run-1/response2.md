I recommend sticking with the **`Decisions & Alternatives` row** in `previews-design.md` rather than adding a standalone decision doc.

### Why the row is enough here

- **Judge forward from the landed design, not backward from the debate.** Three meetings and a 180-message thread are deliberation history; the test for a decision doc is what a future cold reader needs once the design lands, not how hard it was to reach agreement.
- **Nothing outside `previews` leans on this choice.** `review-api`, the `200`/`202`/`404` HTTP contract, the 4-job render queue, and the 12 GiB ceiling are all unchanged across LRU, aged frequency, and 2Q, and HLD tenets explicitly keep replacement bookkeeping private to the worker. Because no other component is sized around 2Q, swapping or tuning the policy later stays strictly local to the cache.
- **The table row already answers "why not simpler LRU or aged frequency?"** A cold reader wondering why the cache maintains two queues gets the complete rationale in one place (protecting reused comparison sheets from sequential screening scans without holding stale favorites across project switches), without adding another document to keep in sync as cache details evolve.

### Where a decision doc *would* earn its keep

Because workload mix varies by production, none of the three policies universally dominates. The one forward-looking case for a standalone doc is if you expect someone during pilot tuning—seeing the two-queue bookkeeping or debating the probationary split—to try reversing 2Q back to plain LRU because a single table cell doesn't carry explicit weighted criteria to re-run the evaluation against real pilot hit-rate data.

If you want one despite the single-node scope, the trade-off is extra doc surface to maintain alongside `previews-design.md` for an internal mechanism no sibling node depends on. If we write it, it would live at `docs/intent/previews/decisions/cache-eviction-policy.md`, linked from the `Decisions & Alternatives` row, and written strictly cold (domain context, weighted criteria tied to the HLD tenets, per-option fit analysis, and selection—no mention of the meetings or thread).

Would you like to keep just the `Decisions & Alternatives` row (my recommendation) or have me draft `docs/intent/previews/decisions/cache-eviction-policy.md` anyway—and how would you like to triage the Phase 2 edge-case items (1–6) above?