I'd recommend keeping it as the **Decisions & Alternatives** table row in `previews-design.md` rather than writing a standalone decision doc.

In LID, the test for a decision doc is forward-looking from the landed state — not how long the debate took to get here:

1. **Blast radius is strictly local**: As the HLD and LLD establish, eviction policy is completely encapsulated inside the preview worker's private cache. It does not affect the HTTP contract (`200` / `202` / `404`), the 4-job FIFO render queue, the 12 GiB disk budget, or `review-api`. No other design node is sized around or constrained by this choice.
2. **The table row is sufficient for a cold reader**: A future maintainer looking at the cache implementation will naturally wonder "why 2Q instead of plain LRU or LFU?", and the single trade-off (protecting revisited comparison sets from sequential screening scans without LFU's project-switch lag) answers that in one paragraph.

That said, if you expect future maintainers to re-litigate the eviction policy (for example, once production telemetry arrives or when tuning the `A1in` / `Am` / `A1out` parameters) and want the full criteria and per-option analysis preserved at `docs/intent/previews/decisions/cache-eviction-policy.md`, I can draft one right now.

Would you like to keep just the table row in `previews-design.md`, or have me draft `docs/intent/previews/decisions/cache-eviction-policy.md`? Also, whenever you're ready, let me know how you'd like to handle the 5 edge-case questions from the Phase 2 probe above so we can wrap up Phase 2.