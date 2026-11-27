I’d recommend **keeping it as the `Decisions & Alternatives` table row** in `previews-design.md` rather than adding a standalone decision doc.

Here is why:

- **Judge from the landed design, not the debate history.** Three meetings and a 180-message thread reflect how hard it was to reach consensus, not what a future reader needs once the code exists. A standalone decision doc earns its place looking forward—when a choice stays live and costly to get wrong without the full criteria-and-options breakdown.
- **The blast radius stays inside one node.** By design, `review-api`, the `200`/`202`/`404` HTTP contract, the four-job FIFO render queue, and the 12 GiB disk cap are identical under LRU, aged frequency, and 2Q. No other component is sized around or coupled to 2Q, so tuning or replacing it later stays local to the preview worker.
- **One row settles what a cold reader would actually ask.** A future maintainer seeing two queues instead of plain LRU will wonder *"why the extra queues?"*—and the row in `previews-design.md` already answers both halves of that question (protecting comparison sets during sequential screeningsunlike LRU, and adapting faster on project switches than aged frequency counters).

That said, it is your call: if you expect teammates who weren't in those meetings to keep re-opening LRU vs. aged frequency vs. 2Q unless the full weighted criteria and per-option analysis are on record, I can draft `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the table row (at the small cost of maintaining an extra doc for a node-private choice).

Would you like to stick with the table row, or have me draft the decision doc? Whenever we settle that, let me know your thoughts on the Phase 2 LLD and edge-case probe items as well.