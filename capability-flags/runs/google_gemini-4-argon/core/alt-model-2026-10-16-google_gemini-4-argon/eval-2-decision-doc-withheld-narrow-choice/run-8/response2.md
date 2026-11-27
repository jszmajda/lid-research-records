I'd recommend keeping it as the `Decisions & Alternatives` row in `previews-design.md` rather than creating a standalone decision doc.

In LID, the test for a decision doc looks forward from the landed state rather than back at how long the deliberation took: *would a cold reader of the landed system re-litigate this choice without a full multi-page breakdown, and do other design nodes size themselves around it?*

Here:
1. **Strictly local blast radius**: By both the HLD tenet (*"Keep cache paths and replacement bookkeeping private to the preview worker"*) and the LLD architecture, the eviction policy is completely encapsulated inside the preview cache. The HTTP contract (`200`/`202`/`404`), the 4-worker render queue, the 12 GiB disk cap, and `review-api` are identical under LRU, aged frequency, and 2Q. No other component leans on or sizes itself around this choice.
2. **One paragraph settles the "why"**: A cold reader looking at the preview worker might reasonably ask *"why 2Q instead of plain LRU or LFU?"*—and the single workload fact (editors alternate linear screening scans with repeated small-set comparisons) answers that question in a few lines, which the `Decisions & Alternatives` table row already captures cleanly.

A long debate is a common reason to *want* a monument, but when the landed result is local to one node and a table row makes the trade-off self-evident to a future maintainer, a separate file in `docs/intent/previews/decisions/` adds maintenance surface without adding new design leverage.

That said, the call is yours—if you still want a standalone `docs/intent/previews/decisions/cache-eviction-policy.md` (for instance, if you expect future tuning of the 2Q vs. LFU trade-off to be revisited across teams), I can draft it now. Otherwise, we can keep the table row as-is and resolve or defer the four Phase 2 edge-case questions above to move to Phase 3. Which do you prefer?