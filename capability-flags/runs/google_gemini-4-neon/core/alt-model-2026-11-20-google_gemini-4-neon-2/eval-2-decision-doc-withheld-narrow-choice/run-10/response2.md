I'd keep it as the **Decisions & Alternatives row** rather than writing a full decision doc.

The test for a decision doc is forward-looking from the landed design, not how hard the debate was:
- **It affects only one node.** The eviction policy is private to `previews` — neither `review-api` nor the HLD interface is sized around it, and reversing it later doesn't cascade elsewhere.
- **The row already settles a cold reader's "why 2Q?"** It records the three options and the exact trade-off (protecting comparison sheets during long screenings at the cost of extra queue bookkeeping and tuning). A long argument often still lands as a single table row; keeping decision docs rare avoids cluttering `docs/` with deliberation history.

That said, it's your call — if you think a future maintainer would genuinely re-litigate 2Q vs. LRU vs. aged frequency without the full criteria and per-option analysis laid out, I can write `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the table row.

Would you like to keep just the table row, or add the decision doc? (And whenever you're ready, let me know your triage on the Phase 2 edge-case items 1–7 so we can move to Phase 3.)