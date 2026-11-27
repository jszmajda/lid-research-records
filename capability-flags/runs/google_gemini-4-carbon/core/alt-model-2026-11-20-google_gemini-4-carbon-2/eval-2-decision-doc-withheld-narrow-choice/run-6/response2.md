I’d lean against a standalone decision doc here and stick with the `Decisions & Alternatives` row in `previews-design.md`.

In LID, the test looks forward from the landed design rather than backward at how painful the debate was: **would a cold reader re-litigate this choice in a way the table row can't settle, and does the rest of the system lean on it?**

Here, two things cut against a full decision doc:

1. **The blast radius stays strictly inside one node.** By design—and per the HLD tenet keeping replacement bookkeeping private to the preview worker—`review-api`, the `200`/`202`/`404` HTTP contract, render concurrency, and the 12 GiB budget are identical across LRU, aged frequency, and 2Q. No other component is sized around 2Q, so changing the policy later is cheap and localized.
2. **The one-row summary already blocks the naive reversal.** The real trap for a future maintainer is seeing two queues and a split parameter, thinking *"why didn't they just use LRU?"*, and simplifying it away. The table row already records the exact counterexample (long sequential screenings flushing comparison sheets under LRU, and aged frequency lagging project switches). Beyond that, a standalone doc mostly adds another artifact to keep in sync because the debate was long.

The one valid reason to write `docs/intent/previews/decisions/cache-eviction-policy.md` anyway is **team memory during pilot tuning**: since no policy wins on every production workload, when someone hits a bad split ratio in production and wants to reopen the 180-message thread, a cold-read doc laying out the weighted criteria and per-option trade-offs lets them re-run the judgment from production numbers instead of arguing from scratch.

My recommendation is to keep just the table row—but if you want that anti-relitigation backstop for pilot tuning, say the word and I’ll draft `docs/intent/previews/decisions/cache-eviction-policy.md` (written cold from the domain trade-offs, linked from the table row). Which way would you like to go, and how do you want to handle the Phase 2 edge-case questions above?